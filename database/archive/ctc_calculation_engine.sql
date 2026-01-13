-- Cost to Complete (CTC) Calculation Engine
-- =====================================================

-- CTC Calculation View
CREATE OR REPLACE VIEW ctc_calculations AS
WITH project_costs AS (
    SELECT 
        p.id as project_id,
        p.name as project_name,
        p.budget as total_budget,
        CURRENT_DATE as calculation_date,
        
        -- Total actual and budget amounts
        COALESCE(SUM(co.actual_amount), 0) as total_actual_cost,
        COALESCE(SUM(co.budget_amount), 0) as total_budget_cost,
        
        -- Progress percentage (weighted average)
        COALESCE(AVG(t.progress_percentage), 0) as avg_progress,
        
        -- Total committed costs from approved POs
        COALESCE(SUM(CASE 
            WHEN po.status = 'approved'
            THEN po.total_amount
            ELSE 0 
        END), 0) as total_committed
        
    FROM projects p
    LEFT JOIN wbs_nodes w ON w.project_id = p.id
    LEFT JOIN activities a ON a.wbs_node_id = w.id
    LEFT JOIN tasks t ON t.activity_id = a.id
    LEFT JOIN cost_objects co ON co.task_id = t.id
    LEFT JOIN purchase_orders po ON po.project_id = p.id
    WHERE p.status = 'active'
    GROUP BY p.id, p.name, p.budget
)
SELECT 
    *,
    -- CTC calculation based on progress and remaining budget
    CASE 
        WHEN avg_progress >= 100 THEN 0
        ELSE GREATEST(0, (total_budget_cost - total_actual_cost - total_committed) * (100 - avg_progress) / 100.0)
    END as total_ctc,
    
    -- Forecast at completion
    total_actual_cost + total_committed + CASE 
        WHEN avg_progress >= 100 THEN 0
        ELSE GREATEST(0, (total_budget_cost - total_actual_cost - total_committed) * (100 - avg_progress) / 100.0)
    END as forecast_at_completion
    
FROM project_costs;

-- Function to calculate CTC for specific project
CREATE OR REPLACE FUNCTION calculate_project_ctc(p_project_id UUID)
RETURNS TABLE (
    project_id UUID,
    project_name VARCHAR,
    calculation_date DATE,
    total_budget DECIMAL,
    total_actual DECIMAL,
    total_committed DECIMAL,

    total_ctc DECIMAL,
    forecast_at_completion DECIMAL,
    budget_variance DECIMAL,
    progress_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.project_id,
        c.project_name,
        c.calculation_date,
        c.total_budget,
        c.total_actual_cost as total_actual,
        c.total_committed,

        c.total_ctc,
        c.forecast_at_completion,
        c.total_budget - c.forecast_at_completion as budget_variance,
        c.avg_progress as progress_percentage
    FROM ctc_calculations c
    WHERE c.project_id = p_project_id;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate CTC at task level
CREATE OR REPLACE FUNCTION calculate_task_ctc(p_task_id UUID)
RETURNS TABLE (
    task_id UUID,
    task_name VARCHAR,
    budget_amount DECIMAL,
    actual_amount DECIMAL,
    progress_percentage DECIMAL,
    remaining_work DECIMAL,
    ctc_amount DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id as task_id,
        t.name as task_name,
        COALESCE(co.budget_amount, 0) as budget_amount,
        COALESCE(co.actual_amount, 0) as actual_amount,
        COALESCE(t.progress_percentage, 0) as progress_percentage,
        (100 - COALESCE(t.progress_percentage, 0)) / 100.0 as remaining_work,
        CASE 
            WHEN COALESCE(t.progress_percentage, 0) >= 100 THEN 0
            ELSE (COALESCE(co.budget_amount, 0) - COALESCE(co.actual_amount, 0)) * 
                 (100 - COALESCE(t.progress_percentage, 0)) / 100.0
        END as ctc_amount
    FROM tasks t
    LEFT JOIN cost_objects co ON co.task_id = t.id
    WHERE t.id = p_task_id;
END;
$$ LANGUAGE plpgsql;

-- Function for advanced CTC calculation with burn rate analysis
CREATE OR REPLACE FUNCTION calculate_ctc_with_burn_rate(
    p_project_id UUID,
    p_analysis_period_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    project_id UUID,
    current_ctc DECIMAL,
    burn_rate_ctc DECIMAL,
    trend_ctc DECIMAL,
    recommended_ctc DECIMAL,
    confidence_level VARCHAR
) AS $$
DECLARE
    current_burn_rate DECIMAL;
    historical_variance DECIMAL;
BEGIN
    -- Calculate current burn rate
    SELECT 
        COALESCE(SUM(ct.amount) / NULLIF(p_analysis_period_days, 0), 0)
    INTO current_burn_rate
    FROM cost_transactions ct
    JOIN cost_objects co ON co.id = ct.cost_object_id
    JOIN tasks t ON t.id = co.task_id
    JOIN activities a ON a.id = t.activity_id
    JOIN wbs_nodes w ON w.id = a.wbs_node_id
    WHERE w.project_id = p_project_id
    AND ct.transaction_date >= CURRENT_DATE - p_analysis_period_days;
    
    -- Calculate historical variance
    SELECT 
        STDDEV(ct.amount)
    INTO historical_variance
    FROM cost_transactions ct
    JOIN cost_objects co ON co.id = ct.cost_object_id
    JOIN tasks t ON t.id = co.task_id
    JOIN activities a ON a.id = t.activity_id
    JOIN wbs_nodes w ON w.id = a.wbs_node_id
    WHERE w.project_id = p_project_id
    AND ct.transaction_date >= CURRENT_DATE - (p_analysis_period_days * 3);
    
    RETURN QUERY
    SELECT 
        c.project_id,
        c.total_ctc as current_ctc,
        -- Burn rate based CTC
        CASE 
            WHEN c.avg_progress > 0 
            THEN current_burn_rate * (100 - c.avg_progress) / c.avg_progress * 100
            ELSE c.total_ctc
        END as burn_rate_ctc,
        -- Trend based CTC (with variance adjustment)
        c.total_ctc * (1 + COALESCE(historical_variance, 0) / NULLIF(c.total_actual_cost, 0)) as trend_ctc,
        -- Recommended CTC (weighted average)
        (c.total_ctc * 0.4 + 
         CASE 
            WHEN c.avg_progress > 0 
            THEN current_burn_rate * (100 - c.avg_progress) / c.avg_progress * 100
            ELSE c.total_ctc
         END * 0.4 +
         c.total_ctc * (1 + COALESCE(historical_variance, 0) / NULLIF(c.total_actual_cost, 0)) * 0.2
        ) as recommended_ctc,
        -- Confidence level
        CASE 
            WHEN COALESCE(historical_variance, 0) / NULLIF(c.total_actual_cost, 0) < 0.1 THEN 'high'
            WHEN COALESCE(historical_variance, 0) / NULLIF(c.total_actual_cost, 0) < 0.2 THEN 'medium'
            ELSE 'low'
        END as confidence_level
    FROM ctc_calculations c
    WHERE c.project_id = p_project_id;
END;
$$ LANGUAGE plpgsql;
-- Margin Analysis System
-- =====================================================

-- Billing/Revenue tracking table
CREATE TABLE IF NOT EXISTS project_billing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    billing_date DATE NOT NULL,
    billing_amount DECIMAL(15,2) NOT NULL,
    billing_type VARCHAR(20) DEFAULT 'progress', -- progress, milestone, final
    description TEXT,
    invoice_number VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending', -- pending, invoiced, paid
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Margin Analysis View
CREATE OR REPLACE VIEW margin_analysis AS
WITH project_financials AS (
    SELECT 
        p.id as project_id,
        p.name as project_name,
        p.budget as contract_value,
        CURRENT_DATE as analysis_date,
        
        -- Cost data
        COALESCE(SUM(co.budget_amount), 0) as planned_cost,
        COALESCE(SUM(co.actual_amount), 0) as actual_cost,
        
        -- Billing data
        COALESCE(SUM(pb.billing_amount), 0) as total_billed,
        COALESCE(SUM(CASE WHEN pb.status = 'paid' THEN pb.billing_amount ELSE 0 END), 0) as total_received,
        
        -- Progress
        COALESCE(AVG(t.progress_percentage), 0) as avg_progress,
        
        -- CTC from existing calculation
        COALESCE(ctc.total_ctc, 0) as cost_to_complete,
        COALESCE(ctc.forecast_at_completion, 0) as forecast_cost
        
    FROM projects p
    LEFT JOIN wbs_nodes w ON w.project_id = p.id
    LEFT JOIN activities a ON a.wbs_node_id = w.id
    LEFT JOIN tasks t ON t.activity_id = a.id
    LEFT JOIN cost_objects co ON co.task_id = t.id
    LEFT JOIN project_billing pb ON pb.project_id = p.id
    LEFT JOIN ctc_calculations ctc ON ctc.project_id = p.id
    WHERE p.status = 'active'
    GROUP BY p.id, p.name, p.budget, ctc.total_ctc, ctc.forecast_at_completion
)
SELECT 
    *,
    -- Planned Margin (Contract Value - Planned Cost)
    contract_value - planned_cost as planned_margin,
    CASE 
        WHEN contract_value > 0 THEN ((contract_value - planned_cost) / contract_value) * 100
        ELSE 0 
    END as planned_margin_percent,
    
    -- Actual Margin (Total Billed - Actual Cost)
    total_billed - actual_cost as actual_margin,
    CASE 
        WHEN total_billed > 0 THEN ((total_billed - actual_cost) / total_billed) * 100
        ELSE 0 
    END as actual_margin_percent,
    
    -- Estimated Margin (based on progress billing)
    (contract_value * avg_progress / 100.0) - actual_cost as estimated_margin,
    CASE 
        WHEN contract_value * avg_progress / 100.0 > 0 
        THEN (((contract_value * avg_progress / 100.0) - actual_cost) / (contract_value * avg_progress / 100.0)) * 100
        ELSE 0 
    END as estimated_margin_percent,
    
    -- Projected Margin (Contract Value - Forecast Cost)
    contract_value - forecast_cost as projected_margin,
    CASE 
        WHEN contract_value > 0 THEN ((contract_value - forecast_cost) / contract_value) * 100
        ELSE 0 
    END as projected_margin_percent,
    
    -- Revenue recognition
    contract_value * avg_progress / 100.0 as earned_revenue,
    contract_value - total_billed as unbilled_revenue
    
FROM project_financials;

-- Function to get margin analysis for specific project
CREATE OR REPLACE FUNCTION get_project_margin_analysis(p_project_id UUID)
RETURNS TABLE (
    project_id UUID,
    project_name VARCHAR,
    contract_value DECIMAL,
    planned_cost DECIMAL,
    actual_cost DECIMAL,
    forecast_cost DECIMAL,
    total_billed DECIMAL,
    planned_margin DECIMAL,
    planned_margin_percent DECIMAL,
    actual_margin DECIMAL,
    actual_margin_percent DECIMAL,
    estimated_margin DECIMAL,
    estimated_margin_percent DECIMAL,
    projected_margin DECIMAL,
    projected_margin_percent DECIMAL,
    earned_revenue DECIMAL,
    unbilled_revenue DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.project_id,
        m.project_name,
        m.contract_value,
        m.planned_cost,
        m.actual_cost,
        m.forecast_cost,
        m.total_billed,
        m.planned_margin,
        m.planned_margin_percent,
        m.actual_margin,
        m.actual_margin_percent,
        m.estimated_margin,
        m.estimated_margin_percent,
        m.projected_margin,
        m.projected_margin_percent,
        m.earned_revenue,
        m.unbilled_revenue
    FROM margin_analysis m
    WHERE m.project_id = p_project_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get margin trend over time
CREATE OR REPLACE FUNCTION get_margin_trend(
    p_project_id UUID,
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '90 days',
    p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    trend_date DATE,
    cumulative_cost DECIMAL,
    cumulative_billing DECIMAL,
    margin_amount DECIMAL,
    margin_percent DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    WITH date_series AS (
        SELECT generate_series(p_start_date, p_end_date, '1 week'::interval)::date as trend_date
    ),
    historical_data AS (
        SELECT 
            ds.trend_date,
            -- Cumulative costs up to date
            COALESCE(SUM(CASE 
                WHEN ct.transaction_date <= ds.trend_date 
                THEN ct.amount 
                ELSE 0 
            END), 0) as cumulative_cost,
            
            -- Cumulative billing up to date
            COALESCE(SUM(CASE 
                WHEN pb.billing_date <= ds.trend_date 
                THEN pb.billing_amount 
                ELSE 0 
            END), 0) as cumulative_billing
            
        FROM date_series ds
        CROSS JOIN projects p
        LEFT JOIN wbs_nodes w ON w.project_id = p.id
        LEFT JOIN activities a ON a.wbs_node_id = w.id
        LEFT JOIN tasks t ON t.activity_id = a.id
        LEFT JOIN cost_objects co ON co.task_id = t.id
        LEFT JOIN cost_transactions ct ON ct.cost_object_id = co.id
        LEFT JOIN project_billing pb ON pb.project_id = p.id
        WHERE p.id = p_project_id
        GROUP BY ds.trend_date
    )
    SELECT 
        h.trend_date,
        h.cumulative_cost,
        h.cumulative_billing,
        h.cumulative_billing - h.cumulative_cost as margin_amount,
        CASE 
            WHEN h.cumulative_billing > 0 
            THEN ((h.cumulative_billing - h.cumulative_cost) / h.cumulative_billing) * 100
            ELSE 0 
        END as margin_percent
    FROM historical_data h
    ORDER BY h.trend_date;
END;
$$ LANGUAGE plpgsql;
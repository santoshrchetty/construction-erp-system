-- Earned Value Management (EVM) Functions
-- =====================================================

-- EVM Calculation View
CREATE OR REPLACE VIEW evm_calculations AS
WITH project_evm AS (
    SELECT 
        p.id as project_id,
        p.name as project_name,
        p.budget as total_budget,
        p.start_date,
        p.planned_end_date,
        CURRENT_DATE as status_date,
        
        -- Planned Value (PV) - Budget allocated to scheduled work
        COALESCE(SUM(CASE 
            WHEN t.planned_start_date <= CURRENT_DATE 
            THEN co.budget_amount * LEAST(
                1.0,
                GREATEST(0, 
                    (CURRENT_DATE - t.planned_start_date) / 
                    NULLIF((t.planned_end_date - t.planned_start_date), 0)
                )
            )
            ELSE 0 
        END), 0) as planned_value,
        
        -- Earned Value (EV) - Budget allocated to completed work
        COALESCE(SUM(co.budget_amount * COALESCE(t.progress_percentage, 0) / 100.0), 0) as earned_value,
        
        -- Actual Cost (AC) - Actual cost of work performed
        COALESCE(SUM(co.actual_amount), 0) as actual_cost,
        
        -- Budget at Completion (BAC)
        COALESCE(SUM(co.budget_amount), p.budget) as budget_at_completion
        
    FROM projects p
    LEFT JOIN wbs_nodes w ON w.project_id = p.id
    LEFT JOIN activities a ON a.wbs_node_id = w.id
    LEFT JOIN tasks t ON t.activity_id = a.id
    LEFT JOIN cost_objects co ON co.task_id = t.id
    WHERE p.status = 'active'
    GROUP BY p.id, p.name, p.budget, p.start_date, p.planned_end_date
)
SELECT 
    *,
    -- Cost Performance Index (CPI) = EV / AC
    CASE 
        WHEN actual_cost > 0 THEN earned_value / actual_cost
        ELSE NULL 
    END as cost_performance_index,
    
    -- Schedule Performance Index (SPI) = EV / PV
    CASE 
        WHEN planned_value > 0 THEN earned_value / planned_value
        ELSE NULL 
    END as schedule_performance_index,
    
    -- Cost Variance (CV) = EV - AC
    earned_value - actual_cost as cost_variance,
    
    -- Schedule Variance (SV) = EV - PV
    earned_value - planned_value as schedule_variance,
    
    -- Estimate to Complete (ETC) = (BAC - EV) / CPI
    CASE 
        WHEN actual_cost > 0 AND earned_value < budget_at_completion 
        THEN (budget_at_completion - earned_value) / (earned_value / actual_cost)
        ELSE budget_at_completion - earned_value
    END as estimate_to_complete,
    
    -- Estimate at Completion (EAC) = AC + ETC
    actual_cost + CASE 
        WHEN actual_cost > 0 AND earned_value < budget_at_completion 
        THEN (budget_at_completion - earned_value) / (earned_value / actual_cost)
        ELSE budget_at_completion - earned_value
    END as estimate_at_completion,
    
    -- Variance at Completion (VAC) = BAC - EAC
    budget_at_completion - (actual_cost + CASE 
        WHEN actual_cost > 0 AND earned_value < budget_at_completion 
        THEN (budget_at_completion - earned_value) / (earned_value / actual_cost)
        ELSE budget_at_completion - earned_value
    END) as variance_at_completion,
    
    -- To Complete Performance Index (TCPI) = (BAC - EV) / (BAC - AC)
    CASE 
        WHEN budget_at_completion - actual_cost > 0 
        THEN (budget_at_completion - earned_value) / (budget_at_completion - actual_cost)
        ELSE NULL
    END as to_complete_performance_index,
    
    -- Percent Complete (Physical)
    CASE 
        WHEN budget_at_completion > 0 THEN earned_value / budget_at_completion * 100
        ELSE 0
    END as percent_complete,
    
    -- Percent Spent
    CASE 
        WHEN budget_at_completion > 0 THEN actual_cost / budget_at_completion * 100
        ELSE 0
    END as percent_spent
    
FROM project_evm;

-- Function to get EVM data for a specific project
CREATE OR REPLACE FUNCTION get_project_evm(p_project_id UUID)
RETURNS TABLE (
    project_id UUID,
    project_name VARCHAR,
    status_date DATE,
    planned_value DECIMAL,
    earned_value DECIMAL,
    actual_cost DECIMAL,
    budget_at_completion DECIMAL,
    cost_performance_index DECIMAL,
    schedule_performance_index DECIMAL,
    cost_variance DECIMAL,
    schedule_variance DECIMAL,
    estimate_to_complete DECIMAL,
    estimate_at_completion DECIMAL,
    variance_at_completion DECIMAL,
    to_complete_performance_index DECIMAL,
    percent_complete DECIMAL,
    percent_spent DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.project_id,
        e.project_name,
        e.status_date,
        e.planned_value,
        e.earned_value,
        e.actual_cost,
        e.budget_at_completion,
        e.cost_performance_index,
        e.schedule_performance_index,
        e.cost_variance,
        e.schedule_variance,
        e.estimate_to_complete,
        e.estimate_at_completion,
        e.variance_at_completion,
        e.to_complete_performance_index,
        e.percent_complete,
        e.percent_spent
    FROM evm_calculations e
    WHERE e.project_id = p_project_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get EVM trend data
CREATE OR REPLACE FUNCTION get_evm_trend(
    p_project_id UUID,
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '90 days',
    p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    trend_date DATE,
    planned_value DECIMAL,
    earned_value DECIMAL,
    actual_cost DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    WITH date_series AS (
        SELECT generate_series(p_start_date, p_end_date, '1 week'::interval)::date as trend_date
    ),
    historical_evm AS (
        SELECT 
            ds.trend_date,
            -- PV calculation for historical dates
            COALESCE(SUM(CASE 
                WHEN t.planned_start_date <= ds.trend_date 
                THEN co.budget_amount * LEAST(
                    1.0,
                    GREATEST(0, 
                        (ds.trend_date - t.planned_start_date) / 
                        NULLIF((t.planned_end_date - t.planned_start_date), 0)
                    )
                )
                ELSE 0 
            END), 0) as pv,
            
            -- EV based on progress at that date (simplified - uses current progress)
            COALESCE(SUM(co.budget_amount * COALESCE(t.progress_percentage, 0) / 100.0), 0) as ev,
            
            -- AC from cost transactions up to that date
            COALESCE(SUM(CASE 
                WHEN ct.transaction_date <= ds.trend_date 
                THEN ct.amount 
                ELSE 0 
            END), 0) as ac
            
        FROM date_series ds
        CROSS JOIN projects p
        LEFT JOIN wbs_nodes w ON w.project_id = p.id
        LEFT JOIN activities a ON a.wbs_node_id = w.id
        LEFT JOIN tasks t ON t.activity_id = a.id
        LEFT JOIN cost_objects co ON co.task_id = t.id
        LEFT JOIN cost_transactions ct ON ct.cost_object_id = co.id
        WHERE p.id = p_project_id
        GROUP BY ds.trend_date
    )
    SELECT 
        h.trend_date,
        h.pv as planned_value,
        h.ev as earned_value,
        h.ac as actual_cost
    FROM historical_evm h
    ORDER BY h.trend_date;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate EVM at task level
CREATE OR REPLACE FUNCTION get_task_evm(p_task_id UUID)
RETURNS TABLE (
    task_id UUID,
    task_name VARCHAR,
    planned_value DECIMAL,
    earned_value DECIMAL,
    actual_cost DECIMAL,
    cost_performance_index DECIMAL,
    schedule_performance_index DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id as task_id,
        t.name as task_name,
        -- PV for this task
        CASE 
            WHEN t.planned_start_date <= CURRENT_DATE 
            THEN co.budget_amount * LEAST(
                1.0,
                GREATEST(0, 
                    (CURRENT_DATE - t.planned_start_date) / 
                    NULLIF((t.planned_end_date - t.planned_start_date), 0)
                )
            )
            ELSE 0 
        END as planned_value,
        
        -- EV for this task
        co.budget_amount * COALESCE(t.progress_percentage, 0) / 100.0 as earned_value,
        
        -- AC for this task
        COALESCE(co.actual_amount, 0) as actual_cost,
        
        -- CPI
        CASE 
            WHEN co.actual_amount > 0 
            THEN (co.budget_amount * COALESCE(t.progress_percentage, 0) / 100.0) / co.actual_amount
            ELSE NULL 
        END as cost_performance_index,
        
        -- SPI
        CASE 
            WHEN t.planned_start_date <= CURRENT_DATE AND 
                 (t.planned_end_date - t.planned_start_date) > 0
            THEN (co.budget_amount * COALESCE(t.progress_percentage, 0) / 100.0) / 
                 (co.budget_amount * LEAST(
                    1.0,
                    GREATEST(0, 
                        (CURRENT_DATE - t.planned_start_date) / 
                        NULLIF(EXTRACT(DAYS FROM t.planned_end_date - t.planned_start_date), 0)
                    )
                ))
            ELSE NULL
        END as schedule_performance_index
        
    FROM tasks t
    LEFT JOIN cost_objects co ON co.task_id = t.id
    WHERE t.id = p_task_id;
END;
$$ LANGUAGE plpgsql;
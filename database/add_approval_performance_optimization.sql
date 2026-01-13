-- Database Indexes and Performance Optimization for Approval System
-- Optimize query performance for approval workflows

-- 1. Indexes for flexible_approval_levels table
CREATE INDEX IF NOT EXISTS idx_flexible_approval_levels_customer_doc 
ON flexible_approval_levels(customer_id, document_type, is_active);

CREATE INDEX IF NOT EXISTS idx_flexible_approval_levels_amount_range 
ON flexible_approval_levels(amount_threshold_min, amount_threshold_max) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_flexible_approval_levels_level_number 
ON flexible_approval_levels(customer_id, document_type, level_number) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_flexible_approval_levels_filters 
ON flexible_approval_levels(category_filter, department_filter) 
WHERE is_active = true;

-- 2. Indexes for approval_executions table
CREATE INDEX IF NOT EXISTS idx_approval_executions_request 
ON approval_executions(request_id, status);

CREATE INDEX IF NOT EXISTS idx_approval_executions_config 
ON approval_executions(config_id, current_level);

CREATE INDEX IF NOT EXISTS idx_approval_executions_status_date 
ON approval_executions(status, started_at);

-- 3. Indexes for approval_steps table
CREATE INDEX IF NOT EXISTS idx_approval_steps_execution_level 
ON approval_steps(execution_id, level_number);

CREATE INDEX IF NOT EXISTS idx_approval_steps_approver_status 
ON approval_steps(approver_id, status, assigned_at);

CREATE INDEX IF NOT EXISTS idx_approval_steps_timeout 
ON approval_steps(timeout_at) 
WHERE status = 'PENDING';

-- 4. Indexes for material_requests table (approval-related)
CREATE INDEX IF NOT EXISTS idx_material_requests_approval_status 
ON material_requests(status, requested_by, created_at);

CREATE INDEX IF NOT EXISTS idx_material_requests_company_type 
ON material_requests(company_code, request_type, status);

-- 5. Indexes for customer configuration tables
CREATE INDEX IF NOT EXISTS idx_customer_approval_config_active 
ON customer_approval_configuration(customer_id, document_type, is_active);

CREATE INDEX IF NOT EXISTS idx_customer_material_request_config_mode 
ON customer_material_request_config(customer_id, request_mode, is_active);

-- 6. Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_approval_path_lookup 
ON flexible_approval_levels(customer_id, document_type, amount_threshold_min, amount_threshold_max, level_number) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_pending_approvals_lookup 
ON approval_steps(approver_id, status, assigned_at, timeout_at) 
WHERE status = 'PENDING';

-- 7. Partial indexes for performance
CREATE INDEX IF NOT EXISTS idx_active_approval_levels 
ON flexible_approval_levels(customer_id, document_type, level_number, approver_role) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_pending_approval_executions 
ON approval_executions(config_id, current_level, started_at) 
WHERE status IN ('PENDING', 'ESCALATED');

-- 8. Performance monitoring views
CREATE OR REPLACE VIEW approval_performance_metrics AS
SELECT 
  ae.config_id,
  cac.customer_id,
  cac.document_type,
  COUNT(*) as total_requests,
  COUNT(CASE WHEN ae.status = 'APPROVED' THEN 1 END) as approved_count,
  COUNT(CASE WHEN ae.status = 'REJECTED' THEN 1 END) as rejected_count,
  COUNT(CASE WHEN ae.status = 'PENDING' THEN 1 END) as pending_count,
  AVG(EXTRACT(EPOCH FROM (ae.completed_at - ae.started_at))/3600) as avg_approval_hours,
  MAX(EXTRACT(EPOCH FROM (ae.completed_at - ae.started_at))/3600) as max_approval_hours,
  MIN(EXTRACT(EPOCH FROM (ae.completed_at - ae.started_at))/3600) as min_approval_hours
FROM approval_executions ae
JOIN customer_approval_configuration cac ON ae.config_id = cac.id
WHERE ae.started_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ae.config_id, cac.customer_id, cac.document_type;

-- 9. Approval bottleneck analysis view
CREATE OR REPLACE VIEW approval_bottleneck_analysis AS
SELECT 
  fal.customer_id,
  fal.document_type,
  fal.level_number,
  fal.level_name,
  fal.approver_role,
  COUNT(ast.id) as total_approvals,
  COUNT(CASE WHEN ast.status = 'PENDING' THEN 1 END) as pending_count,
  AVG(EXTRACT(EPOCH FROM (COALESCE(ast.responded_at, NOW()) - ast.assigned_at))/3600) as avg_response_hours,
  COUNT(CASE WHEN ast.timeout_at < NOW() AND ast.status = 'PENDING' THEN 1 END) as overdue_count
FROM flexible_approval_levels fal
LEFT JOIN approval_steps ast ON fal.level_number = ast.level_number
WHERE fal.is_active = true
  AND ast.assigned_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY fal.customer_id, fal.document_type, fal.level_number, fal.level_name, fal.approver_role
ORDER BY avg_response_hours DESC;

-- 10. Optimization functions
CREATE OR REPLACE FUNCTION optimize_approval_performance()
RETURNS TEXT AS $$
BEGIN
  -- Update table statistics
  ANALYZE flexible_approval_levels;
  ANALYZE approval_executions;
  ANALYZE approval_steps;
  ANALYZE material_requests;
  ANALYZE customer_approval_configuration;
  
  -- Clean up old completed approval executions (older than 1 year)
  DELETE FROM approval_steps 
  WHERE execution_id IN (
    SELECT id FROM approval_executions 
    WHERE status IN ('APPROVED', 'REJECTED') 
    AND completed_at < CURRENT_DATE - INTERVAL '1 year'
  );
  
  DELETE FROM approval_executions 
  WHERE status IN ('APPROVED', 'REJECTED') 
  AND completed_at < CURRENT_DATE - INTERVAL '1 year';
  
  RETURN 'Approval system performance optimized';
END;
$$ LANGUAGE plpgsql;

-- 11. Query performance test
CREATE OR REPLACE FUNCTION test_approval_query_performance()
RETURNS TABLE (
  test_name TEXT,
  execution_time_ms NUMERIC,
  rows_returned BIGINT
) AS $$
DECLARE
  start_time TIMESTAMP;
  end_time TIMESTAMP;
  row_count BIGINT;
BEGIN
  -- Test 1: Get approval path
  start_time := clock_timestamp();
  SELECT COUNT(*) INTO row_count FROM get_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    15000
  );
  end_time := clock_timestamp();
  
  RETURN QUERY SELECT 
    'Get Approval Path'::TEXT,
    EXTRACT(MILLISECONDS FROM (end_time - start_time)),
    row_count;
  
  -- Test 2: Pending approvals lookup
  start_time := clock_timestamp();
  SELECT COUNT(*) INTO row_count FROM approval_steps 
  WHERE approver_id = '550e8400-e29b-41d4-a716-446655440001' 
  AND status = 'PENDING';
  end_time := clock_timestamp();
  
  RETURN QUERY SELECT 
    'Pending Approvals Lookup'::TEXT,
    EXTRACT(MILLISECONDS FROM (end_time - start_time)),
    row_count;
  
  -- Test 3: Customer approval levels
  start_time := clock_timestamp();
  SELECT COUNT(*) INTO row_count FROM flexible_approval_levels 
  WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001' 
  AND document_type = 'MATERIAL_REQ' 
  AND is_active = true;
  end_time := clock_timestamp();
  
  RETURN QUERY SELECT 
    'Customer Approval Levels'::TEXT,
    EXTRACT(MILLISECONDS FROM (end_time - start_time)),
    row_count;
END;
$$ LANGUAGE plpgsql;

-- 12. Maintenance procedures
CREATE OR REPLACE FUNCTION maintain_approval_system()
RETURNS TEXT AS $$
BEGIN
  -- Archive old approval data
  INSERT INTO approval_executions_archive 
  SELECT * FROM approval_executions 
  WHERE completed_at < CURRENT_DATE - INTERVAL '2 years'
  AND status IN ('APPROVED', 'REJECTED');
  
  -- Clean up expired delegations
  UPDATE approval_steps 
  SET delegation_to = NULL 
  WHERE delegation_to IS NOT NULL 
  AND assigned_at < CURRENT_DATE - INTERVAL '30 days';
  
  -- Update approval performance statistics
  REFRESH MATERIALIZED VIEW IF EXISTS approval_performance_summary;
  
  RETURN 'Approval system maintenance completed';
END;
$$ LANGUAGE plpgsql;

-- Create archive table for old approval data
CREATE TABLE IF NOT EXISTS approval_executions_archive (
  LIKE approval_executions INCLUDING ALL
);

-- Schedule maintenance (example - adjust based on your scheduler)
-- SELECT cron.schedule('approval-maintenance', '0 2 * * 0', 'SELECT maintain_approval_system();');

-- Performance monitoring
SELECT 'PERFORMANCE OPTIMIZATION COMPLETE' as status;
SELECT 'Run: SELECT * FROM test_approval_query_performance();' as next_step;

COMMENT ON FUNCTION optimize_approval_performance IS 'Optimize approval system performance by updating statistics and cleaning old data';
COMMENT ON FUNCTION test_approval_query_performance IS 'Test query performance for key approval system operations';
COMMENT ON VIEW approval_performance_metrics IS 'Performance metrics for approval workflows over the last 30 days';
COMMENT ON VIEW approval_bottleneck_analysis IS 'Identify bottlenecks in approval workflows';
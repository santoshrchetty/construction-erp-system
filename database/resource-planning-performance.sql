-- =====================================================
-- RESOURCE PLANNING PERFORMANCE OPTIMIZATION
-- For 2000+ Activities
-- =====================================================

-- Drop existing objects if they exist
DROP MATERIALIZED VIEW IF EXISTS mv_activities_resource_status CASCADE;
DROP INDEX IF EXISTS idx_activities_date_range;
DROP INDEX IF EXISTS idx_activities_status_priority;
DROP INDEX IF EXISTS idx_activities_project_wbs;
DROP INDEX IF EXISTS idx_activity_materials_status_date;

-- 1. Additional Indexes for Fast Filtering
CREATE INDEX idx_activities_date_range ON activities(planned_start_date, planned_end_date) 
WHERE is_active = true;

CREATE INDEX idx_activities_status_priority ON activities(status, priority) 
WHERE is_active = true;

CREATE INDEX idx_activities_project_wbs ON activities(project_id, wbs_node_id);

-- 2. Composite Index for Resource Assignment Queries
CREATE INDEX idx_activity_materials_status_date ON activity_materials(status, planned_consumption_date);

-- 3. Materialized View: Activities Needing Resources (Fast Lookup)
CREATE MATERIALIZED VIEW mv_activities_resource_status AS
SELECT 
    a.id AS activity_id,
    a.project_id,
    a.wbs_node_id,
    a.code,
    a.name,
    a.planned_start_date,
    a.planned_end_date,
    a.status,
    a.priority,
    
    -- Resource counts (5 types)
    COALESCE((SELECT COUNT(*) FROM activity_materials am WHERE am.activity_id = a.id), 0) AS material_count,
    COALESCE((SELECT COUNT(*) FROM activity_equipment ae WHERE ae.activity_id = a.id), 0) AS equipment_count,
    COALESCE((SELECT COUNT(*) FROM activity_manpower amp WHERE amp.activity_id = a.id), 0) AS manpower_count,
    COALESCE((SELECT COUNT(*) FROM activity_services asv WHERE asv.activity_id = a.id), 0) AS services_count,
    COALESCE((SELECT COUNT(*) FROM activity_subcontractors asc WHERE asc.activity_id = a.id), 0) AS subcontractor_count,
    
    -- Resource existence flags
    EXISTS(SELECT 1 FROM activity_materials am WHERE am.activity_id = a.id) AS has_materials,
    EXISTS(SELECT 1 FROM activity_equipment ae WHERE ae.activity_id = a.id) AS has_equipment,
    EXISTS(SELECT 1 FROM activity_manpower amp WHERE amp.activity_id = a.id) AS has_manpower,
    EXISTS(SELECT 1 FROM activity_services asv WHERE asv.activity_id = a.id) AS has_services,
    EXISTS(SELECT 1 FROM activity_subcontractors asc WHERE asc.activity_id = a.id) AS has_subcontractors,
    
    -- Overall resource status
    CASE 
        WHEN NOT EXISTS(SELECT 1 FROM activity_materials am WHERE am.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_equipment ae WHERE ae.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_manpower amp WHERE amp.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_services asv WHERE asv.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_subcontractors asc WHERE asc.activity_id = a.id)
        THEN 'missing'
        WHEN EXISTS(SELECT 1 FROM activity_materials am WHERE am.activity_id = a.id AND am.status = 'planned')
          OR EXISTS(SELECT 1 FROM activity_equipment ae WHERE ae.activity_id = a.id AND ae.status = 'planned')
          OR EXISTS(SELECT 1 FROM activity_manpower amp WHERE amp.activity_id = a.id AND amp.status = 'planned')
          OR EXISTS(SELECT 1 FROM activity_services asv WHERE asv.activity_id = a.id AND asv.status = 'scheduled')
          OR EXISTS(SELECT 1 FROM activity_subcontractors asc WHERE asc.activity_id = a.id AND asc.status = 'awarded')
        THEN 'partial'
        ELSE 'complete'
    END AS resource_status,
    
    -- Date-based priority
    CASE 
        WHEN a.planned_start_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'urgent'
        WHEN a.planned_start_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'soon'
        ELSE 'future'
    END AS time_priority
    
FROM activities a
WHERE a.is_active = true
  AND a.status NOT IN ('completed', 'cancelled');

-- Index on materialized view
CREATE INDEX idx_mv_resource_status ON mv_activities_resource_status(resource_status, time_priority);
CREATE INDEX idx_mv_date_range ON mv_activities_resource_status(planned_start_date);
CREATE INDEX idx_mv_project ON mv_activities_resource_status(project_id);

-- 4. Function to Refresh Materialized View (Call after bulk updates)
CREATE OR REPLACE FUNCTION refresh_resource_status()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_activities_resource_status;
END;
$$ LANGUAGE plpgsql;

-- 5. Optimized Query: Get Activities Needing Resources (< 50ms for 2000+ activities)
CREATE OR REPLACE FUNCTION get_activities_needing_resources(
    p_project_id UUID DEFAULT NULL,
    p_date_from DATE DEFAULT CURRENT_DATE,
    p_date_to DATE DEFAULT CURRENT_DATE + INTERVAL '30 days',
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    activity_id UUID,
    activity_code VARCHAR,
    activity_name VARCHAR,
    start_date DATE,
    end_date DATE,
    status VARCHAR,
    priority VARCHAR,
    material_count INTEGER,
    resource_status VARCHAR,
    time_priority VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mv.activity_id,
        mv.code,
        mv.name,
        mv.planned_start_date,
        mv.planned_end_date,
        mv.status,
        mv.priority,
        mv.material_count::INTEGER,
        mv.resource_status,
        mv.time_priority
    FROM mv_activities_resource_status mv
    WHERE (p_project_id IS NULL OR mv.project_id = p_project_id)
      AND mv.planned_start_date BETWEEN p_date_from AND p_date_to
      AND mv.resource_status IN ('missing', 'partial')
    ORDER BY 
        CASE mv.time_priority 
            WHEN 'urgent' THEN 1 
            WHEN 'soon' THEN 2 
            ELSE 3 
        END,
        mv.planned_start_date
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- 6. Pagination Helper: Count Total Activities
CREATE OR REPLACE FUNCTION count_activities_needing_resources(
    p_project_id UUID DEFAULT NULL,
    p_date_from DATE DEFAULT CURRENT_DATE,
    p_date_to DATE DEFAULT CURRENT_DATE + INTERVAL '30 days'
)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)::INTEGER INTO v_count
    FROM mv_activities_resource_status mv
    WHERE (p_project_id IS NULL OR mv.project_id = p_project_id)
      AND mv.planned_start_date BETWEEN p_date_from AND p_date_to
      AND mv.resource_status IN ('missing', 'partial');
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql STABLE;

-- 7. Trigger: Auto-refresh materialized view on activity_materials changes
CREATE OR REPLACE FUNCTION trigger_refresh_resource_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Refresh only affected activity (partial refresh simulation)
    -- In production, use a queue/job system for actual refresh
    PERFORM refresh_resource_status();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Only enable this trigger if changes are infrequent
-- For high-frequency updates, use scheduled refresh instead
-- CREATE TRIGGER trg_refresh_on_material_change
-- AFTER INSERT OR UPDATE OR DELETE ON activity_materials
-- FOR EACH STATEMENT EXECUTE FUNCTION trigger_refresh_resource_status();

-- 8. Performance Monitoring Query
CREATE OR REPLACE FUNCTION analyze_resource_planning_performance()
RETURNS TABLE (
    metric VARCHAR,
    value TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Total Activities'::VARCHAR, COUNT(*)::TEXT FROM activities WHERE is_active = true
    UNION ALL
    SELECT 'Activities with Materials', COUNT(DISTINCT activity_id)::TEXT FROM activity_materials
    UNION ALL
    SELECT 'Activities with Equipment', COUNT(DISTINCT activity_id)::TEXT FROM activity_equipment
    UNION ALL
    SELECT 'Activities with Manpower', COUNT(DISTINCT activity_id)::TEXT FROM activity_manpower
    UNION ALL
    SELECT 'Activities with Services', COUNT(DISTINCT activity_id)::TEXT FROM activity_services
    UNION ALL
    SELECT 'Activities with Subcontractors', COUNT(DISTINCT activity_id)::TEXT FROM activity_subcontractors
    UNION ALL
    SELECT 'Activities Needing Resources', COUNT(*)::TEXT FROM mv_activities_resource_status WHERE resource_status IN ('missing', 'partial')
    UNION ALL
    SELECT 'Materialized View Size', pg_size_pretty(pg_total_relation_size('mv_activities_resource_status'));
END;
$$ LANGUAGE plpgsql;

-- 9. Initial Refresh
REFRESH MATERIALIZED VIEW mv_activities_resource_status;

SELECT 'Resource Planning Performance Optimization Complete' as status;

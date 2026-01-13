-- PERFORMANCE OPTIMIZATION - Approval Configuration
-- Database-level optimizations for enterprise-scale performance

-- Step 1: Enhanced indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_approval_policies_customer_active 
ON approval_policies (customer_id, is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_approval_policies_object_lookup 
ON approval_policies (customer_id, approval_object_type, approval_object_document_type, is_active) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_field_definitions_customer_active 
ON approval_field_definitions (customer_id, is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_field_options_definition_active 
ON approval_field_options (field_definition_id, is_active) WHERE is_active = true;

-- Step 2: JSONB indexes for context field queries
CREATE INDEX IF NOT EXISTS idx_policies_countries_gin 
ON approval_policies USING GIN (selected_countries) WHERE selected_countries IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_policies_departments_gin 
ON approval_policies USING GIN (selected_departments) WHERE selected_departments IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_policies_plants_gin 
ON approval_policies USING GIN (selected_plants) WHERE selected_plants IS NOT NULL;

-- Step 3: Materialized view for field definitions with options (cached lookup)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_approval_field_cache AS
SELECT 
    fd.id,
    fd.customer_id,
    fd.field_name,
    fd.field_label,
    fd.field_type,
    fd.field_category,
    fd.display_order,
    COALESCE(
        json_agg(
            json_build_object(
                'option_value', fo.option_value,
                'option_label', fo.option_label,
                'option_description', fo.option_description,
                'display_order', fo.display_order
            ) ORDER BY fo.display_order
        ) FILTER (WHERE fo.id IS NOT NULL), 
        '[]'::json
    ) as approval_field_options
FROM approval_field_definitions fd
LEFT JOIN approval_field_options fo ON fd.id = fo.field_definition_id AND fo.is_active = true
WHERE fd.is_active = true
GROUP BY fd.id, fd.customer_id, fd.field_name, fd.field_label, fd.field_type, fd.field_category, fd.display_order
ORDER BY fd.display_order;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_field_cache_customer_field 
ON mv_approval_field_cache (customer_id, field_name);

-- Step 4: Function for fast policy lookup with context scoring
CREATE OR REPLACE FUNCTION get_matching_policies(
    p_customer_id UUID,
    p_object_type VARCHAR(20),
    p_document_type VARCHAR(10) DEFAULT NULL,
    p_country VARCHAR(3) DEFAULT NULL,
    p_department VARCHAR(20) DEFAULT NULL,
    p_plant VARCHAR(20) DEFAULT NULL
) RETURNS TABLE (
    policy_id UUID,
    policy_name VARCHAR(100),
    match_score INTEGER,
    context_specificity INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ap.id,
        ap.policy_name,
        -- Context matching score
        CASE 
            WHEN ap.selected_countries IS NULL THEN 12
            WHEN ap.selected_countries ? p_country THEN 120
            ELSE -60
        END +
        CASE 
            WHEN ap.selected_departments IS NULL THEN 10
            WHEN ap.selected_departments ? p_department THEN 100
            ELSE -50
        END +
        CASE 
            WHEN ap.selected_plants IS NULL THEN 8
            WHEN ap.selected_plants ? p_plant THEN 80
            ELSE -40
        END AS match_score,
        ap.context_specificity
    FROM approval_policies ap
    WHERE ap.customer_id = p_customer_id
      AND ap.approval_object_type = p_object_type
      AND (p_document_type IS NULL OR ap.approval_object_document_type = p_document_type)
      AND ap.is_active = true
    ORDER BY match_score DESC, context_specificity DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql STABLE;

-- Step 5: Refresh function for materialized view
CREATE OR REPLACE FUNCTION refresh_approval_field_cache(p_customer_id UUID DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    IF p_customer_id IS NOT NULL THEN
        -- Partial refresh for specific customer (PostgreSQL doesn't support this natively)
        -- So we refresh the entire view
        REFRESH MATERIALIZED VIEW mv_approval_field_cache;
    ELSE
        REFRESH MATERIALIZED VIEW mv_approval_field_cache;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Step 6: Trigger to auto-refresh cache on data changes
CREATE OR REPLACE FUNCTION trigger_refresh_field_cache()
RETURNS TRIGGER AS $$
BEGIN
    -- Refresh cache asynchronously (in production, use a job queue)
    PERFORM refresh_approval_field_cache();
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_field_definitions_cache ON approval_field_definitions;
CREATE TRIGGER tr_field_definitions_cache
    AFTER INSERT OR UPDATE OR DELETE ON approval_field_definitions
    FOR EACH STATEMENT EXECUTE FUNCTION trigger_refresh_field_cache();

DROP TRIGGER IF EXISTS tr_field_options_cache ON approval_field_options;
CREATE TRIGGER tr_field_options_cache
    AFTER INSERT OR UPDATE OR DELETE ON approval_field_options
    FOR EACH STATEMENT EXECUTE FUNCTION trigger_refresh_field_cache();

-- Step 7: Enhanced policy listing function with document type filtering
CREATE OR REPLACE FUNCTION get_approval_policies_paginated(
    p_customer_id UUID,
    p_object_type VARCHAR(20) DEFAULT NULL,
    p_document_type VARCHAR(10) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    policy_name VARCHAR(100),
    approval_object_type VARCHAR(20),
    approval_object_document_type VARCHAR(10),
    object_category VARCHAR(30),
    approval_strategy VARCHAR(20),
    selected_countries JSONB,
    selected_departments JSONB,
    selected_plants JSONB,
    selected_storage_locations JSONB,
    selected_purchase_orgs JSONB,
    selected_projects JSONB,
    context_specificity INTEGER,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ap.id,
        ap.policy_name,
        ap.approval_object_type,
        ap.approval_object_document_type,
        ap.object_category,
        ap.approval_strategy,
        ap.selected_countries,
        ap.selected_departments,
        ap.selected_plants,
        ap.selected_storage_locations,
        ap.selected_purchase_orgs,
        ap.selected_projects,
        ap.context_specificity,
        ap.is_active,
        ap.created_at
    FROM approval_policies ap
    WHERE ap.customer_id = p_customer_id
      AND (p_object_type IS NULL OR ap.approval_object_type = p_object_type)
      AND (p_document_type IS NULL OR ap.approval_object_document_type = p_document_type)
      AND ap.is_active = true
    ORDER BY ap.context_specificity DESC, ap.policy_name
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- Step 8: Statistics and performance monitoring
CREATE OR REPLACE VIEW v_approval_performance_stats AS
SELECT 
    'approval_policies' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE is_active = true) as active_rows,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(DISTINCT approval_object_type) as object_types,
    AVG(context_specificity) as avg_specificity
FROM approval_policies
UNION ALL
SELECT 
    'approval_field_definitions' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE is_active = true) as active_rows,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(DISTINCT field_category) as categories,
    AVG(display_order) as avg_order
FROM approval_field_definitions
UNION ALL
SELECT 
    'approval_field_options' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) FILTER (WHERE is_active = true) as active_rows,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(DISTINCT field_definition_id) as field_definitions,
    AVG(display_order) as avg_order
FROM approval_field_options;

-- Step 9: Initial cache refresh
SELECT refresh_approval_field_cache();

-- Step 10: Performance verification
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM get_approval_policies_paginated('550e8400-e29b-41d4-a716-446655440001', 'PO', 20, 0);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM get_matching_policies('550e8400-e29b-41d4-a716-446655440001', 'PO', 'NB', 'USA', 'SAFETY', 'PLANT_NYC');

-- Performance summary
SELECT 'Performance Optimization Complete' as status,
       'Indexes: 7, Functions: 3, Materialized Views: 1, Triggers: 2' as components;
-- ========================================
-- TENANT-WISE ISOLATION IMPLEMENTATION
-- ========================================

-- Step 1: Create tenants table
CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_code VARCHAR(10) UNIQUE NOT NULL,
    tenant_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Step 2: Add tenant_id to company_codes table
ALTER TABLE company_codes 
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id);

-- Step 3: Add tenant_id to all core tables
ALTER TABLE document_number_ranges 
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id);

ALTER TABLE document_type_config 
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id);

ALTER TABLE number_range_audit_log 
ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id);

-- Step 4: Create tenant-aware indexes
CREATE INDEX IF NOT EXISTS idx_company_codes_tenant 
ON company_codes(tenant_id, company_code) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_doc_ranges_tenant 
ON document_number_ranges(tenant_id, company_code, document_type) WHERE status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS idx_doc_config_tenant 
ON document_type_config(tenant_id, company_code, base_document_type) WHERE is_active = true;

-- Step 5: Create tenant-aware RLS policies
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_number_ranges ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_type_config ENABLE ROW LEVEL SECURITY;

-- Step 6: Update get_next_number function with tenant isolation
CREATE OR REPLACE FUNCTION get_next_number_tenant_safe(
    p_tenant_id UUID,
    p_company_code VARCHAR,
    p_document_type VARCHAR,
    p_fiscal_year VARCHAR DEFAULT NULL
) RETURNS VARCHAR AS $$
DECLARE
    v_number_range_group VARCHAR;
    v_fiscal_year VARCHAR;
BEGIN
    -- Validate tenant and company
    IF NOT EXISTS (
        SELECT 1 FROM company_codes 
        WHERE tenant_id = p_tenant_id 
        AND company_code = p_company_code 
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Invalid tenant-company combination: % - %', p_tenant_id, p_company_code;
    END IF;
    
    -- Get fiscal year
    v_fiscal_year := COALESCE(p_fiscal_year, get_fiscal_year(CURRENT_DATE)::VARCHAR);
    
    -- Get number range group
    SELECT number_range_group INTO v_number_range_group
    FROM document_type_config
    WHERE tenant_id = p_tenant_id
      AND company_code = p_company_code
      AND base_document_type = p_document_type
      AND is_active = true
    ORDER BY display_order
    LIMIT 1;
    
    v_number_range_group := COALESCE(v_number_range_group, '01');
    
    -- Call tenant-aware numbering function
    RETURN get_next_number_by_group_tenant_safe(
        p_tenant_id,
        p_company_code,
        p_document_type,
        v_number_range_group,
        v_fiscal_year
    );
END;
$$ LANGUAGE plpgsql;

-- Step 7: Create tenant-aware numbering function
CREATE OR REPLACE FUNCTION get_next_number_by_group_tenant_safe(
    p_tenant_id UUID,
    p_company_code VARCHAR,
    p_document_type VARCHAR,
    p_number_range_group VARCHAR,
    p_fiscal_year VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
    v_next_number BIGINT;
    v_prefix VARCHAR;
    v_number_length INTEGER;
    v_result VARCHAR;
BEGIN
    -- Get next number with tenant isolation
    UPDATE document_number_ranges
    SET current_number = current_number + interval_size,
        last_used_date = NOW()
    WHERE tenant_id = p_tenant_id
      AND company_code = p_company_code
      AND document_type = p_document_type
      AND number_range_group = p_number_range_group
      AND (NOT year_dependent OR fiscal_year::VARCHAR = p_fiscal_year)
      AND status = 'ACTIVE'
      AND current_number < to_number
    RETURNING current_number, prefix INTO v_next_number, v_prefix;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No available number range for tenant % company % type %', 
            p_tenant_id, p_company_code, p_document_type;
    END IF;
    
    -- Get number length
    SELECT number_length INTO v_number_length
    FROM document_type_config
    WHERE tenant_id = p_tenant_id
      AND company_code = p_company_code
      AND base_document_type = p_document_type
    LIMIT 1;
    
    v_number_length := COALESCE(v_number_length, 6);
    v_result := v_prefix || LPAD(v_next_number::VARCHAR, v_number_length, '0');
    
    -- Log with tenant info
    INSERT INTO number_range_audit_log (
        tenant_id, company_code, document_type, number_range_group,
        action, new_value, timestamp
    ) VALUES (
        p_tenant_id, p_company_code, p_document_type, p_number_range_group,
        'GENERATED', v_next_number, NOW()
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Step 8: Create tenant management functions
CREATE OR REPLACE FUNCTION create_tenant(
    p_tenant_code VARCHAR,
    p_tenant_name VARCHAR
) RETURNS UUID AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    INSERT INTO tenants (tenant_code, tenant_name)
    VALUES (p_tenant_code, p_tenant_name)
    RETURNING id INTO v_tenant_id;
    
    RETURN v_tenant_id;
END;
$$ LANGUAGE plpgsql;

-- Step 9: Grant permissions
GRANT EXECUTE ON FUNCTION get_next_number_tenant_safe TO PUBLIC;
GRANT EXECUTE ON FUNCTION get_next_number_by_group_tenant_safe TO PUBLIC;
GRANT EXECUTE ON FUNCTION create_tenant TO PUBLIC;

SELECT 'Tenant isolation implemented successfully!' as status;
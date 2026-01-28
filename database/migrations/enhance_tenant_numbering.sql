-- ========================================
-- ENHANCE: Multi-Tenant Numbering Support
-- ========================================

-- Add tenant support to get_next_number function
CREATE OR REPLACE FUNCTION get_next_number_with_tenant(
    p_tenant_id VARCHAR,
    p_company_code VARCHAR,
    p_document_type VARCHAR,
    p_fiscal_year VARCHAR DEFAULT NULL
) RETURNS VARCHAR AS $$
BEGIN
    -- Validate company belongs to tenant
    IF NOT EXISTS (
        SELECT 1 FROM company_codes 
        WHERE company_code = p_company_code 
        AND tenant_id = p_tenant_id
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Company % not found in tenant %', p_company_code, p_tenant_id;
    END IF;
    
    -- Use existing function for numbering
    RETURN get_next_number(p_company_code, p_document_type, p_fiscal_year);
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_next_number_with_tenant TO PUBLIC;

-- Add document type configurations for MR/PR workflow
INSERT INTO document_type_config (
    company_code, 
    base_document_type, 
    number_range_group, 
    is_active, 
    display_order
) VALUES 
    ('*', 'MATERIAL_REQUEST', '01', true, 1),
    ('*', 'PURCHASE_REQ', '01', true, 1),
    ('*', 'STOCK_RESERVATION', '01', true, 1)
ON CONFLICT (company_code, base_document_type, number_range_group) 
DO UPDATE SET is_active = true;

SELECT 'Multi-tenant numbering enhanced successfully!' as status;
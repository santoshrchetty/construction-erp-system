-- ========================================
-- FIX: CREATE MISSING get_next_number FUNCTION
-- ========================================

-- Create the wrapper function that the repository expects
CREATE OR REPLACE FUNCTION get_next_number(
    p_company_code VARCHAR,
    p_document_type VARCHAR,
    p_fiscal_year VARCHAR DEFAULT NULL
) RETURNS VARCHAR AS $$
DECLARE
    v_number_range_group VARCHAR;
    v_fiscal_year VARCHAR;
BEGIN
    -- Get current fiscal year if not provided
    IF p_fiscal_year IS NULL THEN
        v_fiscal_year := get_fiscal_year(CURRENT_DATE)::VARCHAR;
    ELSE
        v_fiscal_year := p_fiscal_year;
    END IF;
    
    -- Get the default number range group (usually '01' for standard)
    SELECT number_range_group INTO v_number_range_group
    FROM document_type_config
    WHERE company_code = p_company_code
      AND base_document_type = p_document_type
      AND is_active = true
    ORDER BY display_order
    LIMIT 1;
    
    -- If no config found, default to '01'
    v_number_range_group := COALESCE(v_number_range_group, '01');
    
    -- Call the main function
    RETURN get_next_number_by_group(
        p_company_code,
        p_document_type,
        v_number_range_group,
        v_fiscal_year
    );
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_next_number TO PUBLIC;

SELECT 'get_next_number function created successfully!' as status;
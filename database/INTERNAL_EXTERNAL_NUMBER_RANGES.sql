-- Internal vs External Number Range Configuration
-- Complete setup for both numbering approaches

-- Internal Numbering Ranges (System-Controlled)
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object,
    from_number, to_number, current_number,
    status, external_numbering, fiscal_year,
    fiscal_year_variant, year_dependent,
    warning_threshold, critical_threshold,
    buffer_size, number_range_group
) 
SELECT * FROM (
    VALUES
    -- INTERNAL: Financial Documents (System assigns sequential numbers)
    ('C001', 'SA', 'RF_BELEG', 2024100000000, 2024199999999, 2024100000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 100, '01'),
    ('C001', 'AB', 'RF_BELEG', 2024200000000, 2024299999999, 2024200000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 100, '01'),
    ('C001', 'DZ', 'RF_BELEG', 2024500000000, 2024599999999, 2024500000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 50, '01'),
    
    -- INTERNAL: Material Documents (System assigns sequential numbers)
    ('C001', 'WE', 'M_MBLNR', 2024600000000, 2024699999999, 2024600000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 200, '21'),
    ('C001', 'WA', 'M_MBLNR', 2024700000000, 2024799999999, 2024700000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 200, '21'),
    ('C001', 'WL', 'M_MBLNR', 2024800000000, 2024899999999, 2024800000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 100, '21'),
    
    -- INTERNAL: Controlling Documents (System assigns sequential numbers)
    ('C001', 'CO', 'RK_BELEG', 2024900000000, 2024999999999, 2024900000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 50, '10'),
    ('C001', 'IO', 'CO_AUFNR', 2024000100000, 2024000199999, 2024000100000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 10, '10'),
    
    -- INTERNAL: Purchase Requisitions (System assigns sequential numbers)
    ('C001', 'NB', 'M_BANFN', 2024300000000, 2024399999999, 2024300000000, 'ACTIVE', false, 2024, 'K4', true, 80, 95, 50, '20')
) AS v(company_code, document_type, number_range_object, from_number, to_number, current_number, status, external_numbering, fiscal_year, fiscal_year_variant, year_dependent, warning_threshold, critical_threshold, buffer_size, number_range_group)
WHERE NOT EXISTS (
    SELECT 1 FROM document_number_ranges d 
    WHERE d.company_code = v.company_code 
    AND d.document_type = v.document_type 
    AND d.fiscal_year = v.fiscal_year
);

-- External Numbering Ranges (User-Controlled)
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object,
    from_number, to_number, current_number,
    status, external_numbering, fiscal_year,
    fiscal_year_variant, year_dependent,
    warning_threshold, critical_threshold,
    buffer_size, number_range_group
) 
SELECT * FROM (
    VALUES
    -- EXTERNAL: Vendor/Customer Invoices (User enters vendor invoice numbers)
    ('C001', 'KR', 'RF_BELEG', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '01'),
    ('C001', 'DR', 'RF_BELEG', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '01'),
    
    -- EXTERNAL: Purchase Orders (User enters business reference numbers)
    ('C001', 'F1', 'M_EBELN', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '20'),
    ('C001', 'F2', 'M_EBELN', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '20'),
    
    -- EXTERNAL: Project Documents (User enters project codes)
    ('C001', 'PR', 'PS_PSPNR', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '30'),
    ('C001', 'WO', 'CO_AUFNR', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '30'),
    ('C001', 'SC', 'M_EBELN', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '30'),
    
    -- EXTERNAL: RFQ Documents (User enters RFQ reference numbers)
    ('C001', 'AN', 'M_ANFNR', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '20'),
    
    -- EXTERNAL: Sales Documents (User enters customer reference numbers)
    ('C001', 'OR', 'SD_VBELN', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '40'),
    ('C001', 'QT', 'SD_VBELN', 0, 9999999999, 0, 'ACTIVE', true, 2024, 'K4', true, 80, 95, 0, '40')
) AS v(company_code, document_type, number_range_object, from_number, to_number, current_number, status, external_numbering, fiscal_year, fiscal_year_variant, year_dependent, warning_threshold, critical_threshold, buffer_size, number_range_group)
WHERE NOT EXISTS (
    SELECT 1 FROM document_number_ranges d 
    WHERE d.company_code = v.company_code 
    AND d.document_type = v.document_type 
    AND d.fiscal_year = v.fiscal_year
);

-- Create validation function for external numbering
CREATE OR REPLACE FUNCTION validate_external_number(
    p_company_code VARCHAR(4),
    p_document_type VARCHAR(2),
    p_fiscal_year INTEGER,
    p_document_number VARCHAR(20)
) RETURNS BOOLEAN AS $$
DECLARE
    v_range_config RECORD;
    v_exists BOOLEAN;
BEGIN
    -- Get number range configuration
    SELECT * INTO v_range_config
    FROM document_number_ranges
    WHERE company_code = p_company_code
    AND document_type = p_document_type
    AND fiscal_year = p_fiscal_year
    AND external_numbering = true;
    
    IF NOT FOUND THEN
        RETURN false; -- No external numbering configured
    END IF;
    
    -- Check if number already exists
    SELECT EXISTS(
        SELECT 1 FROM number_range_usage_history
        WHERE company_code = p_company_code
        AND document_type = p_document_type
        AND document_number = p_document_number
    ) INTO v_exists;
    
    RETURN NOT v_exists; -- Return true if number doesn't exist
END;
$$ LANGUAGE plpgsql;

-- Create function to register external number usage
CREATE OR REPLACE FUNCTION register_external_number(
    p_company_code VARCHAR(4),
    p_document_type VARCHAR(2),
    p_document_number VARCHAR(20),
    p_user_id UUID,
    p_document_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO number_range_usage_history (
        company_code, document_type, document_number,
        used_by, document_id, used_at
    ) VALUES (
        p_company_code, p_document_type, p_document_number,
        p_user_id, p_document_id, NOW()
    );
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

SELECT 'Internal/External Number Range Configuration Complete' as status;
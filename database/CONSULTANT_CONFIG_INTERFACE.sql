-- CONSULTANT CONFIGURATION INTERFACE
-- Module and Object-wise Number Range Configuration

-- Create configuration templates table
CREATE TABLE IF NOT EXISTS number_range_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name VARCHAR(50) NOT NULL,
    module_code VARCHAR(10) NOT NULL,
    object_type VARCHAR(20) NOT NULL,
    default_from_number BIGINT,
    default_to_number BIGINT,
    default_buffer_size INTEGER,
    default_warning_threshold INTEGER,
    default_critical_threshold INTEGER,
    default_external_numbering BOOLEAN,
    default_year_dependent BOOLEAN,
    recommended_prefix VARCHAR(10),
    recommended_suffix VARCHAR(10),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert configuration templates for consultants
INSERT INTO number_range_templates (
    template_name, module_code, object_type,
    default_from_number, default_to_number,
    default_buffer_size, default_warning_threshold, default_critical_threshold,
    default_external_numbering, default_year_dependent,
    recommended_prefix, recommended_suffix, description
) VALUES
-- Financial Accounting Templates
('FI High Volume', 'FI', 'RF_BELEG', 1000000000, 9999999999, 100, 80, 95, false, true, 'FI-', '-{YEAR}', 'High-volume financial documents'),
('FI External Invoices', 'FI', 'RF_BELEG', 0, 9999999999, 0, 80, 95, true, true, 'INV-', '', 'External vendor/customer invoices'),

-- Material Management Templates  
('MM Standard', 'MM', 'M_MBLNR', 5000000000, 5999999999, 200, 75, 90, false, true, 'MM-', '-{COMPANY}', 'Standard material documents'),
('MM Purchase Orders', 'MM', 'M_EBELN', 4000000000, 4999999999, 50, 80, 95, true, true, 'PO-', '-{SITE}', 'Purchase orders with site reference'),

-- Project System Templates
('PS Projects', 'PS', 'PS_PSPNR', 0, 9999999999, 10, 85, 95, true, false, 'PROJ-', '-{YEAR}', 'Project WBS elements'),
('PS Work Orders', 'PS', 'CO_AUFNR', 1000000, 9999999, 20, 80, 90, true, true, 'WO-', '-{SITE}', 'Construction work orders'),

-- Controlling Templates
('CO Cost Documents', 'CO', 'RK_BELEG', 2000000000, 2999999999, 50, 80, 95, false, true, 'CO-', '', 'Cost accounting documents'),
('CO Internal Orders', 'CO', 'CO_AUFNR', 100000, 999999, 10, 85, 95, false, true, 'IO-', '-{YEAR}', 'Internal orders'),

-- Sales & Distribution Templates (Future)
('SD Sales Orders', 'SD', 'SD_VBELN', 0, 9999999999, 100, 80, 95, true, true, 'SO-', '-{CUSTOMER}', 'Sales orders with customer reference'),
('SD Quotations', 'SD', 'SD_VBELN', 0, 9999999999, 50, 85, 95, true, true, 'QT-', '-{RFQ}', 'Quotations with RFQ reference'),

-- Production Planning Templates (Future)
('PP Production Orders', 'PP', 'PP_AUFNR', 4000000, 4999999, 50, 80, 95, false, true, 'PROD-', '-{YEAR}', 'Production orders'),
('PP Master Data', 'PP', 'CS_STLNR', 1, 99999999, 0, 90, 98, false, false, 'BOM-', '', 'Bill of materials master data');

-- Create consultant configuration functions
CREATE OR REPLACE FUNCTION apply_template_to_company(
    p_template_name VARCHAR(50),
    p_company_code VARCHAR(4),
    p_document_type VARCHAR(2),
    p_fiscal_year INTEGER DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_template RECORD;
    v_from_number BIGINT;
    v_to_number BIGINT;
BEGIN
    -- Get template configuration
    SELECT * INTO v_template
    FROM number_range_templates
    WHERE template_name = p_template_name;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Template % not found', p_template_name;
    END IF;
    
    -- Adjust numbers for year-dependent ranges
    IF v_template.default_year_dependent AND p_fiscal_year IS NOT NULL THEN
        v_from_number := (p_fiscal_year::BIGINT * 1000000000) + (v_template.default_from_number % 1000000000);
        v_to_number := (p_fiscal_year::BIGINT * 1000000000) + (v_template.default_to_number % 1000000000);
    ELSE
        v_from_number := v_template.default_from_number;
        v_to_number := v_template.default_to_number;
    END IF;
    
    -- Insert or update number range
    INSERT INTO document_number_ranges (
        company_code, document_type, number_range_object,
        from_number, to_number, current_number,
        buffer_size, warning_threshold, critical_threshold,
        external_numbering, year_dependent, fiscal_year,
        fiscal_year_variant, prefix, suffix, status
    ) VALUES (
        p_company_code, p_document_type, 
        CASE v_template.module_code 
            WHEN 'FI' THEN 'RF_BELEG'
            WHEN 'MM' THEN v_template.object_type
            WHEN 'PS' THEN v_template.object_type
            WHEN 'CO' THEN v_template.object_type
            ELSE v_template.object_type
        END,
        v_from_number, v_to_number, v_from_number,
        v_template.default_buffer_size, v_template.default_warning_threshold, v_template.default_critical_threshold,
        v_template.default_external_numbering, v_template.default_year_dependent, p_fiscal_year,
        'K4', v_template.recommended_prefix, v_template.recommended_suffix, 'ACTIVE'
    )
    ON CONFLICT (company_code, document_type, fiscal_year) 
    DO UPDATE SET
        from_number = EXCLUDED.from_number,
        to_number = EXCLUDED.to_number,
        buffer_size = EXCLUDED.buffer_size,
        warning_threshold = EXCLUDED.warning_threshold,
        critical_threshold = EXCLUDED.critical_threshold,
        external_numbering = EXCLUDED.external_numbering,
        prefix = EXCLUDED.prefix,
        suffix = EXCLUDED.suffix,
        modified_at = NOW();
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Create bulk configuration function for consultants
CREATE OR REPLACE FUNCTION configure_company_module(
    p_company_code VARCHAR(4),
    p_module_code VARCHAR(10),
    p_fiscal_year INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_template RECORD;
    v_result TEXT := '';
    v_doc_types TEXT[] := ARRAY[]::TEXT[];
BEGIN
    -- Define document types per module
    CASE p_module_code
        WHEN 'FI' THEN v_doc_types := ARRAY['SA', 'AB', 'KR', 'DR', 'DZ'];
        WHEN 'MM' THEN v_doc_types := ARRAY['NB', 'F1', 'WE', 'WA', 'WL', 'MI'];
        WHEN 'PS' THEN v_doc_types := ARRAY['PR', 'NW', 'AC', 'WO'];
        WHEN 'CO' THEN v_doc_types := ARRAY['CO', 'IO'];
        WHEN 'SD' THEN v_doc_types := ARRAY['OR', 'QT', 'CT', 'DL', 'IV'];
        WHEN 'PP' THEN v_doc_types := ARRAY['PO', 'PP', 'BM', 'RT'];
        ELSE RAISE EXCEPTION 'Unknown module code: %', p_module_code;
    END CASE;
    
    -- Apply appropriate template for each document type
    FOR i IN 1..array_length(v_doc_types, 1) LOOP
        -- Get the most appropriate template for this module
        SELECT * INTO v_template
        FROM number_range_templates
        WHERE module_code = p_module_code
        ORDER BY template_name
        LIMIT 1;
        
        IF FOUND THEN
            PERFORM apply_template_to_company(
                v_template.template_name,
                p_company_code,
                v_doc_types[i],
                p_fiscal_year
            );
            v_result := v_result || v_doc_types[i] || ' configured, ';
        END IF;
    END LOOP;
    
    RETURN 'Module ' || p_module_code || ' configured for ' || p_company_code || ': ' || v_result;
END;
$$ LANGUAGE plpgsql;

SELECT 'Consultant Configuration Interface Created' as status;
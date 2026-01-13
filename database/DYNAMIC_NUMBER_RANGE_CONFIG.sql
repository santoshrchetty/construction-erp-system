-- Dynamic Number Range Configuration System
-- Eliminates hardcoded company codes and enables unlimited scalability

-- Step 1: Create configuration templates table
CREATE TABLE IF NOT EXISTS number_range_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name VARCHAR(50) NOT NULL UNIQUE,
    module_code VARCHAR(2) NOT NULL,
    document_type VARCHAR(2) NOT NULL,
    number_range_object VARCHAR(10) NOT NULL,
    range_start_pattern VARCHAR(20) NOT NULL, -- e.g., '{MODULE}000000000'
    range_size BIGINT NOT NULL DEFAULT 1000000000,
    year_dependent BOOLEAN NOT NULL DEFAULT true,
    external_numbering BOOLEAN NOT NULL DEFAULT false,
    prefix_pattern VARCHAR(20), -- e.g., '{COMPANY}{DOCTYPE}'
    suffix_pattern VARCHAR(20),
    description_pattern VARCHAR(100) NOT NULL,
    number_range_group VARCHAR(2) NOT NULL DEFAULT '01',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Insert comprehensive templates for all modules
INSERT INTO number_range_templates (
    template_name, module_code, document_type, number_range_object,
    range_start_pattern, range_size, year_dependent, external_numbering,
    prefix_pattern, description_pattern, number_range_group
) VALUES
-- Financial Accounting Templates
('FI_INVOICE', 'FI', 'IV', 'RF_BELEG', '1{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Invoice Documents', '01'),
('FI_PAYMENT', 'FI', 'PY', 'RF_BELEG', '5{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Payment Documents', '01'),
('FI_JOURNAL', 'FI', 'JE', 'RF_BELEG', '2{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Journal Entry Documents', '01'),

-- Materials Management Templates
('MM_GOODS_RECEIPT', 'MM', 'GR', 'MATBELEG', '3{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Goods Receipt Documents', '02'),
('MM_GOODS_ISSUE', 'MM', 'GI', 'MATBELEG', '4{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Goods Issue Documents', '02'),
('MM_TRANSFER', 'MM', 'GT', 'MATBELEG', '4{MODULE_NUM}50000000', 500000000, false, false, '{DOCTYPE}', '{MODULE} Transfer Documents', '02'),

-- Sales & Distribution Templates
('SD_SALES_ORDER', 'SD', 'SO', 'VBELN', '8{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Sales Order Documents', '05'),
('SD_DELIVERY', 'SD', 'DL', 'VBELN', '8{MODULE_NUM}10000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Delivery Documents', '05'),
('SD_INVOICE', 'SD', 'SI', 'VBELN', '8{MODULE_NUM}20000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Sales Invoice Documents', '05'),

-- Production Planning Templates
('PP_PRODUCTION_ORDER', 'PP', 'PO', 'AUFNR', '9{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Production Order Documents', '06'),
('PP_WORK_ORDER', 'PP', 'WO', 'AUFNR', '9{MODULE_NUM}10000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Work Order Documents', '06'),

-- Quality Management Templates
('QM_INSPECTION', 'QM', 'QI', 'QMNUM', '1{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Quality Inspection Documents', '07'),
('QM_CERTIFICATE', 'QM', 'QC', 'QMNUM', '1{MODULE_NUM}10000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Quality Certificate Documents', '07'),

-- Plant Maintenance Templates
('PM_WORK_ORDER', 'PM', 'WO', 'AUFNR', '1{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Maintenance Work Orders', '08'),
('PM_NOTIFICATION', 'PM', 'PN', 'QMNUM', '1{MODULE_NUM}10000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Maintenance Notifications', '08'),

-- Human Resources Templates
('HR_PERSONNEL', 'HR', 'PE', 'PERNR', '1{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Personnel Documents', '09'),
('HR_PAYROLL', 'HR', 'PR', 'PAYNUM', '1{MODULE_NUM}10000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Payroll Documents', '09'),

-- Controlling Templates
('CO_COST_CENTER', 'CO', 'CC', 'CO_BELEG', '6{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Cost Center Documents', '03'),
('CO_INTERNAL_ORDER', 'CO', 'IO', 'CO_BELEG', '6{MODULE_NUM}10000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Internal Order Documents', '03'),

-- Project System Templates
('PS_PROJECT', 'PS', 'PR', 'PROJ_BELEG', '7{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Project Documents', '04'),
('PS_NETWORK', 'PS', 'NW', 'PROJ_BELEG', '7{MODULE_NUM}10000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Network Documents', '04'),

-- Asset Accounting Templates
('AA_ASSET', 'AA', 'AS', 'ANLN1', '1{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Asset Documents', '10'),
('AA_DEPRECIATION', 'AA', 'DP', 'ANLN1', '1{MODULE_NUM}10000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Depreciation Documents', '10')

ON CONFLICT (template_name) DO UPDATE SET
    module_code = EXCLUDED.module_code,
    document_type = EXCLUDED.document_type,
    number_range_object = EXCLUDED.number_range_object,
    range_start_pattern = EXCLUDED.range_start_pattern,
    range_size = EXCLUDED.range_size,
    year_dependent = EXCLUDED.year_dependent,
    external_numbering = EXCLUDED.external_numbering,
    prefix_pattern = EXCLUDED.prefix_pattern,
    description_pattern = EXCLUDED.description_pattern,
    number_range_group = EXCLUDED.number_range_group;

-- Step 3: Create module mapping for range calculation
CREATE TABLE IF NOT EXISTS module_number_mapping (
    module_code VARCHAR(2) PRIMARY KEY,
    module_number INTEGER NOT NULL UNIQUE,
    module_name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO module_number_mapping (module_code, module_number, module_name) VALUES
('FI', 1, 'Financial Accounting'),
('MM', 2, 'Materials Management'),
('CO', 3, 'Controlling'),
('PS', 4, 'Project System'),
('SD', 5, 'Sales & Distribution'),
('PP', 6, 'Production Planning'),
('QM', 7, 'Quality Management'),
('PM', 8, 'Plant Maintenance'),
('HR', 9, 'Human Resources'),
('AA', 10, 'Asset Accounting')
ON CONFLICT (module_code) DO UPDATE SET
    module_name = EXCLUDED.module_name,
    is_active = EXCLUDED.is_active;

-- Step 4: Dynamic configuration function for single company
CREATE OR REPLACE FUNCTION configure_company_number_ranges(
    p_company_code VARCHAR(4),
    p_modules VARCHAR(2)[] DEFAULT NULL -- If NULL, configure all modules
) RETURNS TABLE (
    company_code VARCHAR(4),
    document_type VARCHAR(2),
    from_number BIGINT,
    to_number BIGINT,
    status TEXT
) AS $$
DECLARE
    template_rec RECORD;
    module_num INTEGER;
    calculated_start BIGINT;
    calculated_end BIGINT;
    final_prefix VARCHAR(10);
    final_description VARCHAR(100);
BEGIN
    -- Loop through templates
    FOR template_rec IN 
        SELECT t.*, m.module_number
        FROM number_range_templates t
        JOIN module_number_mapping m ON t.module_code = m.module_code
        WHERE (p_modules IS NULL OR t.module_code = ANY(p_modules))
          AND m.is_active = true
    LOOP
        -- Calculate range numbers
        calculated_start := REPLACE(template_rec.range_start_pattern, '{MODULE_NUM}', template_rec.module_number::TEXT)::BIGINT;
        calculated_end := calculated_start + template_rec.range_size - 1;
        
        -- Build prefix
        final_prefix := template_rec.prefix_pattern;
        final_prefix := REPLACE(final_prefix, '{COMPANY}', p_company_code);
        final_prefix := REPLACE(final_prefix, '{DOCTYPE}', template_rec.document_type);
        final_prefix := REPLACE(final_prefix, '{MODULE}', template_rec.module_code);
        
        -- Build description
        final_description := REPLACE(template_rec.description_pattern, '{MODULE}', template_rec.module_code);
        final_description := REPLACE(final_description, '{COMPANY}', p_company_code);
        
        -- Insert or update number range
        INSERT INTO document_number_ranges (
            company_code, document_type, number_range_object,
            from_number, to_number, current_number,
            status, year_dependent, external_numbering,
            prefix, description, number_range_group
        ) VALUES (
            p_company_code, template_rec.document_type, template_rec.number_range_object,
            calculated_start, calculated_end, calculated_start,
            'ACTIVE', template_rec.year_dependent, template_rec.external_numbering,
            final_prefix, final_description, template_rec.number_range_group
        )
        ON CONFLICT (company_code, document_type) DO UPDATE SET
            from_number = EXCLUDED.from_number,
            to_number = EXCLUDED.to_number,
            number_range_object = EXCLUDED.number_range_object,
            year_dependent = EXCLUDED.year_dependent,
            external_numbering = EXCLUDED.external_numbering,
            prefix = EXCLUDED.prefix,
            description = EXCLUDED.description,
            number_range_group = EXCLUDED.number_range_group,
            modified_at = NOW();
        
        -- Return result
        RETURN QUERY SELECT 
            p_company_code,
            template_rec.document_type,
            calculated_start,
            calculated_end,
            'CONFIGURED'::TEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Bulk configuration function for multiple companies
CREATE OR REPLACE FUNCTION configure_multiple_companies(
    p_company_codes VARCHAR(4)[],
    p_modules VARCHAR(2)[] DEFAULT NULL
) RETURNS TABLE (
    company_code VARCHAR(4),
    document_type VARCHAR(2),
    from_number BIGINT,
    to_number BIGINT,
    status TEXT
) AS $$
DECLARE
    company_code_item VARCHAR(4);
BEGIN
    FOREACH company_code_item IN ARRAY p_company_codes
    LOOP
        RETURN QUERY SELECT * FROM configure_company_number_ranges(company_code_item, p_modules);
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 6: Create number range groups dynamically
CREATE OR REPLACE FUNCTION create_number_range_groups(
    p_company_code VARCHAR(4)
) RETURNS VOID AS $$
BEGIN
    INSERT INTO number_range_groups (group_code, group_name, company_code, description) VALUES
    ('01', 'Financial Documents', p_company_code, 'All financial accounting documents'),
    ('02', 'Material Documents', p_company_code, 'All materials management documents'),
    ('03', 'Controlling Documents', p_company_code, 'All controlling documents'),
    ('04', 'Project Documents', p_company_code, 'All project system documents'),
    ('05', 'Sales Documents', p_company_code, 'All sales & distribution documents'),
    ('06', 'Production Documents', p_company_code, 'All production planning documents'),
    ('07', 'Quality Documents', p_company_code, 'All quality management documents'),
    ('08', 'Maintenance Documents', p_company_code, 'All plant maintenance documents'),
    ('09', 'HR Documents', p_company_code, 'All human resources documents'),
    ('10', 'Asset Documents', p_company_code, 'All asset accounting documents')
    ON CONFLICT (company_code, group_code) DO UPDATE SET
        group_name = EXCLUDED.group_name,
        description = EXCLUDED.description;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT 'Dynamic number range configuration system deployed successfully' as status;
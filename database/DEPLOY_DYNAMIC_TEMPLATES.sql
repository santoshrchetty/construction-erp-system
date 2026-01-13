-- DEPLOY DYNAMIC NUMBER RANGE TEMPLATES
-- Enables unlimited company expansion with template-based configuration

-- Step 1: Create configuration templates table
CREATE TABLE IF NOT EXISTS number_range_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name VARCHAR(50) NOT NULL UNIQUE,
    module_code VARCHAR(2) NOT NULL,
    document_type VARCHAR(2) NOT NULL,
    number_range_object VARCHAR(10) NOT NULL,
    range_start_pattern VARCHAR(20) NOT NULL,
    range_size BIGINT NOT NULL DEFAULT 1000000000,
    year_dependent BOOLEAN NOT NULL DEFAULT true,
    external_numbering BOOLEAN NOT NULL DEFAULT false,
    prefix_pattern VARCHAR(20),
    description_pattern VARCHAR(100) NOT NULL,
    number_range_group VARCHAR(2) NOT NULL DEFAULT '01',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Insert comprehensive templates
INSERT INTO number_range_templates (
    template_name, module_code, document_type, number_range_object,
    range_start_pattern, range_size, year_dependent, external_numbering,
    prefix_pattern, description_pattern, number_range_group
) VALUES
-- Financial Accounting Templates
('FI_PAYMENT', 'FI', 'PY', 'RF_BELEG', '5{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Payment Documents', '01'),
('FI_JOURNAL', 'FI', 'JE', 'RF_BELEG', '2{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Journal Entry Documents', '01'),
('FI_BANK', 'FI', 'BK', 'RF_BELEG', '5{MODULE_NUM}30000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Bank Documents', '01'),

-- Materials Management Templates
('MM_GOODS_RECEIPT', 'MM', 'GR', 'MATBELEG', '3{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Goods Receipt Documents', '02'),
('MM_GOODS_ISSUE', 'MM', 'GI', 'MATBELEG', '4{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Goods Issue Documents', '02'),
('MM_TRANSFER', 'MM', 'GT', 'MATBELEG', '4{MODULE_NUM}50000000', 500000000, false, false, '{DOCTYPE}', '{MODULE} Transfer Documents', '02'),

-- Controlling Templates
('CO_COST_CENTER', 'CO', 'CC', 'CO_BELEG', '6{MODULE_NUM}00000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Cost Center Documents', '03'),
('CO_COST_DOCUMENT', 'CO', 'CD', 'CO_BELEG', '6{MODULE_NUM}10000000', 1000000000, true, false, '{DOCTYPE}', '{MODULE} Cost Documents', '03'),

-- Project System Templates
('PS_PROJECT', 'PS', 'PJ', 'PROJ_BELEG', '7{MODULE_NUM}00000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Project Documents', '04'),
('PS_NETWORK', 'PS', 'NW', 'PROJ_BELEG', '7{MODULE_NUM}10000000', 1000000000, false, false, '{DOCTYPE}', '{MODULE} Network Documents', '04')

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

-- Step 3: Create module mapping
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
('PS', 4, 'Project System')
ON CONFLICT (module_code) DO UPDATE SET
    module_name = EXCLUDED.module_name,
    is_active = EXCLUDED.is_active;

-- Step 4: Dynamic configuration function
CREATE OR REPLACE FUNCTION configure_company_number_ranges(
    p_company_code VARCHAR(4),
    p_modules VARCHAR(2)[] DEFAULT NULL
) RETURNS TABLE (
    company_code VARCHAR(4),
    document_type VARCHAR(2),
    from_number BIGINT,
    to_number BIGINT,
    status TEXT
) AS $$
DECLARE
    template_rec RECORD;
    calculated_start BIGINT;
    calculated_end BIGINT;
    final_prefix VARCHAR(10);
    final_description VARCHAR(100);
BEGIN
    FOR template_rec IN 
        SELECT t.*, m.module_number
        FROM number_range_templates t
        JOIN module_number_mapping m ON t.module_code = m.module_code
        WHERE (p_modules IS NULL OR t.module_code = ANY(p_modules))
          AND m.is_active = true
    LOOP
        calculated_start := REPLACE(template_rec.range_start_pattern, '{MODULE_NUM}', template_rec.module_number::TEXT)::BIGINT;
        calculated_end := calculated_start + template_rec.range_size - 1;
        
        final_prefix := COALESCE(REPLACE(REPLACE(template_rec.prefix_pattern, '{COMPANY}', p_company_code), '{DOCTYPE}', template_rec.document_type), template_rec.document_type);
        final_description := REPLACE(REPLACE(template_rec.description_pattern, '{MODULE}', template_rec.module_code), '{COMPANY}', p_company_code);
        
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
        
        RETURN QUERY SELECT 
            p_company_code,
            template_rec.document_type,
            calculated_start,
            calculated_end,
            'CONFIGURED'::TEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Test dynamic configuration
SELECT 'Testing Dynamic Configuration for B001' as test_name;
SELECT * FROM configure_company_number_ranges('B001', ARRAY['FI', 'MM']);

SELECT 'Dynamic Number Range Template System Deployed Successfully' as status;
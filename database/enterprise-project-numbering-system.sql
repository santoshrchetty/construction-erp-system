-- Enterprise Project Numbering System for Cross-Industry Integration
-- Supports Primavera P6, MS Project, Concerto, and other PM tools

-- 1. Industry-specific numbering templates
CREATE TABLE IF NOT EXISTS industry_numbering_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    industry_code VARCHAR(20) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    pattern VARCHAR(200) NOT NULL,
    description TEXT,
    external_tool_mapping JSONB,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enhanced project numbering rules with industry support
ALTER TABLE project_numbering_rules 
ADD COLUMN IF NOT EXISTS industry_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS external_id_pattern VARCHAR(200),
ADD COLUMN IF NOT EXISTS integration_mapping JSONB,
ADD COLUMN IF NOT EXISTS validation_rules JSONB;

-- 3. External system integration mapping
CREATE TABLE IF NOT EXISTS external_system_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    system_name VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    internal_pattern VARCHAR(200) NOT NULL,
    external_pattern VARCHAR(200) NOT NULL,
    field_mappings JSONB,
    sync_enabled BOOLEAN DEFAULT true,
    company_code VARCHAR(10) DEFAULT 'C001'
);

-- Industry Templates
INSERT INTO industry_numbering_templates (industry_code, entity_type, pattern, description, external_tool_mapping, is_default) VALUES
-- Construction Industry
('CONSTRUCTION', 'PROJECT', '{COMPANY}-{YYYY}-{####}', 'Construction project numbering', '{"primavera": "PROJECT_ID", "msproject": "Project.UniqueID"}', true),
('CONSTRUCTION', 'WBS_ELEMENT', '{PROJECT}.{##}.{##}', 'Construction WBS', '{"primavera": "WBS_ID", "msproject": "Task.OutlineNumber"}', true),
('CONSTRUCTION', 'ACTIVITY', '{WBS}.A{###}', 'Construction activities', '{"primavera": "ACTIVITY_ID", "msproject": "Task.UniqueID"}', true),

-- Manufacturing Industry  
('MANUFACTURING', 'PROJECT', 'MFG-{PLANT}-{YYYY}{###}', 'Manufacturing project numbering', '{"sap": "PS_PROJECT", "oracle": "PROJECT_NUMBER"}', true),
('MANUFACTURING', 'WBS_ELEMENT', '{PROJECT}.{##}', 'Manufacturing WBS', '{"sap": "PS_WBS_ELEMENT", "oracle": "TASK_NUMBER"}', true),

-- IT/Software Industry
('IT', 'PROJECT', 'IT{YYYY}{###}', 'IT project numbering', '{"jira": "PROJECT_KEY", "azure": "PROJECT_ID"}', true),
('IT', 'WBS_ELEMENT', '{PROJECT}-{SPRINT##}', 'Agile sprint structure', '{"jira": "SPRINT_ID", "azure": "ITERATION_PATH"}', true),

-- Oil & Gas Industry
('OIL_GAS', 'PROJECT', '{FIELD}-{YYYY}-{###}', 'Oil & Gas project numbering', '{"primavera": "PROJECT_ID", "concerto": "PROJECT_CODE"}', true),
('OIL_GAS', 'WBS_ELEMENT', '{PROJECT}.{AREA##}.{SYSTEM##}', 'O&G WBS structure', '{"primavera": "WBS_ID", "concerto": "WBS_CODE"}', true);

-- External System Mappings
INSERT INTO external_system_mappings (system_name, entity_type, internal_pattern, external_pattern, field_mappings, company_code) VALUES
-- Primavera P6 Integration
('PRIMAVERA_P6', 'PROJECT', '{COMPANY}-{YYYY}-{####}', 'P6_{COMPANY}_{YYYY}_{####}', 
 '{"project_name": "PROJECT_NAME", "start_date": "START_DATE", "finish_date": "FINISH_DATE"}', 'C001'),
('PRIMAVERA_P6', 'WBS_ELEMENT', '{PROJECT}.{##}.{##}', '{PROJECT}_WBS_{##}_{##}', 
 '{"wbs_name": "WBS_NAME", "parent_wbs": "PARENT_WBS_ID"}', 'C001'),

-- MS Project Integration  
('MS_PROJECT', 'PROJECT', '{COMPANY}-{YYYY}-{####}', '{COMPANY}_{YYYY}_{####}', 
 '{"project_name": "Name", "start_date": "Start", "finish_date": "Finish"}', 'C001'),
('MS_PROJECT', 'WBS_ELEMENT', '{PROJECT}.{##}.{##}', '{##}.{##}', 
 '{"task_name": "Name", "outline_level": "OutlineLevel"}', 'C001'),

-- Concerto Integration
('CONCERTO', 'PROJECT', '{FIELD}-{YYYY}-{###}', 'CONC_{FIELD}_{YYYY}_{###}', 
 '{"project_title": "PROJECT_TITLE", "project_manager": "PM_NAME"}', 'C001');

-- Functions for pattern generation
CREATE OR REPLACE FUNCTION generate_project_number(
    p_industry_code VARCHAR(20),
    p_entity_type VARCHAR(50),
    p_company_code VARCHAR(10) DEFAULT 'C001',
    p_context JSONB DEFAULT '{}'::jsonb
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_pattern VARCHAR(200);
    v_current_number INTEGER;
    v_result VARCHAR(200);
    v_year VARCHAR(4) := EXTRACT(YEAR FROM NOW())::VARCHAR;
BEGIN
    -- Get pattern from industry template or fallback to company-specific
    SELECT pattern INTO v_pattern
    FROM industry_numbering_templates 
    WHERE industry_code = p_industry_code 
    AND entity_type = p_entity_type 
    AND is_default = true
    LIMIT 1;
    
    IF v_pattern IS NULL THEN
        SELECT pattern INTO v_pattern
        FROM project_numbering_rules
        WHERE entity_type = p_entity_type
        AND company_code = p_company_code
        AND is_active = true
        LIMIT 1;
    END IF;
    
    -- Get and increment current number
    UPDATE project_numbering_rules 
    SET current_number = current_number + 1
    WHERE entity_type = p_entity_type 
    AND company_code = p_company_code
    RETURNING current_number INTO v_current_number;
    
    -- Replace pattern placeholders
    v_result := v_pattern;
    v_result := REPLACE(v_result, '{COMPANY}', p_company_code);
    v_result := REPLACE(v_result, '{YYYY}', v_year);
    v_result := REPLACE(v_result, '{####}', LPAD(v_current_number::VARCHAR, 4, '0'));
    v_result := REPLACE(v_result, '{###}', LPAD(v_current_number::VARCHAR, 3, '0'));
    v_result := REPLACE(v_result, '{##}', LPAD(v_current_number::VARCHAR, 2, '0'));
    
    -- Handle context-specific replacements
    IF p_context ? 'PROJECT' THEN
        v_result := REPLACE(v_result, '{PROJECT}', p_context->>'PROJECT');
    END IF;
    IF p_context ? 'WBS' THEN
        v_result := REPLACE(v_result, '{WBS}', p_context->>'WBS');
    END IF;
    IF p_context ? 'FIELD' THEN
        v_result := REPLACE(v_result, '{FIELD}', p_context->>'FIELD');
    END IF;
    IF p_context ? 'PLANT' THEN
        v_result := REPLACE(v_result, '{PLANT}', p_context->>'PLANT');
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Function to get external system ID
CREATE OR REPLACE FUNCTION get_external_system_id(
    p_internal_id VARCHAR(200),
    p_system_name VARCHAR(50),
    p_entity_type VARCHAR(50)
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_external_pattern VARCHAR(200);
    v_result VARCHAR(200);
BEGIN
    SELECT external_pattern INTO v_external_pattern
    FROM external_system_mappings
    WHERE system_name = p_system_name
    AND entity_type = p_entity_type
    AND sync_enabled = true
    LIMIT 1;
    
    IF v_external_pattern IS NULL THEN
        RETURN p_internal_id; -- Return internal ID if no mapping
    END IF;
    
    -- Apply transformation logic based on pattern
    v_result := v_external_pattern;
    -- Add specific transformation logic here based on patterns
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_industry_templates_industry ON industry_numbering_templates(industry_code);
CREATE INDEX IF NOT EXISTS idx_industry_templates_entity ON industry_numbering_templates(entity_type);
CREATE INDEX IF NOT EXISTS idx_external_mappings_system ON external_system_mappings(system_name);
CREATE INDEX IF NOT EXISTS idx_external_mappings_entity ON external_system_mappings(entity_type);
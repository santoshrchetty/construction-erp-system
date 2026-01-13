-- Consultant-Editable Pattern System
-- Allows full customization of numbering patterns with validation

-- Add consultant editing capabilities to existing tables
ALTER TABLE project_numbering_rules 
ADD COLUMN IF NOT EXISTS pattern_editable BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS pattern_validation_rules JSONB DEFAULT '{"required_placeholders": [], "max_length": 200, "allowed_characters": "A-Z0-9-._{}"}',
ADD COLUMN IF NOT EXISTS last_modified_by VARCHAR(100),
ADD COLUMN IF NOT EXISTS modification_reason TEXT;

-- Pattern validation function
CREATE OR REPLACE FUNCTION validate_numbering_pattern(
    p_pattern VARCHAR(200),
    p_entity_type VARCHAR(50)
) RETURNS JSONB AS $$
DECLARE
    v_result JSONB := '{"valid": true, "errors": [], "warnings": []}';
    v_errors TEXT[] := '{}';
    v_warnings TEXT[] := '{}';
BEGIN
    -- Check pattern length
    IF LENGTH(p_pattern) > 200 THEN
        v_errors := array_append(v_errors, 'Pattern exceeds maximum length of 200 characters');
    END IF;
    
    -- Check for required placeholders based on entity type
    CASE p_entity_type
        WHEN 'PROJECT' THEN
            IF p_pattern !~ '\{(COMPANY|YYYY|####|###|##)\}' THEN
                v_errors := array_append(v_errors, 'PROJECT patterns must include at least one numbering placeholder');
            END IF;
        WHEN 'WBS_ELEMENT' THEN
            IF p_pattern !~ '\{PROJECT\}' THEN
                v_warnings := array_append(v_warnings, 'WBS patterns typically reference {PROJECT}');
            END IF;
        WHEN 'ACTIVITY' THEN
            IF p_pattern !~ '\{(WBS|PROJECT)\}' THEN
                v_warnings := array_append(v_warnings, 'ACTIVITY patterns typically reference {WBS} or {PROJECT}');
            END IF;
    END CASE;
    
    -- Check for invalid characters
    IF p_pattern ~ '[^A-Za-z0-9\-\._\{\}]' THEN
        v_errors := array_append(v_errors, 'Pattern contains invalid characters. Allowed: A-Z, 0-9, -, ., _, {}');
    END IF;
    
    -- Build result
    v_result := jsonb_build_object(
        'valid', array_length(v_errors, 1) IS NULL,
        'errors', v_errors,
        'warnings', v_warnings
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Pattern preview function
CREATE OR REPLACE FUNCTION preview_numbering_pattern(
    p_pattern VARCHAR(200),
    p_entity_type VARCHAR(50),
    p_context JSONB DEFAULT '{}'::jsonb
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_preview VARCHAR(200);
    v_year VARCHAR(4) := EXTRACT(YEAR FROM NOW())::VARCHAR;
    v_sample_number INTEGER := 1;
BEGIN
    v_preview := p_pattern;
    
    -- Replace common placeholders with sample values
    v_preview := REPLACE(v_preview, '{COMPANY}', COALESCE(p_context->>'COMPANY', 'ABC'));
    v_preview := REPLACE(v_preview, '{YYYY}', v_year);
    v_preview := REPLACE(v_preview, '{YY}', RIGHT(v_year, 2));
    v_preview := REPLACE(v_preview, '{####}', LPAD(v_sample_number::VARCHAR, 4, '0'));
    v_preview := REPLACE(v_preview, '{###}', LPAD(v_sample_number::VARCHAR, 3, '0'));
    v_preview := REPLACE(v_preview, '{##}', LPAD(v_sample_number::VARCHAR, 2, '0'));
    v_preview := REPLACE(v_preview, '{#}', v_sample_number::VARCHAR);
    
    -- Context-specific replacements
    v_preview := REPLACE(v_preview, '{PROJECT}', COALESCE(p_context->>'PROJECT', 'ABC-2024-0001'));
    v_preview := REPLACE(v_preview, '{WBS}', COALESCE(p_context->>'WBS', 'ABC-2024-0001.01'));
    v_preview := REPLACE(v_preview, '{FIELD}', COALESCE(p_context->>'FIELD', 'GULF'));
    v_preview := REPLACE(v_preview, '{PLANT}', COALESCE(p_context->>'PLANT', 'TX01'));
    v_preview := REPLACE(v_preview, '{SPRINT}', COALESCE(p_context->>'SPRINT', 'SPRINT01'));
    
    RETURN v_preview;
END;
$$ LANGUAGE plpgsql;

-- Consultant pattern management functions
CREATE OR REPLACE FUNCTION update_numbering_pattern(
    p_id UUID,
    p_new_pattern VARCHAR(200),
    p_consultant_id VARCHAR(100),
    p_reason TEXT DEFAULT 'Pattern customization'
) RETURNS JSONB AS $$
DECLARE
    v_entity_type VARCHAR(50);
    v_validation JSONB;
    v_result JSONB;
BEGIN
    -- Get entity type for validation
    SELECT entity_type INTO v_entity_type
    FROM project_numbering_rules
    WHERE id = p_id;
    
    IF v_entity_type IS NULL THEN
        RETURN '{"success": false, "error": "Numbering rule not found"}';
    END IF;
    
    -- Validate pattern
    v_validation := validate_numbering_pattern(p_new_pattern, v_entity_type);
    
    IF NOT (v_validation->>'valid')::boolean THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Pattern validation failed',
            'validation', v_validation
        );
    END IF;
    
    -- Update pattern
    UPDATE project_numbering_rules
    SET 
        pattern = p_new_pattern,
        last_modified_by = p_consultant_id,
        modification_reason = p_reason,
        updated_at = NOW()
    WHERE id = p_id;
    
    v_result := jsonb_build_object(
        'success', true,
        'validation', v_validation,
        'preview', preview_numbering_pattern(p_new_pattern, v_entity_type)
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Common pattern templates for consultants
INSERT INTO industry_numbering_templates (industry_code, entity_type, pattern, description, is_default) VALUES
-- Flexible templates consultants can customize
('CUSTOM', 'PROJECT', '{COMPANY}-{YYYY}-{####}', 'Standard company-year-sequence', false),
('CUSTOM', 'PROJECT', '{COMPANY}{YY}{###}', 'Compact company-year-sequence', false),
('CUSTOM', 'PROJECT', '{DEPT}-{YYYY}-{##}', 'Department-based numbering', false),
('CUSTOM', 'WBS_ELEMENT', '{PROJECT}.{##}', 'Simple 2-level hierarchy', false),
('CUSTOM', 'WBS_ELEMENT', '{PROJECT}.{##}.{##}', 'Standard 3-level hierarchy', false),
('CUSTOM', 'WBS_ELEMENT', '{PROJECT}-{PHASE##}-{AREA##}', 'Phase-area structure', false),
('CUSTOM', 'ACTIVITY', '{WBS}.A{###}', 'Activity with A prefix', false),
('CUSTOM', 'ACTIVITY', '{WBS}-ACT{##}', 'Activity with ACT prefix', false),
('CUSTOM', 'TASK', '{ACTIVITY}.T{##}', 'Task with T prefix', false)
ON CONFLICT DO NOTHING;

-- Available placeholders reference
CREATE TABLE IF NOT EXISTS pattern_placeholders (
    placeholder VARCHAR(20) PRIMARY KEY,
    description TEXT,
    example VARCHAR(50),
    entity_types VARCHAR(200)
);

INSERT INTO pattern_placeholders VALUES
('{COMPANY}', 'Company code', 'ABC', 'PROJECT,WBS_ELEMENT,ACTIVITY,TASK'),
('{YYYY}', 'Full year', '2024', 'PROJECT,WBS_ELEMENT,ACTIVITY,TASK'),
('{YY}', 'Short year', '24', 'PROJECT,WBS_ELEMENT,ACTIVITY,TASK'),
('{####}', '4-digit sequence', '0001', 'PROJECT,WBS_ELEMENT,ACTIVITY,TASK'),
('{###}', '3-digit sequence', '001', 'PROJECT,WBS_ELEMENT,ACTIVITY,TASK'),
('{##}', '2-digit sequence', '01', 'PROJECT,WBS_ELEMENT,ACTIVITY,TASK'),
('{#}', '1-digit sequence', '1', 'PROJECT,WBS_ELEMENT,ACTIVITY,TASK'),
('{PROJECT}', 'Parent project ID', 'ABC-2024-0001', 'WBS_ELEMENT,ACTIVITY,TASK'),
('{WBS}', 'Parent WBS ID', 'ABC-2024-0001.01', 'ACTIVITY,TASK'),
('{ACTIVITY}', 'Parent activity ID', 'ABC-2024-0001.01.A001', 'TASK'),
('{FIELD}', 'Field/location code', 'GULF', 'PROJECT,WBS_ELEMENT'),
('{PLANT}', 'Plant code', 'TX01', 'PROJECT,WBS_ELEMENT'),
('{DEPT}', 'Department code', 'IT', 'PROJECT,WBS_ELEMENT'),
('{PHASE}', 'Phase identifier', 'PHASE01', 'WBS_ELEMENT,ACTIVITY'),
('{SPRINT}', 'Sprint identifier', 'SPRINT01', 'WBS_ELEMENT,ACTIVITY')
ON CONFLICT DO NOTHING;
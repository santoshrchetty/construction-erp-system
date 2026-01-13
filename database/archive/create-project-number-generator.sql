-- Create function to generate project numbers using the pattern system
CREATE OR REPLACE FUNCTION generate_project_number(
    p_entity_type VARCHAR(50) DEFAULT 'PROJECT',
    p_company_code VARCHAR(10) DEFAULT 'C001'
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_pattern VARCHAR(200);
    v_current_number INTEGER;
    v_result VARCHAR(200);
BEGIN
    -- Get pattern from numbering rules
    SELECT pattern, current_number INTO v_pattern, v_current_number
    FROM project_numbering_rules
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND is_active = true
    ORDER BY created_at DESC
    LIMIT 1;
    
    -- If no pattern found, return default
    IF v_pattern IS NULL THEN
        v_pattern := 'HW-{####}';
        v_current_number := 1;
    END IF;
    
    -- Update current number
    UPDATE project_numbering_rules 
    SET current_number = current_number + 1,
        updated_at = NOW()
    WHERE entity_type = p_entity_type 
    AND company_code = p_company_code
    AND is_active = true;
    
    -- If no rows updated, insert default rule
    IF NOT FOUND THEN
        INSERT INTO project_numbering_rules (entity_type, pattern, current_number, description, company_code)
        VALUES (p_entity_type, 'HW-{####}', 2, 'Auto-created highway project numbering', p_company_code);
        v_current_number := 1;
        v_pattern := 'HW-{####}';
    END IF;
    
    -- Replace pattern placeholders
    v_result := v_pattern;
    v_result := REPLACE(v_result, '{####}', LPAD(v_current_number::VARCHAR, 4, '0'));
    v_result := REPLACE(v_result, '{###}', LPAD(v_current_number::VARCHAR, 3, '0'));
    v_result := REPLACE(v_result, '{##}', LPAD(v_current_number::VARCHAR, 2, '0'));
    v_result := REPLACE(v_result, '{#}', v_current_number::VARCHAR);
    
    -- Replace other placeholders
    v_result := REPLACE(v_result, '{COMPANY}', p_company_code);
    v_result := REPLACE(v_result, '{YYYY}', EXTRACT(YEAR FROM NOW())::VARCHAR);
    v_result := REPLACE(v_result, '{YY}', RIGHT(EXTRACT(YEAR FROM NOW())::VARCHAR, 2));
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT generate_project_number('PROJECT', 'C001') as generated_project_code;
-- Create function to generate project numbers with specific pattern
CREATE OR REPLACE FUNCTION generate_project_number_with_pattern(
    p_entity_type VARCHAR(50),
    p_company_code VARCHAR(10),
    p_pattern VARCHAR(200)
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_current_number INTEGER;
    v_result VARCHAR(200);
BEGIN
    -- Get current number for this pattern
    SELECT current_number INTO v_current_number
    FROM project_numbering_rules
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern
    AND is_active = true;
    
    -- If no record found, start with 1
    IF v_current_number IS NULL THEN
        v_current_number := 1;
        -- Insert new numbering rule
        INSERT INTO project_numbering_rules (entity_type, pattern, current_number, description, company_code, is_active)
        VALUES (p_entity_type, p_pattern, 1, 'Auto-created numbering rule', p_company_code, true);
    ELSE
        -- Increment the counter
        v_current_number := v_current_number + 1;
        UPDATE project_numbering_rules 
        SET current_number = v_current_number,
            updated_at = NOW()
        WHERE entity_type = p_entity_type 
        AND company_code = p_company_code
        AND pattern = p_pattern
        AND is_active = true;
    END IF;
    
    -- Replace pattern placeholders
    v_result := p_pattern;
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
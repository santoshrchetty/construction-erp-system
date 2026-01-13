-- Preview function - does NOT increment counter
CREATE OR REPLACE FUNCTION preview_project_number_with_pattern(
    p_entity_type VARCHAR(50),
    p_company_code VARCHAR(10),
    p_pattern VARCHAR(200)
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_next_number INTEGER;
    v_max_existing INTEGER;
    v_current_counter INTEGER;
    v_result VARCHAR(200);
    v_pattern_regex VARCHAR(200);
BEGIN
    -- Create regex pattern to extract numbers from existing projects
    v_pattern_regex := REPLACE(p_pattern, '{####}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{###}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{##}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{#}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{YYYY}', EXTRACT(YEAR FROM NOW())::VARCHAR);
    v_pattern_regex := REPLACE(v_pattern_regex, '{YY}', RIGHT(EXTRACT(YEAR FROM NOW())::VARCHAR, 2));
    v_pattern_regex := REPLACE(v_pattern_regex, '{COMPANY}', p_company_code);
    
    -- Get highest existing project number
    EXECUTE format('
        SELECT COALESCE(MAX(CAST(substring(code FROM %L) AS INTEGER)), 0)
        FROM projects 
        WHERE code ~ %L
    ', v_pattern_regex, '^' || v_pattern_regex || '$') INTO v_max_existing;
    
    -- Get current counter (without incrementing)
    SELECT current_number INTO v_current_counter
    FROM project_numbering_rules
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern
    AND is_active = true;
    
    -- Calculate next number (preview only)
    v_next_number := GREATEST(COALESCE(v_max_existing, 0), COALESCE(v_current_counter, 0)) + 1;
    
    -- Generate preview result
    v_result := p_pattern;
    v_result := REPLACE(v_result, '{####}', LPAD(v_next_number::VARCHAR, 4, '0'));
    v_result := REPLACE(v_result, '{###}', LPAD(v_next_number::VARCHAR, 3, '0'));
    v_result := REPLACE(v_result, '{##}', LPAD(v_next_number::VARCHAR, 2, '0'));
    v_result := REPLACE(v_result, '{#}', v_next_number::VARCHAR);
    v_result := REPLACE(v_result, '{COMPANY}', p_company_code);
    v_result := REPLACE(v_result, '{YYYY}', EXTRACT(YEAR FROM NOW())::VARCHAR);
    v_result := REPLACE(v_result, '{YY}', RIGHT(EXTRACT(YEAR FROM NOW())::VARCHAR, 2));
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Final function - DOES increment counter (only called on save)
CREATE OR REPLACE FUNCTION generate_project_number_with_pattern(
    p_entity_type VARCHAR(50),
    p_company_code VARCHAR(10),
    p_pattern VARCHAR(200)
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_final_number INTEGER;
    v_max_existing INTEGER;
    v_current_counter INTEGER;
    v_result VARCHAR(200);
    v_pattern_regex VARCHAR(200);
BEGIN
    -- Create regex pattern to extract numbers from existing projects
    v_pattern_regex := REPLACE(p_pattern, '{####}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{###}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{##}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{#}', '(\d+)');
    v_pattern_regex := REPLACE(v_pattern_regex, '{YYYY}', EXTRACT(YEAR FROM NOW())::VARCHAR);
    v_pattern_regex := REPLACE(v_pattern_regex, '{YY}', RIGHT(EXTRACT(YEAR FROM NOW())::VARCHAR, 2));
    v_pattern_regex := REPLACE(v_pattern_regex, '{COMPANY}', p_company_code);
    
    -- Get highest existing project number
    EXECUTE format('
        SELECT COALESCE(MAX(CAST(substring(code FROM %L) AS INTEGER)), 0)
        FROM projects 
        WHERE code ~ %L
    ', v_pattern_regex, '^' || v_pattern_regex || '$') INTO v_max_existing;
    
    -- Get current counter
    SELECT current_number INTO v_current_counter
    FROM project_numbering_rules
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern
    AND is_active = true;
    
    -- Calculate final number and increment counter
    v_final_number := GREATEST(COALESCE(v_max_existing, 0), COALESCE(v_current_counter, 0)) + 1;
    
    -- Update counter (only here, not in preview)
    INSERT INTO project_numbering_rules (entity_type, pattern, current_number, description, company_code, is_active)
    VALUES (p_entity_type, p_pattern, v_final_number, 'Auto-created numbering rule', p_company_code, true)
    ON CONFLICT (entity_type, company_code, pattern) 
    DO UPDATE SET 
        current_number = v_final_number,
        updated_at = NOW();
    
    -- Generate final result
    v_result := p_pattern;
    v_result := REPLACE(v_result, '{####}', LPAD(v_final_number::VARCHAR, 4, '0'));
    v_result := REPLACE(v_result, '{###}', LPAD(v_final_number::VARCHAR, 3, '0'));
    v_result := REPLACE(v_result, '{##}', LPAD(v_final_number::VARCHAR, 2, '0'));
    v_result := REPLACE(v_result, '{#}', v_final_number::VARCHAR);
    v_result := REPLACE(v_result, '{COMPANY}', p_company_code);
    v_result := REPLACE(v_result, '{YYYY}', EXTRACT(YEAR FROM NOW())::VARCHAR);
    v_result := REPLACE(v_result, '{YY}', RIGHT(EXTRACT(YEAR FROM NOW())::VARCHAR, 2));
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
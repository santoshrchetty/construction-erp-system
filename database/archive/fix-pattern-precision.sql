-- Fix the regex pattern generation to be more precise
CREATE OR REPLACE FUNCTION reserve_project_number_with_pattern(
    p_entity_type VARCHAR(50),
    p_company_code VARCHAR(10),
    p_pattern VARCHAR(200),
    p_session_id VARCHAR(100)
) RETURNS VARCHAR(200) AS $$
DECLARE
    v_next_number INTEGER;
    v_max_existing INTEGER;
    v_max_reserved INTEGER;
    v_current_counter INTEGER;
    v_result VARCHAR(200);
    v_pattern_regex VARCHAR(200);
    v_exact_pattern VARCHAR(200);
BEGIN
    -- Clean up expired reservations first
    DELETE FROM project_number_reservations WHERE expires_at < NOW();
    
    -- Check if session already has a reservation
    SELECT reserved_code INTO v_result
    FROM project_number_reservations
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern
    AND session_id = p_session_id
    AND expires_at > NOW()
    AND is_consumed = false;
    
    IF v_result IS NOT NULL THEN
        -- Extend existing reservation
        UPDATE project_number_reservations 
        SET expires_at = NOW() + INTERVAL '30 minutes'
        WHERE session_id = p_session_id AND reserved_code = v_result;
        RETURN v_result;
    END IF;
    
    -- Create precise regex pattern
    v_exact_pattern := p_pattern;
    v_exact_pattern := REPLACE(v_exact_pattern, '{YYYY}', EXTRACT(YEAR FROM NOW())::VARCHAR);
    v_exact_pattern := REPLACE(v_exact_pattern, '{YY}', RIGHT(EXTRACT(YEAR FROM NOW())::VARCHAR, 2));
    v_exact_pattern := REPLACE(v_exact_pattern, '{COMPANY}', p_company_code);
    
    -- Create regex that matches the exact pattern structure
    v_pattern_regex := v_exact_pattern;
    v_pattern_regex := REPLACE(v_pattern_regex, '{####}', '(\d{4})');
    v_pattern_regex := REPLACE(v_pattern_regex, '{###}', '(\d{3})');
    v_pattern_regex := REPLACE(v_pattern_regex, '{##}', '(\d{2})');
    v_pattern_regex := REPLACE(v_pattern_regex, '{#}', '(\d+)');
    
    -- Escape special regex characters in the pattern
    v_pattern_regex := REPLACE(v_pattern_regex, '-', '\-');
    
    -- Get highest existing project number with exact pattern match
    EXECUTE format('
        SELECT COALESCE(MAX(CAST(substring(code FROM %L) AS INTEGER)), 0)
        FROM projects 
        WHERE code ~ %L
    ', v_pattern_regex, '^' || v_pattern_regex || '$') INTO v_max_existing;
    
    -- Get highest reserved number for this exact pattern
    SELECT COALESCE(MAX(reserved_number), 0) INTO v_max_reserved
    FROM project_number_reservations
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern  -- Exact pattern match
    AND expires_at > NOW()
    AND is_consumed = false;
    
    -- Get current counter for this exact pattern
    SELECT current_number INTO v_current_counter
    FROM project_numbering_rules
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern  -- Exact pattern match
    AND is_active = true;
    
    -- Calculate next available number
    v_next_number := GREATEST(
        COALESCE(v_max_existing, 0),
        COALESCE(v_max_reserved, 0),
        COALESCE(v_current_counter, 0)
    ) + 1;
    
    -- Generate the code
    v_result := p_pattern;
    v_result := REPLACE(v_result, '{####}', LPAD(v_next_number::VARCHAR, 4, '0'));
    v_result := REPLACE(v_result, '{###}', LPAD(v_next_number::VARCHAR, 3, '0'));
    v_result := REPLACE(v_result, '{##}', LPAD(v_next_number::VARCHAR, 2, '0'));
    v_result := REPLACE(v_result, '{#}', v_next_number::VARCHAR);
    v_result := REPLACE(v_result, '{COMPANY}', p_company_code);
    v_result := REPLACE(v_result, '{YYYY}', EXTRACT(YEAR FROM NOW())::VARCHAR);
    v_result := REPLACE(v_result, '{YY}', RIGHT(EXTRACT(YEAR FROM NOW())::VARCHAR, 2));
    
    -- Reserve the number
    INSERT INTO project_number_reservations (
        entity_type, company_code, pattern, reserved_number, reserved_code, session_id
    ) VALUES (
        p_entity_type, p_company_code, p_pattern, v_next_number, v_result, p_session_id
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
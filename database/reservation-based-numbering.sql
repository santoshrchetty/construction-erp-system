-- Create number reservations table
CREATE TABLE IF NOT EXISTS project_number_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    pattern VARCHAR(200) NOT NULL,
    reserved_number INTEGER NOT NULL,
    reserved_code VARCHAR(200) NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    reserved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 minutes'),
    is_consumed BOOLEAN DEFAULT false
);

-- Create index for cleanup
CREATE INDEX IF NOT EXISTS idx_reservations_expires ON project_number_reservations(expires_at);
CREATE INDEX IF NOT EXISTS idx_reservations_session ON project_number_reservations(session_id);

-- Function to reserve a project number (called during preview)
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
    
    -- Create regex pattern to extract numbers
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
    
    -- Get highest reserved number
    SELECT COALESCE(MAX(reserved_number), 0) INTO v_max_reserved
    FROM project_number_reservations
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern
    AND expires_at > NOW()
    AND is_consumed = false;
    
    -- Get current counter
    SELECT current_number INTO v_current_counter
    FROM project_numbering_rules
    WHERE entity_type = p_entity_type
    AND company_code = p_company_code
    AND pattern = p_pattern
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

-- Function to consume reserved number (called during save)
CREATE OR REPLACE FUNCTION consume_reserved_project_number(
    p_session_id VARCHAR(100),
    p_reserved_code VARCHAR(200)
) RETURNS BOOLEAN AS $$
DECLARE
    v_reservation_exists BOOLEAN := false;
BEGIN
    -- Check if valid reservation exists
    SELECT true INTO v_reservation_exists
    FROM project_number_reservations
    WHERE session_id = p_session_id
    AND reserved_code = p_reserved_code
    AND expires_at > NOW()
    AND is_consumed = false;
    
    IF v_reservation_exists THEN
        -- Mark reservation as consumed
        UPDATE project_number_reservations
        SET is_consumed = true
        WHERE session_id = p_session_id
        AND reserved_code = p_reserved_code;
        
        -- Update the counter to match
        UPDATE project_numbering_rules
        SET current_number = (
            SELECT reserved_number 
            FROM project_number_reservations 
            WHERE session_id = p_session_id AND reserved_code = p_reserved_code
        )
        WHERE pattern = (
            SELECT pattern 
            FROM project_number_reservations 
            WHERE session_id = p_session_id AND reserved_code = p_reserved_code
        );
        
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- Function to release reservation (called on cancel/timeout)
CREATE OR REPLACE FUNCTION release_project_number_reservation(
    p_session_id VARCHAR(100)
) RETURNS VOID AS $$
BEGIN
    DELETE FROM project_number_reservations
    WHERE session_id = p_session_id
    AND is_consumed = false;
END;
$$ LANGUAGE plpgsql;
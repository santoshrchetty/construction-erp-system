-- Step 1: Create the preview function (run this first)
CREATE OR REPLACE FUNCTION preview_project_number_with_pattern(
    p_entity_type TEXT,
    p_company_code TEXT,
    p_pattern TEXT
) RETURNS TEXT AS $$
DECLARE
    v_current_number INTEGER;
    v_new_number INTEGER;
    v_generated_code TEXT;
    v_year TEXT;
    v_company TEXT;
    v_max_existing INTEGER;
BEGIN
    -- Get current number from numbering rules
    SELECT COALESCE(current_number, 0) INTO v_current_number
    FROM project_numbering_rules 
    WHERE entity_type = p_entity_type 
    AND company_code = p_company_code 
    AND pattern = p_pattern;
    
    -- Check actual projects table for highest existing number
    SELECT COALESCE(MAX(
        CASE 
            WHEN code ~ '^HW-[0-9]+$' AND p_pattern LIKE 'HW-%' THEN 
                CAST(SUBSTRING(code FROM 'HW-([0-9]+)') AS INTEGER)
            WHEN code ~ '^P-[0-9]+$' AND p_pattern LIKE 'P-%' THEN 
                CAST(SUBSTRING(code FROM 'P-([0-9]+)') AS INTEGER)
            WHEN code ~ '^BLD-[0-9]+$' AND p_pattern LIKE 'BLD-%' THEN 
                CAST(SUBSTRING(code FROM 'BLD-([0-9]+)') AS INTEGER)
            WHEN code ~ '^INF-[0-9]+$' AND p_pattern LIKE 'INF-%' THEN 
                CAST(SUBSTRING(code FROM 'INF-([0-9]+)') AS INTEGER)
            ELSE 0
        END
    ), 0) INTO v_max_existing
    FROM projects;
    
    -- Calculate next number WITHOUT updating
    v_new_number := GREATEST(v_current_number, v_max_existing) + 1;
    
    -- Generate the code based on pattern
    v_generated_code := p_pattern;
    v_year := EXTRACT(YEAR FROM CURRENT_DATE)::TEXT;
    v_company := p_company_code;
    
    -- Replace placeholders
    v_generated_code := REPLACE(v_generated_code, '{COMPANY}', v_company);
    v_generated_code := REPLACE(v_generated_code, '{YYYY}', v_year);
    v_generated_code := REPLACE(v_generated_code, '{YY}', RIGHT(v_year, 2));
    v_generated_code := REPLACE(v_generated_code, '{####}', LPAD(v_new_number::TEXT, 4, '0'));
    v_generated_code := REPLACE(v_generated_code, '{###}', LPAD(v_new_number::TEXT, 3, '0'));
    
    RETURN v_generated_code;
END;
$$ LANGUAGE plpgsql;
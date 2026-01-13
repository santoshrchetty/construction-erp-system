-- Fix get_number_range_statistics function for mixed data types
-- The function needs to handle VARCHAR current_number and BIGINT from_number/to_number

CREATE OR REPLACE FUNCTION get_number_range_statistics(
    p_company_code VARCHAR(4) DEFAULT NULL
) RETURNS TABLE (
    company_code VARCHAR(4),
    document_type VARCHAR(2),
    total_capacity BIGINT,
    numbers_used BIGINT,
    usage_percentage INTEGER,
    status VARCHAR(20),
    days_since_last_use INTEGER,
    estimated_days_remaining INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dnr.company_code,
        dnr.document_type,
        (dnr.to_number - dnr.from_number + 1) as total_capacity,
        (dnr.current_number::BIGINT - dnr.from_number) as numbers_used,
        calculate_usage_percentage(dnr.current_number::BIGINT, dnr.from_number, dnr.to_number) as usage_percentage,
        dnr.status,
        CASE 
            WHEN dnr.last_used_date IS NULL THEN NULL
            ELSE EXTRACT(DAY FROM (CURRENT_DATE - dnr.last_used_date))::INTEGER
        END as days_since_last_use,
        CASE 
            WHEN dnr.last_used_date IS NULL OR dnr.last_used_date = CURRENT_DATE THEN NULL
            ELSE ((dnr.to_number - dnr.current_number::BIGINT) / 
                  GREATEST(1, (dnr.current_number::BIGINT - dnr.from_number) / 
                  GREATEST(1, EXTRACT(DAY FROM (CURRENT_DATE - dnr.created_at)))))::INTEGER
        END as estimated_days_remaining
    FROM document_number_ranges dnr
    WHERE (p_company_code IS NULL OR dnr.company_code = p_company_code)
    ORDER BY dnr.company_code, dnr.document_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Also fix get_next_number function to handle VARCHAR current_number
CREATE OR REPLACE FUNCTION get_next_number(
    p_company_code VARCHAR(4),
    p_document_type VARCHAR(2),
    p_fiscal_year VARCHAR(4) DEFAULT NULL
) RETURNS VARCHAR(20) AS $$  -- Increased return length to VARCHAR(20)
DECLARE
    v_current_number BIGINT;
    v_to_number BIGINT;
    v_year_dependent BOOLEAN;
    v_prefix VARCHAR(10);
    v_suffix VARCHAR(10);
    v_usage_pct INTEGER;
    v_final_number VARCHAR(20);  -- Increased length
BEGIN
    -- Lock the row for update and cast VARCHAR to BIGINT
    SELECT current_number::BIGINT, to_number, year_dependent, prefix, suffix
    INTO v_current_number, v_to_number, v_year_dependent, v_prefix, v_suffix
    FROM document_number_ranges
    WHERE company_code = p_company_code 
      AND document_type = p_document_type
      AND status = 'ACTIVE'
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No active number range found for company % document type %', p_company_code, p_document_type;
    END IF;
    
    -- Check if range is exhausted
    IF v_current_number >= v_to_number THEN
        RAISE EXCEPTION 'Number range exhausted for company % document type %', p_company_code, p_document_type;
    END IF;
    
    -- Increment current number
    v_current_number := v_current_number + 1;
    
    -- Update current number and last used date (store as VARCHAR)
    UPDATE document_number_ranges
    SET current_number = v_current_number::VARCHAR,
        last_used_date = CURRENT_DATE,
        modified_at = NOW()
    WHERE company_code = p_company_code 
      AND document_type = p_document_type;
    
    -- Build final number with prefix/suffix
    v_final_number := COALESCE(v_prefix, '') || v_current_number::TEXT || COALESCE(v_suffix, '');
    
    -- Log usage
    INSERT INTO number_range_usage_history (company_code, document_type, document_number, used_by)
    VALUES (p_company_code, p_document_type, v_final_number, auth.uid());
    
    -- Check for alerts
    v_usage_pct := calculate_usage_percentage(v_current_number, 
        (SELECT from_number FROM document_number_ranges WHERE company_code = p_company_code AND document_type = p_document_type),
        v_to_number);
    
    IF v_usage_pct >= 95 THEN
        INSERT INTO number_range_alerts (company_code, document_type, alert_type, alert_message, usage_percentage)
        VALUES (p_company_code, p_document_type, 'CRITICAL', 'Number range is 95% exhausted', v_usage_pct)
        ON CONFLICT DO NOTHING;
    ELSIF v_usage_pct >= 80 THEN
        INSERT INTO number_range_alerts (company_code, document_type, alert_type, alert_message, usage_percentage)
        VALUES (p_company_code, p_document_type, 'WARNING', 'Number range is 80% exhausted', v_usage_pct)
        ON CONFLICT DO NOTHING;
    END IF;
    
    RETURN v_final_number;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT 'Functions fixed for mixed data types' as status;
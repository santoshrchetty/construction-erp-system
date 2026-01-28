-- ========================================
-- DOCUMENT NUMBERING SYSTEM - COMPLETE IMPLEMENTATION
-- Version: 2.0
-- Date: 2024-01-26
-- ========================================

-- Step 1: Create document_type_config table
CREATE TABLE IF NOT EXISTS document_type_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(31) NOT NULL,
    base_document_type VARCHAR(10) NOT NULL,
    subtype_code VARCHAR(2) NOT NULL,
    subtype_name VARCHAR(100) NOT NULL,
    description TEXT,
    sap_document_type VARCHAR(10),
    number_range_group VARCHAR(10) NOT NULL,
    format_template VARCHAR(100) NOT NULL,
    number_length INTEGER DEFAULT 6,
    expected_volume VARCHAR(10) DEFAULT 'LOW',
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(company_code, base_document_type, subtype_code)
);

-- Step 2: Create SAP mapping table
CREATE TABLE IF NOT EXISTS sap_document_type_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    our_doc_type VARCHAR(10) NOT NULL,
    our_subtype VARCHAR(2) NOT NULL,
    sap_doc_type VARCHAR(10),
    sap_movement_type VARCHAR(3),
    sap_blart VARCHAR(10),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(our_doc_type, our_subtype)
);

-- Step 3: Update document_number_ranges table (add missing columns)
ALTER TABLE document_number_ranges 
ADD COLUMN IF NOT EXISTS auto_extend BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS extend_by BIGINT DEFAULT 1000000;

-- Step 4: Create number range audit log
CREATE TABLE IF NOT EXISTS number_range_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(31) NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    number_range_group VARCHAR(10),
    action VARCHAR(50) NOT NULL,
    old_value BIGINT,
    new_value BIGINT,
    old_to_number BIGINT,
    new_to_number BIGINT,
    extended_by BIGINT,
    user_id UUID,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Step 5: Create monitoring view
CREATE OR REPLACE VIEW v_number_range_health AS
SELECT 
    company_code,
    document_type,
    number_range_group,
    prefix,
    current_number,
    to_number,
    to_number - current_number as remaining,
    ROUND((current_number::NUMERIC / to_number) * 100, 2) as utilization_pct,
    CASE 
        WHEN current_number >= to_number THEN '🔴 EXHAUSTED'
        WHEN (current_number::NUMERIC / to_number) * 100 >= critical_threshold THEN '🟠 CRITICAL'
        WHEN (current_number::NUMERIC / to_number) * 100 >= warning_threshold THEN '🟡 WARNING'
        ELSE '🟢 OK'
    END as health_status,
    auto_extend,
    extend_by,
    status,
    fiscal_year,
    year_dependent
FROM document_number_ranges
WHERE status = 'ACTIVE'
ORDER BY utilization_pct DESC;

-- Step 6: Create improved RPC function with auto-extension
CREATE OR REPLACE FUNCTION get_next_number_by_group(
    p_company_code VARCHAR,
    p_document_type VARCHAR,
    p_number_range_group VARCHAR,
    p_fiscal_year VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
    v_next_number BIGINT;
    v_to_number BIGINT;
    v_prefix VARCHAR;
    v_auto_extend BOOLEAN;
    v_extend_by BIGINT;
    v_number_length INTEGER;
    v_result VARCHAR;
BEGIN
    -- Try to get next number
    UPDATE document_number_ranges
    SET current_number = current_number + interval_size,
        last_used_date = NOW()
    WHERE company_code = p_company_code
      AND document_type = p_document_type
      AND number_range_group = p_number_range_group
      AND (NOT year_dependent OR fiscal_year::VARCHAR = p_fiscal_year)
      AND status = 'ACTIVE'
      AND current_number < to_number
    RETURNING current_number, to_number, prefix, auto_extend, extend_by 
    INTO v_next_number, v_to_number, v_prefix, v_auto_extend, v_extend_by;
    
    -- If exhausted, try to extend
    IF NOT FOUND THEN
        SELECT to_number, auto_extend, extend_by, prefix 
        INTO v_to_number, v_auto_extend, v_extend_by, v_prefix
        FROM document_number_ranges
        WHERE company_code = p_company_code
          AND document_type = p_document_type
          AND number_range_group = p_number_range_group
          AND (NOT year_dependent OR fiscal_year::VARCHAR = p_fiscal_year)
          AND status = 'ACTIVE';
        
        IF FOUND AND v_auto_extend THEN
            -- Extend the range
            UPDATE document_number_ranges
            SET to_number = to_number + v_extend_by,
                current_number = current_number + interval_size,
                modified_at = NOW()
            WHERE company_code = p_company_code
              AND document_type = p_document_type
              AND number_range_group = p_number_range_group
              AND (NOT year_dependent OR fiscal_year::VARCHAR = p_fiscal_year)
            RETURNING current_number, prefix INTO v_next_number, v_prefix;
            
            -- Log extension
            INSERT INTO number_range_audit_log (
                company_code, document_type, number_range_group,
                action, old_to_number, new_to_number, extended_by, timestamp
            ) VALUES (
                p_company_code, p_document_type, p_number_range_group,
                'AUTO_EXTEND', v_to_number, v_to_number + v_extend_by, v_extend_by, NOW()
            );
        ELSE
            RAISE EXCEPTION 'Number range exhausted for company % document type % group %', 
                p_company_code, p_document_type, p_number_range_group;
        END IF;
    END IF;
    
    -- Get number length from config
    SELECT number_length INTO v_number_length
    FROM document_type_config
    WHERE company_code = p_company_code
      AND base_document_type = p_document_type
      AND subtype_code = p_number_range_group
    LIMIT 1;
    
    -- Default to 6 if not found
    v_number_length := COALESCE(v_number_length, 6);
    
    -- Format result
    v_result := v_prefix || LPAD(v_next_number::VARCHAR, v_number_length, '0');
    
    -- Log generation
    INSERT INTO number_range_audit_log (
        company_code, document_type, number_range_group,
        action, new_value, timestamp
    ) VALUES (
        p_company_code, p_document_type, p_number_range_group,
        'GENERATED', v_next_number, NOW()
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_doc_type_config_lookup 
ON document_type_config(company_code, base_document_type, subtype_code) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_num_range_lookup 
ON document_number_ranges(company_code, document_type, number_range_group, fiscal_year) 
WHERE status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS idx_audit_log_company_type 
ON number_range_audit_log(company_code, document_type, timestamp DESC);

-- Step 8: Create helper function to get fiscal year
CREATE OR REPLACE FUNCTION get_fiscal_year(
    p_date DATE,
    p_fiscal_year_variant VARCHAR DEFAULT 'K4'
) RETURNS INTEGER AS $$
DECLARE
    v_year INTEGER;
    v_month INTEGER;
BEGIN
    v_year := EXTRACT(YEAR FROM p_date);
    v_month := EXTRACT(MONTH FROM p_date);
    
    -- K4: April-March (India)
    IF p_fiscal_year_variant = 'K4' THEN
        IF v_month >= 4 THEN
            RETURN v_year;
        ELSE
            RETURN v_year - 1;
        END IF;
    END IF;
    
    -- V3: January-December (US)
    IF p_fiscal_year_variant = 'V3' THEN
        RETURN v_year;
    END IF;
    
    -- Default: Calendar year
    RETURN v_year;
END;
$$ LANGUAGE plpgsql;

-- Step 9: Grant permissions
GRANT SELECT ON v_number_range_health TO PUBLIC;
GRANT EXECUTE ON FUNCTION get_next_number_by_group TO PUBLIC;
GRANT EXECUTE ON FUNCTION get_fiscal_year TO PUBLIC;

-- Completion message
SELECT 'Document Numbering System - Core Infrastructure Created Successfully!' as status;

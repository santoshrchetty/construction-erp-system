-- Year-Independent Numbering Patterns
-- Patterns that don't include year components

-- Add year-independent pattern examples
INSERT INTO industry_numbering_templates (industry_code, entity_type, pattern, description, is_default) VALUES
-- Year-independent project patterns
('CUSTOM', 'PROJECT', '{COMPANY}-{#####}', 'Simple company-sequence (no year)', false),
('CUSTOM', 'PROJECT', 'P{#####}', 'Simple P-prefix sequential', false),
('CUSTOM', 'PROJECT', '{DEPT}{####}', 'Department-sequence', false),
('CUSTOM', 'PROJECT', '{COMPANY}-{CATEGORY}-{###}', 'Company-category-sequence', false),

-- Construction without year
('CONSTRUCTION', 'PROJECT', 'CONST-{#####}', 'Construction sequential numbering', false),
('CONSTRUCTION', 'PROJECT', '{COMPANY}-BLDG-{###}', 'Building project numbering', false),

-- Manufacturing without year  
('MANUFACTURING', 'PROJECT', 'MFG-{PLANT}-{####}', 'Plant-based sequential', false),
('MANUFACTURING', 'PROJECT', '{PLANT}-PROD-{###}', 'Production project numbering', false),

-- IT without year
('IT', 'PROJECT', 'IT-{#####}', 'IT sequential numbering', false),
('IT', 'PROJECT', '{SYSTEM}-{###}', 'System-based numbering', false),

-- Oil & Gas without year
('OIL_GAS', 'PROJECT', '{FIELD}-{####}', 'Field-based sequential', false),
('OIL_GAS', 'PROJECT', 'DRILL-{#####}', 'Drilling project sequential', false)
ON CONFLICT DO NOTHING;

-- Update pattern validation to allow year-independent patterns
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
            -- PROJECT patterns must have at least one numbering placeholder
            IF p_pattern !~ '\{(#####|####|###|##|#)\}' THEN
                v_errors := array_append(v_errors, 'PROJECT patterns must include at least one numbering placeholder');
            END IF;
            -- Warn if no year but don't require it
            IF p_pattern !~ '\{(YYYY|YY)\}' THEN
                v_warnings := array_append(v_warnings, 'Pattern does not include year - numbers will be continuous across years');
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

-- Examples of year-independent patterns in use:

-- EXAMPLES WITHOUT YEAR:
-- ======================

-- Simple Sequential:
-- P00001, P00002, P00003, P00004...

-- Company-Sequential:
-- ABC-00001, ABC-00002, ABC-00003...

-- Department-Sequential:
-- IT0001, IT0002, IT0003...
-- CONST001, CONST002, CONST003...

-- Category-Based:
-- ABC-CUSTOMER-001, ABC-CUSTOMER-002...
-- ABC-CAPITAL-001, ABC-CAPITAL-002...

-- Plant-Based Manufacturing:
-- TX01-0001, TX01-0002, TX01-0003...
-- CA02-0001, CA02-0002, CA02-0003...

-- Field-Based Oil & Gas:
-- GULF-0001, GULF-0002, GULF-0003...
-- NORTH-0001, NORTH-0002, NORTH-0003...

-- System-Based IT:
-- ERP-001, ERP-002, ERP-003...
-- CRM-001, CRM-002, CRM-003...

-- ADVANTAGES OF YEAR-INDEPENDENT PATTERNS:
-- ========================================
-- 1. Simpler numbering scheme
-- 2. Continuous sequence across years
-- 3. Shorter project IDs
-- 4. No year rollover complexity
-- 5. Better for long-running projects
-- 6. Easier external system integration

-- DISADVANTAGES:
-- ==============
-- 1. No automatic year identification
-- 2. Potential for very large numbers over time
-- 3. Less audit trail visibility
-- 4. May not meet some compliance requirements

-- HYBRID APPROACH:
-- ================
-- Companies can use both approaches:
-- - Year-dependent for financial/compliance projects
-- - Year-independent for operational/internal projects
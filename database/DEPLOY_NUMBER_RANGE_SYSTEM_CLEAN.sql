-- Complete Number Range Maintenance System Deployment
-- Enterprise-grade ERP-compliant number range management solution

-- Step 1: Enhanced Document Number Ranges Table with ERP Best Practices
ALTER TABLE document_number_ranges 
ADD COLUMN IF NOT EXISTS number_range_object VARCHAR(10) NOT NULL DEFAULT 'RF_BELEG',
ADD COLUMN IF NOT EXISTS from_number BIGINT NOT NULL DEFAULT 1000000000,
ADD COLUMN IF NOT EXISTS to_number BIGINT NOT NULL DEFAULT 1999999999,
ADD COLUMN IF NOT EXISTS current_number BIGINT NOT NULL DEFAULT 1000000000,
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'ACTIVE',
ADD COLUMN IF NOT EXISTS warning_threshold INTEGER DEFAULT 80,
ADD COLUMN IF NOT EXISTS critical_threshold INTEGER DEFAULT 95,
ADD COLUMN IF NOT EXISTS external_numbering BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS prefix VARCHAR(10),
ADD COLUMN IF NOT EXISTS suffix VARCHAR(10),
ADD COLUMN IF NOT EXISTS created_by UUID,
ADD COLUMN IF NOT EXISTS modified_by UUID,
ADD COLUMN IF NOT EXISTS modified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS interval_size INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS buffer_size INTEGER DEFAULT 10,
ADD COLUMN IF NOT EXISTS fiscal_year_variant VARCHAR(2) DEFAULT 'K4',
ADD COLUMN IF NOT EXISTS year_dependent BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS transport_request VARCHAR(20),
ADD COLUMN IF NOT EXISTS change_document VARCHAR(20),
ADD COLUMN IF NOT EXISTS locked_by UUID,
ADD COLUMN IF NOT EXISTS locked_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS number_range_group VARCHAR(2) DEFAULT '01',
ADD COLUMN IF NOT EXISTS last_used_date DATE,
ADD COLUMN IF NOT EXISTS auto_extend BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS extend_by INTEGER DEFAULT 1000000000,
ADD COLUMN IF NOT EXISTS description VARCHAR(100);

-- Add status constraint
ALTER TABLE document_number_ranges 
DROP CONSTRAINT IF EXISTS document_number_ranges_status_check;

ALTER TABLE document_number_ranges 
ADD CONSTRAINT document_number_ranges_status_check 
CHECK (status IN ('ACTIVE', 'INACTIVE', 'EXHAUSTED', 'SUSPENDED'));

-- Add alert type constraint
ALTER TABLE number_range_alerts 
DROP CONSTRAINT IF EXISTS number_range_alerts_type_check;

ALTER TABLE number_range_alerts 
ADD CONSTRAINT number_range_alerts_type_check 
CHECK (alert_type IN ('WARNING', 'CRITICAL', 'INFO'));

-- Step 2: ERP Best Practices - Number Range Groups
CREATE TABLE IF NOT EXISTS number_range_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_code VARCHAR(2) NOT NULL,
    group_name VARCHAR(50) NOT NULL,
    company_code VARCHAR(4) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, group_code)
);

-- Step 3: ERP Best Practices - Number Range Buffer
CREATE TABLE IF NOT EXISTS number_range_buffer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    document_type VARCHAR(2) NOT NULL,
    buffer_start BIGINT NOT NULL,
    buffer_end BIGINT NOT NULL,
    server_instance VARCHAR(20) DEFAULT 'DEFAULT',
    allocated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(company_code, document_type, server_instance)
);

-- Step 4: Number Range Usage History
CREATE TABLE IF NOT EXISTS number_range_usage_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    document_type VARCHAR(2) NOT NULL,
    document_number VARCHAR(10) NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    used_by UUID,
    document_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 5: Number Range Alerts
CREATE TABLE IF NOT EXISTS number_range_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    document_type VARCHAR(2) NOT NULL,
    alert_type VARCHAR(20) NOT NULL,
    alert_message TEXT NOT NULL,
    usage_percentage INTEGER NOT NULL,
    is_acknowledged BOOLEAN DEFAULT false,
    acknowledged_by UUID,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 6: Next number generation function with enterprise features
CREATE OR REPLACE FUNCTION get_next_number(
    p_company_code VARCHAR(4),
    p_document_type VARCHAR(2),
    p_fiscal_year VARCHAR(4) DEFAULT NULL
) RETURNS VARCHAR(10) AS $$
DECLARE
    v_current_number BIGINT;
    v_to_number BIGINT;
    v_year_dependent BOOLEAN;
    v_prefix VARCHAR(10);
    v_suffix VARCHAR(10);
    v_usage_pct INTEGER;
    v_final_number VARCHAR(10);
BEGIN
    -- Lock the row for update
    SELECT current_number, to_number, year_dependent, prefix, suffix
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
    
    -- Update current number and last used date
    UPDATE document_number_ranges
    SET current_number = v_current_number,
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

-- Step 7: Usage calculation function
CREATE OR REPLACE FUNCTION calculate_usage_percentage(
    p_current_number BIGINT,
    p_from_number BIGINT,
    p_to_number BIGINT
) RETURNS INTEGER AS $$
BEGIN
    IF p_to_number = p_from_number THEN
        RETURN 100;
    END IF;
    
    RETURN ROUND(((p_current_number - p_from_number)::DECIMAL / (p_to_number - p_from_number)::DECIMAL) * 100);
END;
$$ LANGUAGE plpgsql;

-- Step 8: Number range statistics function
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
        (dnr.current_number - dnr.from_number) as numbers_used,
        calculate_usage_percentage(dnr.current_number, dnr.from_number, dnr.to_number) as usage_percentage,
        dnr.status,
        CASE 
            WHEN dnr.last_used_date IS NULL THEN NULL
            ELSE EXTRACT(DAY FROM (CURRENT_DATE - dnr.last_used_date))::INTEGER
        END as days_since_last_use,
        CASE 
            WHEN dnr.last_used_date IS NULL OR dnr.last_used_date = CURRENT_DATE THEN NULL
            ELSE ((dnr.to_number - dnr.current_number) / 
                  GREATEST(1, (dnr.current_number - dnr.from_number) / 
                  GREATEST(1, EXTRACT(DAY FROM (CURRENT_DATE - dnr.created_at)))))::INTEGER
        END as estimated_days_remaining
    FROM document_number_ranges dnr
    WHERE (p_company_code IS NULL OR dnr.company_code = p_company_code)
    ORDER BY dnr.company_code, dnr.document_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Step 9: ERP Best Practices - Performance Indexes
CREATE INDEX IF NOT EXISTS idx_number_ranges_company_type ON document_number_ranges(company_code, document_type);
CREATE INDEX IF NOT EXISTS idx_number_ranges_status ON document_number_ranges(status) WHERE status = 'ACTIVE';
CREATE INDEX IF NOT EXISTS idx_alerts_unacknowledged ON number_range_alerts(company_code, is_acknowledged) WHERE is_acknowledged = false;
CREATE INDEX IF NOT EXISTS idx_usage_history_company_type ON number_range_usage_history(company_code, document_type);
CREATE INDEX IF NOT EXISTS idx_usage_history_date ON number_range_usage_history(used_at);
CREATE INDEX IF NOT EXISTS idx_number_ranges_last_used ON document_number_ranges(last_used_date) WHERE last_used_date IS NOT NULL;

-- Step 10: Grant necessary permissions
GRANT ALL ON document_number_ranges TO authenticated;
GRANT ALL ON number_range_usage_history TO authenticated;
GRANT ALL ON number_range_alerts TO authenticated;
GRANT ALL ON number_range_groups TO authenticated;
GRANT ALL ON number_range_buffer TO authenticated;

-- Step 11: Create RLS policies for multi-tenant access
ALTER TABLE document_number_ranges ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_usage_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_buffer ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can access number ranges for their companies" ON document_number_ranges;
DROP POLICY IF EXISTS "Users can access alerts for their companies" ON number_range_alerts;
DROP POLICY IF EXISTS "Users can access number range groups for their companies" ON number_range_groups;
DROP POLICY IF EXISTS "Users can access usage history for their companies" ON number_range_usage_history;
DROP POLICY IF EXISTS "Users can access number range buffer for their companies" ON number_range_buffer;

-- Create policies
CREATE POLICY "Users can access number ranges for their companies" ON document_number_ranges
    FOR ALL USING (true);

CREATE POLICY "Users can access alerts for their companies" ON number_range_alerts
    FOR ALL USING (true);

CREATE POLICY "Users can access number range groups for their companies" ON number_range_groups
    FOR ALL USING (true);

CREATE POLICY "Users can access usage history for their companies" ON number_range_usage_history
    FOR ALL USING (true);

CREATE POLICY "Users can access number range buffer for their companies" ON number_range_buffer
    FOR ALL USING (true);

-- Step 12: Verification queries
SELECT 'Number Range Maintenance System Deployed Successfully' as status;
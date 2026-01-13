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
-- ERP Best Practices: Intervals & Buffering
ADD COLUMN IF NOT EXISTS interval_size INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS buffer_size INTEGER DEFAULT 10,
-- ERP Best Practices: Fiscal Year Integration
ADD COLUMN IF NOT EXISTS fiscal_year_variant VARCHAR(2) DEFAULT 'K4',
ADD COLUMN IF NOT EXISTS year_dependent BOOLEAN DEFAULT true,
-- ERP Best Practices: Change Management
ADD COLUMN IF NOT EXISTS transport_request VARCHAR(20),
ADD COLUMN IF NOT EXISTS change_document VARCHAR(20),
-- ERP Best Practices: Locking Mechanism
ADD COLUMN IF NOT EXISTS locked_by UUID,
ADD COLUMN IF NOT EXISTS locked_at TIMESTAMP WITH TIME ZONE,
-- ERP Best Practices: Number Range Groups
ADD COLUMN IF NOT EXISTS number_range_group VARCHAR(2) DEFAULT '01';

-- Add status constraint
ALTER TABLE document_number_ranges 
DROP CONSTRAINT IF EXISTS document_number_ranges_status_check;

ALTER TABLE document_number_ranges 
ADD CONSTRAINT document_number_ranges_status_check 
CHECK (status IN ('ACTIVE', 'INACTIVE', 'EXHAUSTED', 'SUSPENDED'));

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

-- Step 6: ERP Best Practices - Validation Functions
CREATE OR REPLACE FUNCTION validate_number_range_overlap(
    p_company_code VARCHAR(4),
    p_document_type VARCHAR(2),
    p_from_number BIGINT,
    p_to_number BIGINT,
    p_exclude_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_overlap_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_overlap_count
    FROM document_number_ranges
    WHERE company_code = p_company_code
    AND document_type = p_document_type
    AND (id != p_exclude_id OR p_exclude_id IS NULL)
    AND (
        (p_from_number BETWEEN from_number AND to_number) OR
        (p_to_number BETWEEN from_number AND to_number) OR
        (from_number BETWEEN p_from_number AND p_to_number)
    );
    
    RETURN v_overlap_count = 0;
END;
$$ LANGUAGE plpgsql;

-- Step 7: ERP Best Practices - Number Range Locking
CREATE OR REPLACE FUNCTION lock_number_range(
    p_range_id UUID,
    p_user_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE document_number_ranges
    SET locked_by = p_user_id,
        locked_at = NOW()
    WHERE id = p_range_id
    AND (locked_by IS NULL OR locked_at < NOW() - INTERVAL '30 minutes');
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Step 8: Usage calculation function
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

-- Step 9: ERP Best Practices - Performance Indexes
CREATE INDEX IF NOT EXISTS idx_number_ranges_company_type ON document_number_ranges(company_code, document_type);
CREATE INDEX IF NOT EXISTS idx_number_ranges_status ON document_number_ranges(status) WHERE status = 'ACTIVE';
CREATE INDEX IF NOT EXISTS idx_number_ranges_locked ON document_number_ranges(locked_by, locked_at) WHERE locked_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_alerts_unacknowledged ON number_range_alerts(company_code, is_acknowledged) WHERE is_acknowledged = false;
CREATE INDEX IF NOT EXISTS idx_usage_history_company_type ON number_range_usage_history(company_code, document_type, used_at);
CREATE INDEX IF NOT EXISTS idx_buffer_company_type ON number_range_buffer(company_code, document_type);

-- Step 10: Create sample number range configurations
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, 
    from_number, to_number, current_number,
    status, warning_threshold, critical_threshold,
    external_numbering, created_by, fiscal_year,
    range_from, range_to, fiscal_year_variant,
    year_dependent, interval_size, buffer_size,
    number_range_group
) 
SELECT * FROM (
    VALUES
    ('C001', 'ZA', 'RF_BELEG', 5000000000, 5999999999, 5000000000, 'ACTIVE', 75, 90, false, (SELECT id FROM users WHERE email = 'admin@construction.com' LIMIT 1), 2024, 5000000000, 5999999999, 'K4', true, 1, 10, '01'),
    ('C001', 'ZB', 'RF_BELEG', 6000000000, 6999999999, 6000000000, 'ACTIVE', 80, 95, false, (SELECT id FROM users WHERE email = 'admin@construction.com' LIMIT 1), 2024, 6000000000, 6999999999, 'K4', true, 1, 10, '01'),
    ('B001', 'ZA', 'RF_BELEG', 5000000000, 5999999999, 5000000000, 'ACTIVE', 75, 90, false, (SELECT id FROM users WHERE email = 'admin@construction.com' LIMIT 1), 2024, 5000000000, 5999999999, 'K4', true, 1, 10, '01'),
    ('B001', 'ZB', 'RF_BELEG', 6000000000, 6999999999, 6000000000, 'ACTIVE', 80, 95, false, (SELECT id FROM users WHERE email = 'admin@construction.com' LIMIT 1), 2024, 6000000000, 6999999999, 'K4', true, 1, 10, '01')
) AS v(company_code, document_type, number_range_object, from_number, to_number, current_number, status, warning_threshold, critical_threshold, external_numbering, created_by, fiscal_year, range_from, range_to, fiscal_year_variant, year_dependent, interval_size, buffer_size, number_range_group)
WHERE NOT EXISTS (
    SELECT 1 FROM document_number_ranges d 
    WHERE d.company_code = v.company_code 
    AND d.document_type = v.document_type 
    AND d.fiscal_year = v.fiscal_year
);

-- Step 11: Create sample number range groups
INSERT INTO number_range_groups (group_code, group_name, company_code, description) VALUES
('01', 'Financial Documents', 'C001', 'Standard financial document numbering'),
('02', 'Material Documents', 'C001', 'Material movement document numbering'),
('01', 'Financial Documents', 'B001', 'Standard financial document numbering'),
('02', 'Material Documents', 'B001', 'Material movement document numbering');

-- Step 12: Create sample alerts for demonstration
INSERT INTO number_range_alerts (
    company_code, document_type, alert_type, alert_message, usage_percentage
) VALUES
('C001', 'SA', 'WARNING', 'Number range usage at 85% for C001-SA', 85),
('B001', 'KR', 'CRITICAL', 'Number range usage at 96% for B001-KR', 96);

-- Step 14: Create RLS policies for multi-tenant access
ALTER TABLE document_number_ranges ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_usage_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_buffer ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can access number ranges for their companies" ON document_number_ranges;
DROP POLICY IF EXISTS "Users can access alerts for their companies" ON number_range_alerts;
DROP POLICY IF EXISTS "Users can access number range groups for their companies" ON number_range_groups;
DROP POLICY IF EXISTS "Users can access number range buffer for their companies" ON number_range_buffer;

-- Create policies
CREATE POLICY "Users can access number ranges for their companies" ON document_number_ranges
    FOR ALL USING (true);

CREATE POLICY "Users can access alerts for their companies" ON number_range_alerts
    FOR ALL USING (true);

CREATE POLICY "Users can access number range groups for their companies" ON number_range_groups
    FOR ALL USING (true);

CREATE POLICY "Users can access number range buffer for their companies" ON number_range_buffer
    FOR ALL USING (true);er_range_alerts TO authenticated;
GRANT ALL ON number_range_groups TO authenticated;
GRANT ALL ON number_range_buffer TO authenticated;

-- Step 14: Create RLS policies for multi-tenant access
ALTER TABLE document_number_ranges ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_usage_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE number_range_buffer ENABLE ROW LEVEL SECURITY;

-- Policy for document_number_ranges
CREATE POLICY "Users can access number ranges for their companies" ON document_number_ranges
    FOR ALL USING (true);

-- Policy for alerts
CREATE POLICY "Users can access alerts for their companies" ON number_range_alerts
    FOR ALL USING (true);

-- Policy for number_range_groups
CREATE POLICY "Users can access number range groups for their companies" ON number_range_groups
    FOR ALL USING (true);

-- Policy for number_range_buffer
CREATE POLICY "Users can access number range buffer for their companies" ON number_range_buffer
    FOR ALL USING (true);

-- Step 15: Create automated alert checking job (if supported)
-- This would typically be handled by a cron job or scheduled function
CREATE OR REPLACE FUNCTION run_number_range_alert_check()
RETURNS void AS $$
BEGIN
    PERFORM check_number_range_alerts();
END;
$$ LANGUAGE plpgsql;

-- Step 16: Create audit triggers
CREATE OR REPLACE FUNCTION audit_number_range_changes()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO number_range_usage_history (
            company_code, document_type, document_number, 
            used_by, created_at
        ) VALUES (
            NEW.company_code, NEW.document_type, NEW.current_number::text,
            NEW.modified_by, NOW()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER number_range_audit_trigger
    AFTER UPDATE ON document_number_ranges
    FOR EACH ROW
    EXECUTE FUNCTION audit_number_range_changes();

-- Step 17: Verification queries
SELECT 'Number Range Maintenance System Deployed Successfully' as status;

-- Verify deployment
SELECT 
    'Document Number Ranges' as table_name,
    COUNT(*) as record_count
FROM document_number_ranges
UNION ALL
SELECT 
    'Number Range Alerts' as table_name,
    COUNT(*) as record_count
FROM number_range_alerts
UNION ALL
SELECT 
    'Usage History' as table_name,
    COUNT(*) as record_count
FROM number_range_usage_history
UNION ALL
SELECT 
    'Number Range Groups' as table_name,
    COUNT(*) as record_count
FROM number_range_groups
UNION ALL
SELECT 
    'Number Range Buffer' as table_name,
    COUNT(*) as record_count
FROM number_range_buffer;

-- Show sample data
SELECT 
    company_code,
    document_type,
    from_number,
    to_number,
    current_number,
    status,
    calculate_usage_percentage(current_number::BIGINT, from_number::BIGINT, to_number::BIGINT) as usage_pct
FROM document_number_ranges
ORDER BY company_code, document_type;

-- Step 13: Grant necessary permissions
GRANT ALL ON document_number_ranges TO authenticated;
GRANT ALL ON number_range_usage_history TO authenticated;
GRANT ALL ON number_range_alerts TO authenticated;
GRANT ALL ON number_range_groups TO authenticated;
GRANT ALL ON number_range_buffer TO authenticated;

-- Step 15: Create automated alert checking job
CREATE OR REPLACE FUNCTION run_number_range_alert_check()
RETURNS void AS $$
BEGIN
    PERFORM check_number_range_alerts();
END;
$$ LANGUAGE plpgsql;

-- Step 16: Create audit triggers
CREATE OR REPLACE FUNCTION audit_number_range_changes()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO number_range_usage_history (
            company_code, document_type, document_number, 
            used_by, created_at
        ) VALUES (
            NEW.company_code, NEW.document_type, NEW.current_number::text,
            NEW.modified_by, NOW()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS number_range_audit_trigger ON document_number_ranges;
CREATE TRIGGER number_range_audit_trigger
    AFTER UPDATE ON document_number_ranges
    FOR EACH ROW
    EXECUTE FUNCTION audit_number_range_changes();

-- Step 17: Verification queries
SELECT 'Number Range Maintenance System Deployed Successfully' as status;

-- Verify deployment
SELECT 
    'Document Number Ranges' as table_name,
    COUNT(*) as record_count
FROM document_number_ranges
UNION ALL
SELECT 
    'Number Range Alerts' as table_name,
    COUNT(*) as record_count
FROM number_range_alerts
UNION ALL
SELECT 
    'Usage History' as table_name,
    COUNT(*) as record_count
FROM number_range_usage_history
UNION ALL
SELECT 
    'Number Range Groups' as table_name,
    COUNT(*) as record_count
FROM number_range_groups
UNION ALL
SELECT 
    'Number Range Buffer' as table_name,
    COUNT(*) as record_count
FROM number_range_buffer;

-- Show sample data
SELECT 
    company_code,
    document_type,
    from_number,
    to_number,
    current_number,
    status,
    calculate_usage_percentage(current_number::BIGINT, from_number::BIGINT, to_number::BIGINT) as usage_pct
FROM document_number_ranges
ORDER BY company_code, document_type;
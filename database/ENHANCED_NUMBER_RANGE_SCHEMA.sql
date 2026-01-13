-- Enhanced Number Range Management Schema
-- Enterprise-grade number range configuration

-- Enhanced Document Number Ranges Table
ALTER TABLE document_number_ranges 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'ACTIVE',
ADD COLUMN IF NOT EXISTS warning_threshold INTEGER DEFAULT 80,
ADD COLUMN IF NOT EXISTS critical_threshold INTEGER DEFAULT 95,
ADD COLUMN IF NOT EXISTS external_numbering BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS prefix VARCHAR(10),
ADD COLUMN IF NOT EXISTS suffix VARCHAR(10),
ADD COLUMN IF NOT EXISTS created_by UUID,
ADD COLUMN IF NOT EXISTS modified_by UUID,
ADD COLUMN IF NOT EXISTS modified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Add status constraint
ALTER TABLE document_number_ranges 
DROP CONSTRAINT IF EXISTS document_number_ranges_status_check;

ALTER TABLE document_number_ranges 
ADD CONSTRAINT document_number_ranges_status_check 
CHECK (status IN ('ACTIVE', 'INACTIVE', 'EXHAUSTED', 'SUSPENDED'));

-- Number Range Usage History
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

-- Number Range Alerts
CREATE TABLE IF NOT EXISTS number_range_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    document_type VARCHAR(2) NOT NULL,
    alert_type VARCHAR(20) NOT NULL, -- WARNING, CRITICAL, EXHAUSTED
    alert_message TEXT NOT NULL,
    usage_percentage INTEGER NOT NULL,
    is_acknowledged BOOLEAN DEFAULT false,
    acknowledged_by UUID,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_number_range_usage_company ON number_range_usage_history(company_code, document_type);
CREATE INDEX IF NOT EXISTS idx_number_range_alerts_status ON number_range_alerts(company_code, is_acknowledged);
CREATE INDEX IF NOT EXISTS idx_document_number_ranges_status ON document_number_ranges(company_code, status);

-- Function to calculate usage percentage
CREATE OR REPLACE FUNCTION calculate_usage_percentage(
    p_current_number INTEGER,
    p_from_number INTEGER,
    p_to_number INTEGER
) RETURNS INTEGER AS $$
BEGIN
    IF p_to_number = p_from_number THEN
        RETURN 100;
    END IF;
    
    RETURN ROUND(((p_current_number - p_from_number)::DECIMAL / (p_to_number - p_from_number)::DECIMAL) * 100);
END;
$$ LANGUAGE plpgsql;

-- Function to check and create alerts
CREATE OR REPLACE FUNCTION check_number_range_alerts() RETURNS VOID AS $$
DECLARE
    range_record RECORD;
    usage_pct INTEGER;
    alert_type VARCHAR(20);
    alert_msg TEXT;
BEGIN
    FOR range_record IN 
        SELECT * FROM document_number_ranges WHERE status = 'ACTIVE'
    LOOP
        usage_pct := calculate_usage_percentage(
            range_record.current_number,
            range_record.from_number,
            range_record.to_number
        );
        
        IF usage_pct >= 100 THEN
            alert_type := 'EXHAUSTED';
            alert_msg := 'Number range exhausted for ' || range_record.company_code || '-' || range_record.document_type;
            
            UPDATE document_number_ranges 
            SET status = 'EXHAUSTED' 
            WHERE id = range_record.id;
            
        ELSIF usage_pct >= range_record.critical_threshold THEN
            alert_type := 'CRITICAL';
            alert_msg := 'Critical usage (' || usage_pct || '%) for ' || range_record.company_code || '-' || range_record.document_type;
            
        ELSIF usage_pct >= range_record.warning_threshold THEN
            alert_type := 'WARNING';
            alert_msg := 'Warning usage (' || usage_pct || '%) for ' || range_record.company_code || '-' || range_record.document_type;
        ELSE
            CONTINUE;
        END IF;
        
        -- Insert alert if not already exists
        INSERT INTO number_range_alerts (
            company_code, document_type, alert_type, alert_message, usage_percentage
        )
        SELECT range_record.company_code, range_record.document_type, alert_type, alert_msg, usage_pct
        WHERE NOT EXISTS (
            SELECT 1 FROM number_range_alerts 
            WHERE company_code = range_record.company_code 
            AND document_type = range_record.document_type 
            AND alert_type = alert_type 
            AND is_acknowledged = false
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT 'Enhanced number range schema created successfully' as status;
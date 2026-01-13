-- GL Posting Configuration System
-- Eliminates hardcoded business rules

-- Create system configuration table
CREATE TABLE IF NOT EXISTS gl_posting_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    config_key VARCHAR(50) NOT NULL,
    config_value TEXT NOT NULL,
    data_type VARCHAR(20) NOT NULL DEFAULT 'string',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_code, config_key)
);

-- Enable RLS
ALTER TABLE gl_posting_config ENABLE ROW LEVEL SECURITY;

-- RLS Policy
CREATE POLICY "gl_posting_config_policy" ON gl_posting_config
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_company_access uca 
            WHERE uca.user_id = auth.uid() 
            AND uca.company_code = gl_posting_config.company_code
        )
    );

-- Insert default configurations
INSERT INTO gl_posting_config (company_code, config_key, config_value, data_type, description) VALUES
('1000', 'balance_tolerance', '0.01', 'decimal', 'Maximum allowed difference for balanced documents'),
('1000', 'minimum_entries', '2', 'integer', 'Minimum number of journal entries required'),
('1000', 'allow_zero_amounts', 'false', 'boolean', 'Allow journal entries with zero amounts'),
('1000', 'require_cost_center', 'false', 'boolean', 'Require cost center for all entries'),
('1000', 'require_project', 'false', 'boolean', 'Require project/WBS for all entries')
ON CONFLICT (company_code, config_key) DO NOTHING;

-- Function to get GL posting configuration
CREATE OR REPLACE FUNCTION get_gl_posting_config(
    p_company_code VARCHAR(4),
    p_config_key VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
    config_key VARCHAR(50),
    config_value TEXT,
    data_type VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gpc.config_key,
        gpc.config_value,
        gpc.data_type
    FROM gl_posting_config gpc
    WHERE gpc.company_code = p_company_code
    AND gpc.is_active = true
    AND (p_config_key IS NULL OR gpc.config_key = p_config_key)
    ORDER BY gpc.config_key;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT SELECT ON gl_posting_config TO authenticated;
GRANT EXECUTE ON FUNCTION get_gl_posting_config TO authenticated;
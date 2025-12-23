-- Add Controlling Areas table if it doesn't exist
CREATE TABLE IF NOT EXISTS controlling_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cocarea_code VARCHAR(4) UNIQUE NOT NULL,
    cocarea_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    fiscal_year_variant VARCHAR(2) DEFAULT 'K4',
    chart_of_accounts_id UUID REFERENCES chart_of_accounts(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add controlling area assignment to company codes
ALTER TABLE company_codes 
ADD COLUMN IF NOT EXISTS controlling_area_code VARCHAR(4);

-- Insert sample controlling areas
INSERT INTO controlling_areas (cocarea_code, cocarea_name, currency, fiscal_year_variant) VALUES
('1000', 'Construction Controlling Area', 'USD', 'K4'),
('2000', 'Projects Controlling Area', 'USD', 'K4')
ON CONFLICT (cocarea_code) DO NOTHING;

-- Update company codes with controlling area assignments
UPDATE company_codes 
SET controlling_area_code = '1000' 
WHERE company_code IN ('C001', 'C002');

-- Verify the setup
SELECT 
    cc.company_code,
    cc.company_name,
    cc.controlling_area_code,
    ca.cocarea_name
FROM company_codes cc
LEFT JOIN controlling_areas ca ON cc.controlling_area_code = ca.cocarea_code;
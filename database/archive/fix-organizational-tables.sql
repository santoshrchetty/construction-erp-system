-- Check existing table structure
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'cost_centers' ORDER BY ordinal_position;

-- Add missing columns if they don't exist
ALTER TABLE cost_centers ADD COLUMN IF NOT EXISTS cost_center_id VARCHAR(20);
ALTER TABLE cost_centers ADD COLUMN IF NOT EXISTS cost_center_name VARCHAR(255);
ALTER TABLE cost_centers ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS profit_center_id VARCHAR(20);
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS profit_center_name VARCHAR(255);
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

ALTER TABLE plants ADD COLUMN IF NOT EXISTS plant_id VARCHAR(20);
ALTER TABLE plants ADD COLUMN IF NOT EXISTS plant_name VARCHAR(255);
ALTER TABLE plants ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE plants ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

-- Insert data using existing column names
INSERT INTO cost_centers (cost_center_id, cost_center_name, company_code) VALUES
('CC001', 'Construction Operations', 'C001'),
('CC002', 'Project Management', 'C001'),
('CC003', 'Engineering Services', 'C001')
ON CONFLICT DO NOTHING;

INSERT INTO profit_centers (profit_center_id, profit_center_name, company_code) VALUES
('PC001', 'Residential Construction', 'C001'),
('PC002', 'Commercial Construction', 'C001')
ON CONFLICT DO NOTHING;

INSERT INTO plants (plant_id, plant_name, address, company_code) VALUES
('PL001', 'Main Construction Site', '123 Construction Ave', 'C001'),
('PL002', 'Equipment Yard', '456 Equipment Blvd', 'C001')
ON CONFLICT DO NOTHING;
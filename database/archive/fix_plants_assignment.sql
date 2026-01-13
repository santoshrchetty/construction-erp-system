-- Add company_code_id to plants table for proper assignment
ALTER TABLE plants 
ADD COLUMN IF NOT EXISTS company_code_id UUID REFERENCES company_codes(id);

-- Insert sample plants with company code assignments
INSERT INTO plants (plant_code, plant_name, company_code_id, address) VALUES
('P001', 'Main Construction Plant', (SELECT id FROM company_codes WHERE company_code = 'C001'), 'Main Construction Site, City A'),
('P002', 'Secondary Plant', (SELECT id FROM company_codes WHERE company_code = 'C001'), 'Secondary Site, City B'),
('P003', 'Project Plant Alpha', (SELECT id FROM company_codes WHERE company_code = 'C002'), 'Project Alpha Location')
ON CONFLICT (plant_code) DO NOTHING;

-- Update existing plants with company assignments if they don't have them
UPDATE plants 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'C001' LIMIT 1)
WHERE company_code_id IS NULL;

-- Add storage locations for the plants (using correct column names)
INSERT INTO storage_locations (sloc_code, sloc_name, plant_id, location_type) VALUES
('0001', 'Main Warehouse', (SELECT id FROM plants WHERE plant_code = 'P001'), 'Warehouse'),
('0002', 'Raw Materials Store', (SELECT id FROM plants WHERE plant_code = 'P001'), 'Raw Materials'),
('0003', 'Finished Goods Store', (SELECT id FROM plants WHERE plant_code = 'P001'), 'Finished Goods'),
('0001', 'Secondary Warehouse', (SELECT id FROM plants WHERE plant_code = 'P002'), 'Warehouse'),
('0001', 'Project Alpha Store', (SELECT id FROM plants WHERE plant_code = 'P003'), 'Project Store')
ON CONFLICT (plant_id, sloc_code) DO NOTHING;

-- Verify plant and company assignments
SELECT 
    p.plant_code,
    p.plant_name,
    cc.company_code,
    cc.company_name,
    COUNT(sl.id) as storage_locations_count
FROM plants p
JOIN company_codes cc ON p.company_code_id = cc.id
LEFT JOIN storage_locations sl ON p.id = sl.plant_id
GROUP BY p.plant_code, p.plant_name, cc.company_code, cc.company_name
ORDER BY p.plant_code;
-- Update existing cost_centers with cost_center_code
UPDATE cost_centers SET cost_center_code = 'CC001' WHERE cost_center_name = 'Construction Operations';
UPDATE cost_centers SET cost_center_code = 'CC002' WHERE cost_center_name = 'Project Management';
UPDATE cost_centers SET cost_center_code = 'CC003' WHERE cost_center_name = 'Engineering Services';

-- Insert new records if they don't exist
INSERT INTO cost_centers (cost_center_code, cost_center_name, company_code) 
SELECT 'CC001', 'Construction Operations', 'C001'
WHERE NOT EXISTS (SELECT 1 FROM cost_centers WHERE cost_center_code = 'CC001');

INSERT INTO cost_centers (cost_center_code, cost_center_name, company_code) 
SELECT 'CC002', 'Project Management', 'C001'
WHERE NOT EXISTS (SELECT 1 FROM cost_centers WHERE cost_center_code = 'CC002');

INSERT INTO cost_centers (cost_center_code, cost_center_name, company_code) 
SELECT 'CC003', 'Engineering Services', 'C001'
WHERE NOT EXISTS (SELECT 1 FROM cost_centers WHERE cost_center_code = 'CC003');

-- Same for profit_centers
INSERT INTO profit_centers (profit_center_code, profit_center_name, company_code) 
SELECT 'PC001', 'Residential Construction', 'C001'
WHERE NOT EXISTS (SELECT 1 FROM profit_centers WHERE profit_center_code = 'PC001');

INSERT INTO profit_centers (profit_center_code, profit_center_name, company_code) 
SELECT 'PC002', 'Commercial Construction', 'C001'
WHERE NOT EXISTS (SELECT 1 FROM profit_centers WHERE profit_center_code = 'PC002');

-- Same for plants
INSERT INTO plants (plant_code, plant_name, address, company_code) 
SELECT 'PL001', 'Main Construction Site', '123 Construction Ave', 'C001'
WHERE NOT EXISTS (SELECT 1 FROM plants WHERE plant_code = 'PL001');

INSERT INTO plants (plant_code, plant_name, address, company_code) 
SELECT 'PL002', 'Equipment Yard', '456 Equipment Blvd', 'C001'
WHERE NOT EXISTS (SELECT 1 FROM plants WHERE plant_code = 'PL002');
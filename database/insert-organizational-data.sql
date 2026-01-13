-- Insert Person Responsible data
INSERT INTO persons_responsible (person_id, first_name, last_name, email, company_code, is_active) VALUES
('PR001', 'John', 'Smith', 'john.smith@company.com', 'C001', true),
('PR002', 'Sarah', 'Johnson', 'sarah.johnson@company.com', 'C001', true),
('PR003', 'Mike', 'Davis', 'mike.davis@company.com', 'C001', true),
('PR004', 'Lisa', 'Wilson', 'lisa.wilson@company.com', 'C001', true)
ON CONFLICT DO NOTHING;

-- Insert Cost Centers
INSERT INTO cost_centers (cost_center_id, cost_center_name, company_code, is_active) VALUES
('CC001', 'Construction Operations', 'C001', true),
('CC002', 'Project Management', 'C001', true),
('CC003', 'Engineering Services', 'C001', true),
('CC004', 'Equipment & Machinery', 'C001', true),
('CC005', 'Administration', 'C001', true)
ON CONFLICT DO NOTHING;

-- Insert Profit Centers
INSERT INTO profit_centers (profit_center_id, profit_center_name, company_code, is_active) VALUES
('PC001', 'Residential Construction', 'C001', true),
('PC002', 'Commercial Construction', 'C001', true),
('PC003', 'Infrastructure Projects', 'C001', true),
('PC004', 'Renovation Services', 'C001', true)
ON CONFLICT DO NOTHING;

-- Insert Plants
INSERT INTO plants (plant_id, plant_name, address, company_code, is_active) VALUES
('PL001', 'Main Construction Site', '123 Construction Ave, City, State', 'C001', true),
('PL002', 'Equipment Yard', '456 Equipment Blvd, City, State', 'C001', true),
('PL003', 'Material Storage', '789 Storage St, City, State', 'C001', true),
('PL004', 'Office Complex', '321 Office Park Dr, City, State', 'C001', true)
ON CONFLICT DO NOTHING;
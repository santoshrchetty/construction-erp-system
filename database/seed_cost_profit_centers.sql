-- Add Cost Centers aligned with existing company structure
INSERT INTO cost_centers (cost_center_code, cost_center_name, cost_center_category, controlling_area_code, is_active) VALUES
('CC001', 'Construction Operations', 'Operations', 'CA01', true),
('CC002', 'Equipment Management', 'Equipment', 'CA01', true),
('CC003', 'Infrastructure Development', 'Development', 'CA01', true),
('CC004', 'MEP Operations', 'Operations', 'CA01', true),
('CC005', 'Project Management Office', 'Administration', 'CA01', true);

-- Add Profit Centers aligned with existing company structure  
INSERT INTO profit_centers (profit_center_code, profit_center_name, profit_center_group, controlling_area_code, is_active) VALUES
('PC001', 'Construction Materials Division', 'Materials', 'CA01', true),
('PC002', 'Equipment & Services Division', 'Services', 'CA01', true),
('PC003', 'Infrastructure Division', 'Infrastructure', 'CA01', true),
('PC004', 'MEP Division', 'MEP', 'CA01', true),
('PC005', 'Bremen Operations', 'Regional', 'CA01', true);
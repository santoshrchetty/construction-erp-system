-- Add Profit Centers using controlling area N001 and company C001
INSERT INTO profit_centers (profit_center_code, profit_center_name, controlling_area_code, company_code_id, responsible_person, is_active) VALUES
('PC001', 'Construction Materials Division', 'N001', '0732be60-1fef-4550-9dd0-2f94bc15ba5b', 'Materials Manager', true),
('PC002', 'Equipment & Services Division', 'N001', '0732be60-1fef-4550-9dd0-2f94bc15ba5b', 'Services Manager', true),
('PC003', 'Infrastructure Division', 'N001', '0732be60-1fef-4550-9dd0-2f94bc15ba5b', 'Infrastructure Manager', true),
('PC004', 'MEP Division', 'N001', '0732be60-1fef-4550-9dd0-2f94bc15ba5b', 'MEP Manager', true),
('PC005', 'Bremen Operations', 'N001', '0732be60-1fef-4550-9dd0-2f94bc15ba5b', 'Regional Manager', true);

-- Add Cost Centers for controlling area N001 and company C001
INSERT INTO cost_centers (cost_center_code, cost_center_name, cost_center_type, controlling_area_code, company_code, responsible_person, is_active) VALUES
('CC-N001-01', 'Construction Operations N001', 'PROJECT', 'N001', 'C001', 'Operations Manager', true),
('CC-N001-02', 'Equipment Management N001', 'OVERHEAD', 'N001', 'C001', 'Equipment Manager', true),
('CC-N001-03', 'Infrastructure Development N001', 'PROJECT', 'N001', 'C001', 'Infrastructure Manager', true),
('CC-N001-04', 'MEP Operations N001', 'PROJECT', 'N001', 'C001', 'MEP Manager', true),
('CC-N001-05', 'Project Management Office N001', 'OVERHEAD', 'N001', 'C001', 'PMO Manager', true);
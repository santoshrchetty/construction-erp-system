-- Create WBS Elements for Project P100 using correct column names
-- Insert Level 1 WBS Elements (Total: $5M)
INSERT INTO wbs_elements (
    company_code, project_code, wbs_element, wbs_description, wbs_level, parent_wbs, 
    is_active, project_start_date, project_end_date, created_at, updated_at
) VALUES 
('C001', 'P100', 'P100.1', 'Site Preparation - Site clearing, excavation, and foundation work', 1, NULL, true, '2024-01-15', '2024-04-30', NOW(), NOW()),
('C001', 'P100', 'P100.2', 'Structure Construction - Building structure, floors, and roofing', 1, NULL, true, '2024-03-01', '2024-09-30', NOW(), NOW()),
('C001', 'P100', 'P100.3', 'MEP Installation - Mechanical, Electrical, and Plumbing systems', 1, NULL, true, '2024-07-01', '2024-11-30', NOW(), NOW()),
('C001', 'P100', 'P100.4', 'Interior Finishing - Interior walls, flooring, and finishing work', 1, NULL, false, '2024-10-01', '2024-12-15', NOW(), NOW()),
('C001', 'P100', 'P100.5', 'External Works - Landscaping, parking, and external utilities', 1, NULL, false, '2024-11-01', '2024-12-31', NOW(), NOW());

-- Insert Level 2 WBS Elements
INSERT INTO wbs_elements (
    company_code, project_code, wbs_element, wbs_description, wbs_level, parent_wbs, 
    is_active, project_start_date, project_end_date, created_at, updated_at
) VALUES 
-- Site Preparation sub-elements
('C001', 'P100', 'P100.1.1', 'Excavation - Site excavation and earth moving', 2, 'P100.1', true, '2024-01-15', '2024-02-28', NOW(), NOW()),
('C001', 'P100', 'P100.1.2', 'Foundation - Foundation and basement construction', 2, 'P100.1', true, '2024-02-15', '2024-04-30', NOW(), NOW()),

-- Structure Construction sub-elements
('C001', 'P100', 'P100.2.1', 'Concrete Work - Concrete pouring and structural work', 2, 'P100.2', true, '2024-03-01', '2024-07-31', NOW(), NOW()),
('C001', 'P100', 'P100.2.2', 'Steel Framework - Steel structure and framework', 2, 'P100.2', true, '2024-04-01', '2024-08-31', NOW(), NOW()),
('C001', 'P100', 'P100.2.3', 'Roofing - Roof construction and waterproofing', 2, 'P100.2', false, '2024-08-01', '2024-09-30', NOW(), NOW()),

-- MEP Installation sub-elements
('C001', 'P100', 'P100.3.1', 'Electrical Systems - Electrical wiring and systems', 2, 'P100.3', true, '2024-07-01', '2024-10-31', NOW(), NOW()),
('C001', 'P100', 'P100.3.2', 'HVAC Systems - Heating, ventilation, and air conditioning', 2, 'P100.3', false, '2024-08-01', '2024-11-30', NOW(), NOW()),
('C001', 'P100', 'P100.3.3', 'Plumbing - Water supply and drainage systems', 2, 'P100.3', false, '2024-07-15', '2024-10-15', NOW(), NOW());

-- Verify WBS creation
SELECT 
    wbs_element, 
    wbs_description, 
    wbs_level, 
    parent_wbs,
    is_active,
    project_start_date,
    project_end_date
FROM wbs_elements 
WHERE project_code = 'P100'
ORDER BY wbs_element;
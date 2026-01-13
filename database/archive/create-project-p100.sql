-- Create Project P100 with WBS Elements for Testing
-- This aligns the projects table with existing universal_journal financial data

-- Insert Project P100
INSERT INTO projects (
    id, code, name, description, status, budget, start_date, 
    company_code, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    'P100',
    'Office Building Construction',
    'Modern office building construction project with 10 floors and underground parking',
    'active',
    5000000.00,
    '2024-01-15',
    'C001',
    NOW(),
    NOW()
) ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    budget = EXCLUDED.budget,
    updated_at = NOW();

-- Get the project ID for WBS creation
DO $$
DECLARE
    project_uuid UUID;
BEGIN
    SELECT id INTO project_uuid FROM projects WHERE code = 'P100';
    
    -- Insert WBS Elements for P100
    INSERT INTO wbs_elements (
        id, project_id, wbs_code, wbs_name, description, level, parent_id, 
        budget_amount, actual_cost, status, created_at, updated_at
    ) VALUES 
    -- Level 1 - Main Project
    (gen_random_uuid(), project_uuid, 'P100.1', 'Site Preparation', 'Site clearing, excavation, and foundation work', 1, NULL, 800000.00, 0, 'active', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.2', 'Structure Construction', 'Building structure, floors, and roofing', 1, NULL, 2500000.00, 0, 'active', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.3', 'MEP Installation', 'Mechanical, Electrical, and Plumbing systems', 1, NULL, 1200000.00, 0, 'active', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.4', 'Interior Finishing', 'Interior walls, flooring, and finishing work', 1, NULL, 400000.00, 0, 'planning', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.5', 'External Works', 'Landscaping, parking, and external utilities', 1, NULL, 100000.00, 0, 'planning', NOW(), NOW())
    ON CONFLICT (wbs_code) DO UPDATE SET
        wbs_name = EXCLUDED.wbs_name,
        description = EXCLUDED.description,
        budget_amount = EXCLUDED.budget_amount,
        updated_at = NOW();
END $$;

-- Get WBS parent IDs and create Level 2 elements
DO $$
DECLARE
    project_uuid UUID;
    site_prep_id UUID;
    structure_id UUID;
    mep_id UUID;
BEGIN
    SELECT id INTO project_uuid FROM projects WHERE code = 'P100';
    SELECT id INTO site_prep_id FROM wbs_elements WHERE wbs_code = 'P100.1';
    SELECT id INTO structure_id FROM wbs_elements WHERE wbs_code = 'P100.2';
    SELECT id INTO mep_id FROM wbs_elements WHERE wbs_code = 'P100.3';
    
    -- Level 2 - Sub-elements
    INSERT INTO wbs_elements (
        id, project_id, wbs_code, wbs_name, description, level, parent_id, 
        budget_amount, actual_cost, status, created_at, updated_at
    ) VALUES 
    -- Site Preparation sub-elements
    (gen_random_uuid(), project_uuid, 'P100.1.1', 'Excavation', 'Site excavation and earth moving', 2, site_prep_id, 300000.00, 0, 'active', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.1.2', 'Foundation', 'Foundation and basement construction', 2, site_prep_id, 500000.00, 0, 'active', NOW(), NOW()),
    
    -- Structure sub-elements
    (gen_random_uuid(), project_uuid, 'P100.2.1', 'Concrete Work', 'Concrete pouring and structural work', 2, structure_id, 1500000.00, 0, 'active', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.2.2', 'Steel Framework', 'Steel structure and framework', 2, structure_id, 800000.00, 0, 'active', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.2.3', 'Roofing', 'Roof construction and waterproofing', 2, structure_id, 200000.00, 0, 'planning', NOW(), NOW()),
    
    -- MEP sub-elements
    (gen_random_uuid(), project_uuid, 'P100.3.1', 'Electrical Systems', 'Electrical wiring and systems', 2, mep_id, 500000.00, 0, 'active', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.3.2', 'HVAC Systems', 'Heating, ventilation, and air conditioning', 2, mep_id, 400000.00, 0, 'planning', NOW(), NOW()),
    (gen_random_uuid(), project_uuid, 'P100.3.3', 'Plumbing', 'Water supply and drainage systems', 2, mep_id, 300000.00, 0, 'planning', NOW(), NOW())
    ON CONFLICT (wbs_code) DO UPDATE SET
        wbs_name = EXCLUDED.wbs_name,
        description = EXCLUDED.description,
        budget_amount = EXCLUDED.budget_amount,
        updated_at = NOW();
END $$;

-- Verify the creation
SELECT 'Project Created' as result, code, name, status, budget 
FROM projects WHERE code = 'P100';

SELECT 'WBS Elements Created' as result, wbs_code, wbs_name, level, budget_amount, status
FROM wbs_elements 
WHERE project_id = (SELECT id FROM projects WHERE code = 'P100')
ORDER BY wbs_code;
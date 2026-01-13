-- Create WBS Elements for Project P100
-- Get project ID and create WBS structure with budget allocation

DO $$
DECLARE
    project_uuid UUID;
BEGIN
    -- Get P100 project ID
    SELECT id INTO project_uuid FROM projects WHERE code = 'P100';
    
    -- Insert Level 1 WBS Elements (Total: $5M)
    INSERT INTO wbs_elements (
        project_id, wbs_code, wbs_name, description, level, parent_id, 
        budget_amount, actual_cost, status, created_at, updated_at
    ) VALUES 
    (project_uuid, 'P100.1', 'Site Preparation', 'Site clearing, excavation, and foundation work', 1, NULL, 800000.00, 0, 'active', NOW(), NOW()),
    (project_uuid, 'P100.2', 'Structure Construction', 'Building structure, floors, and roofing', 1, NULL, 2500000.00, 0, 'active', NOW(), NOW()),
    (project_uuid, 'P100.3', 'MEP Installation', 'Mechanical, Electrical, and Plumbing systems', 1, NULL, 1200000.00, 0, 'active', NOW(), NOW()),
    (project_uuid, 'P100.4', 'Interior Finishing', 'Interior walls, flooring, and finishing work', 1, NULL, 400000.00, 0, 'planning', NOW(), NOW()),
    (project_uuid, 'P100.5', 'External Works', 'Landscaping, parking, and external utilities', 1, NULL, 100000.00, 0, 'planning', NOW(), NOW())
    ON CONFLICT (wbs_code) DO UPDATE SET
        wbs_name = EXCLUDED.wbs_name,
        description = EXCLUDED.description,
        budget_amount = EXCLUDED.budget_amount,
        status = EXCLUDED.status,
        updated_at = NOW();
END $$;

-- Create Level 2 WBS Elements
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
    
    -- Level 2 Sub-elements
    INSERT INTO wbs_elements (
        project_id, wbs_code, wbs_name, description, level, parent_id, 
        budget_amount, actual_cost, status, created_at, updated_at
    ) VALUES 
    -- Site Preparation ($800K)
    (project_uuid, 'P100.1.1', 'Excavation', 'Site excavation and earth moving', 2, site_prep_id, 300000.00, 0, 'active', NOW(), NOW()),
    (project_uuid, 'P100.1.2', 'Foundation', 'Foundation and basement construction', 2, site_prep_id, 500000.00, 0, 'active', NOW(), NOW()),
    
    -- Structure Construction ($2.5M)
    (project_uuid, 'P100.2.1', 'Concrete Work', 'Concrete pouring and structural work', 2, structure_id, 1500000.00, 0, 'active', NOW(), NOW()),
    (project_uuid, 'P100.2.2', 'Steel Framework', 'Steel structure and framework', 2, structure_id, 800000.00, 0, 'active', NOW(), NOW()),
    (project_uuid, 'P100.2.3', 'Roofing', 'Roof construction and waterproofing', 2, structure_id, 200000.00, 0, 'planning', NOW(), NOW()),
    
    -- MEP Installation ($1.2M)
    (project_uuid, 'P100.3.1', 'Electrical Systems', 'Electrical wiring and systems', 2, mep_id, 500000.00, 0, 'active', NOW(), NOW()),
    (project_uuid, 'P100.3.2', 'HVAC Systems', 'Heating, ventilation, and air conditioning', 2, mep_id, 400000.00, 0, 'planning', NOW(), NOW()),
    (project_uuid, 'P100.3.3', 'Plumbing', 'Water supply and drainage systems', 2, mep_id, 300000.00, 0, 'planning', NOW(), NOW())
    ON CONFLICT (wbs_code) DO UPDATE SET
        wbs_name = EXCLUDED.wbs_name,
        description = EXCLUDED.description,
        budget_amount = EXCLUDED.budget_amount,
        status = EXCLUDED.status,
        updated_at = NOW();
END $$;

-- Verify WBS creation
SELECT 
    wbs_code, 
    wbs_name, 
    level, 
    budget_amount, 
    status,
    CASE WHEN parent_id IS NULL THEN 'Root' ELSE 'Child' END as hierarchy
FROM wbs_elements 
WHERE project_id = (SELECT id FROM projects WHERE code = 'P100')
ORDER BY wbs_code;
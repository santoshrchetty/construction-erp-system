-- Migration: Remove UUID foreign keys, use codes only (SAP-aligned)
-- Development system - safe to execute

-- Step 1: Verify all code fields are populated
SELECT 
    COUNT(*) as total_records,
    COUNT(company_code) as has_company_code,
    COUNT(plant_code) as has_plant_code,
    COUNT(project_code) as has_project_code,
    COUNT(cost_center) as has_cost_center,
    COUNT(wbs_element) as has_wbs_element
FROM material_requests;

-- Step 2: Populate any missing codes from UUID references (safety)
UPDATE material_requests mr
SET company_code = cc.company_code
FROM company_codes cc
WHERE mr.company_id = cc.id AND mr.company_code IS NULL;

UPDATE material_requests mr
SET plant_code = p.plant_code
FROM plants p
WHERE mr.plant_id = p.id AND mr.plant_code IS NULL;

UPDATE material_requests mr
SET project_code = p.project_code
FROM projects p
WHERE mr.project_id = p.id AND mr.project_code IS NULL;

UPDATE material_requests mr
SET cost_center = cc.cost_center_code
FROM cost_centers cc
WHERE mr.cost_center_id = cc.id AND mr.cost_center IS NULL;

UPDATE material_requests mr
SET wbs_element = w.wbs_element
FROM wbs_elements w
WHERE mr.wbs_element_id = w.id AND mr.wbs_element IS NULL;

UPDATE material_requests mr
SET activity_code = a.code
FROM activities a
WHERE mr.activity_id = a.id AND mr.activity_code IS NULL;

-- Step 3: Add foreign key constraints on code fields
ALTER TABLE material_requests
ADD CONSTRAINT fk_mr_company_code 
FOREIGN KEY (company_code) REFERENCES company_codes(company_code)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE material_requests
ADD CONSTRAINT fk_mr_plant_code 
FOREIGN KEY (plant_code) REFERENCES plants(plant_code)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- Optional: Add FK for project, cost_center, wbs if they have code as unique key
-- ALTER TABLE material_requests
-- ADD CONSTRAINT fk_mr_project_code 
-- FOREIGN KEY (project_code) REFERENCES projects(project_code);

-- Step 4: Drop UUID foreign key columns
ALTER TABLE material_requests
DROP COLUMN IF EXISTS company_id,
DROP COLUMN IF EXISTS plant_id,
DROP COLUMN IF EXISTS project_id,
DROP COLUMN IF EXISTS cost_center_id,
DROP COLUMN IF EXISTS wbs_element_id,
DROP COLUMN IF EXISTS activity_id;

-- Step 5: Verify final schema
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'material_requests'
ORDER BY ordinal_position;

-- Step 6: Test query (should work without joins)
SELECT 
    request_number,
    company_code,
    plant_code,
    project_code,
    cost_center,
    wbs_element,
    status,
    priority
FROM material_requests
LIMIT 5;

-- Step 7: Verify foreign key constraints
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'material_requests';

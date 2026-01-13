-- Update existing policies with organizational context
-- First, let's see what policies exist
SELECT id, policy_name, approval_object_type, approval_object_document_type 
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
LIMIT 10;

-- Update existing policies with context - make some plant-specific
UPDATE approval_policies 
SET plant_code = 'PLANT_NYC',
    purchase_org = 'PO_CONSTRUCTION'
WHERE approval_object_type = 'PO' 
  AND approval_object_document_type = 'NB'
  AND customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND id = (
    SELECT id FROM approval_policies 
    WHERE approval_object_type = 'PO' 
      AND approval_object_document_type = 'NB'
      AND customer_id = '550e8400-e29b-41d4-a716-446655440001'
    LIMIT 1
  );

-- Update another policy for Chicago plant
UPDATE approval_policies 
SET plant_code = 'PLANT_CHI',
    purchase_org = 'PO_CONSTRUCTION'
WHERE approval_object_type = 'MR' 
  AND approval_object_document_type = 'NB'
  AND customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND id = (
    SELECT id FROM approval_policies 
    WHERE approval_object_type = 'MR' 
      AND approval_object_document_type = 'NB'
      AND customer_id = '550e8400-e29b-41d4-a716-446655440001'
    LIMIT 1
  );

-- Update a policy for project-specific context
UPDATE approval_policies 
SET project_code = 'PROJ_ALPHA_2024'
WHERE approval_object_type = 'MR' 
  AND approval_object_document_type = 'SP'
  AND customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND id = (
    SELECT id FROM approval_policies 
    WHERE approval_object_type = 'MR' 
      AND approval_object_document_type = 'SP'
      AND customer_id = '550e8400-e29b-41d4-a716-446655440001'
    LIMIT 1
  );

-- Verify updated policies with context
SELECT 
    policy_name,
    approval_object_type,
    approval_object_document_type,
    company_code,
    country_code,
    plant_code,
    purchase_org,
    project_code,
    approval_strategy
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND (plant_code IS NOT NULL OR project_code IS NOT NULL OR purchase_org IS NOT NULL)
ORDER BY plant_code, project_code;
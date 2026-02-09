-- ============================================================================
-- Add Standard Fields to All Authorization Objects
-- ============================================================================
-- This adds ACTVT, COMP_CODE, PLANT, DEPT to all existing objects
-- ============================================================================

-- Add ACTVT (Activity) to all objects - REQUIRED
INSERT INTO authorization_object_fields (auth_object_id, field_code, is_required, tenant_id)
SELECT 
  ao.id,
  'ACTVT',
  true,
  ao.tenant_id
FROM authorization_objects ao
WHERE NOT EXISTS (
  SELECT 1 FROM authorization_object_fields aof 
  WHERE aof.auth_object_id = ao.id AND aof.field_code = 'ACTVT'
);

-- Add COMP_CODE (Company Code) to all objects
INSERT INTO authorization_object_fields (auth_object_id, field_code, is_required, tenant_id)
SELECT 
  ao.id,
  'COMP_CODE',
  false,
  ao.tenant_id
FROM authorization_objects ao
WHERE NOT EXISTS (
  SELECT 1 FROM authorization_object_fields aof 
  WHERE aof.auth_object_id = ao.id AND aof.field_code = 'COMP_CODE'
);

-- Add PLANT to all objects
INSERT INTO authorization_object_fields (auth_object_id, field_code, is_required, tenant_id)
SELECT 
  ao.id,
  'PLANT',
  false,
  ao.tenant_id
FROM authorization_objects ao
WHERE NOT EXISTS (
  SELECT 1 FROM authorization_object_fields aof 
  WHERE aof.auth_object_id = ao.id AND aof.field_code = 'PLANT'
);

-- Add DEPT (Department) to all objects
INSERT INTO authorization_object_fields (auth_object_id, field_code, is_required, tenant_id)
SELECT 
  ao.id,
  'DEPT',
  false,
  ao.tenant_id
FROM authorization_objects ao
WHERE NOT EXISTS (
  SELECT 1 FROM authorization_object_fields aof 
  WHERE aof.auth_object_id = ao.id AND aof.field_code = 'DEPT'
);

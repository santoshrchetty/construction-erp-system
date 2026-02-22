-- Check which DG tiles exist and their auth requirements
SELECT 
  title,
  auth_object,
  route,
  is_active
FROM tiles
WHERE tile_category = 'Document Governance'
ORDER BY sequence_order;

-- Check if user has these authorizations
SELECT 
  t.title,
  t.auth_object,
  CASE 
    WHEN rao.id IS NOT NULL THEN 'HAS ACCESS'
    ELSE 'NO ACCESS'
  END as access_status
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
LEFT JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id 
  AND rao.role_id = (SELECT role_id FROM users WHERE email = 'internaluser@abc.com')
WHERE t.tile_category = 'Document Governance'
ORDER BY t.sequence_order;

-- Check user's current authorizations
SELECT 
  ao.object_name,
  ao.description,
  rao.field_values
FROM users u
JOIN roles r ON u.role_id = r.id
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE u.email = 'internaluser@abc.com'
AND ao.module = 'DG'
ORDER BY ao.object_name;

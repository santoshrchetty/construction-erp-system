-- Check tile access status
SELECT 
  t.title,
  t.auth_object,
  CASE 
    WHEN rao.id IS NOT NULL THEN '✅ HAS ACCESS'
    ELSE '❌ NO ACCESS'
  END as access_status
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
LEFT JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id 
  AND rao.role_id = (SELECT role_id FROM users WHERE email = 'internaluser@abc.com')
WHERE t.tile_category = 'Document Governance'
ORDER BY t.sequence_order;

-- Check if My Pending Approvals tile exists
SELECT id, title, subtitle, module_code, construction_action, route, tile_category, auth_object, is_active
FROM tiles 
WHERE title LIKE '%Pending Approvals%';

-- If tile doesn't exist, insert it
INSERT INTO tiles (
  id,
  title,
  subtitle,
  icon,
  module_code,
  construction_action,
  route,
  tile_category,
  sequence_order,
  auth_object,
  is_active,
  tenant_id,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'My Pending Approvals',
  'Review and approve pending requests',
  'check-square',
  'WF',
  'View List',
  '/approvals/inbox',
  'WORKFLOW',
  5,
  'WF_APPROVE',
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- If tile exists but route is wrong, update it
UPDATE tiles 
SET route = '/approvals/inbox',
    updated_at = NOW()
WHERE title LIKE '%Pending Approvals%' 
  AND route != '/approvals/inbox';

-- Verify the tile
SELECT id, title, subtitle, module_code, construction_action, route, tile_category, auth_object
FROM tiles 
WHERE title LIKE '%Pending Approvals%';

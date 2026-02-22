-- Restore the My Tasks tile
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
  '0c1eaed5-b2ca-431f-ad9f-64fbdd388537'::uuid,
  'My Pending Approvals',
  'Requests waiting for my approval',
  'check-square',
  'user_tasks',
  'my-pending-approvals',
  '/approvals/inbox',
  'My Tasks',
  1,
  'UT_PEND_APPR',
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  route = '/approvals/inbox',
  updated_at = NOW();

-- Verify both tiles exist
SELECT id, title, subtitle, module_code, construction_action, route, tile_category, auth_object
FROM tiles 
WHERE title = 'My Pending Approvals'
ORDER BY tile_category;

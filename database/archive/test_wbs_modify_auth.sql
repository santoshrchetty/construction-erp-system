-- Test authorization check for PS_WBS_MODIFY
-- ==========================================

-- Test the check_construction_authorization function
SELECT check_construction_authorization(
  '70f8baa8-27b8-4061-84c4-6dd027d6b89f'::uuid,
  'PS_WBS_MODIFY'
) as has_wbs_modify_access;

-- Also test PS_WBS_CREATE for comparison
SELECT check_construction_authorization(
  '70f8baa8-27b8-4061-84c4-6dd027d6b89f'::uuid,
  'PS_WBS_CREATE'
) as has_wbs_create_access;
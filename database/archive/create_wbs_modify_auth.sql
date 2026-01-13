-- Create PS_WBS_MODIFY authorization object
-- ==========================================

INSERT INTO authorization_objects (
  object_name,
  description,
  module,
  is_active
) VALUES (
  'PS_WBS_MODIFY',
  'Project WBS Modification Authorization',
  'project_system',
  true
) ON CONFLICT (object_name) DO NOTHING;

-- Verify it was created
SELECT object_name, description, module
FROM authorization_objects 
WHERE object_name = 'PS_WBS_MODIFY';
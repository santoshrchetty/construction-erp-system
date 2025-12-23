-- Update Engineer role to have full project access
UPDATE roles 
SET permissions = '{
  "projects": ["read", "write", "create", "delete"],
  "wbs": ["read", "write", "create", "delete"],
  "activities": ["read", "write", "create", "delete"],
  "tasks": ["read", "write", "create", "delete"],
  "scheduling": ["read", "write"],
  "reports": ["read"],
  "timesheets": ["read", "write"]
}'
WHERE name = 'Engineer';

-- Verify the update
SELECT name, permissions FROM roles WHERE name = 'Engineer';

SELECT 'Engineer permissions updated successfully!' as status;
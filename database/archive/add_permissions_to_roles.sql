-- Add permissions column to roles table if it doesn't exist
ALTER TABLE roles ADD COLUMN IF NOT EXISTS permissions JSONB DEFAULT '{}';

-- Update Admin role with all permissions
UPDATE roles 
SET permissions = '{"all": true}'
WHERE name = 'Admin';

-- Verify the update
SELECT id, name, permissions FROM roles WHERE name = 'Admin';
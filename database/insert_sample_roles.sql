-- Insert sample roles if they don't exist
INSERT INTO roles (id, name, description, is_active, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'Project Manager', 'Full project management access', true, NOW(), NOW()),
  (gen_random_uuid(), 'Site Engineer', 'Site operations and engineering access', true, NOW(), NOW()),
  (gen_random_uuid(), 'Procurement Officer', 'Purchasing and procurement access', true, NOW(), NOW()),
  (gen_random_uuid(), 'Finance Manager', 'Financial operations access', true, NOW(), NOW()),
  (gen_random_uuid(), 'Quality Inspector', 'Quality control and inspection access', true, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Verify roles were created
SELECT id, name, description, is_active FROM roles ORDER BY name;
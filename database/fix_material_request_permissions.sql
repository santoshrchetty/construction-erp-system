-- Check existing authorization objects
SELECT * FROM authorization_objects WHERE object_name LIKE '%MATERIAL%' OR module = 'materials';

-- Insert missing material request permissions with shorter names
INSERT INTO authorization_objects (object_name, module, description, is_active, tenant_id)
VALUES 
  ('MAT_REQ_READ', 'materials', 'Read material requests', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('MAT_REQ_WRITE', 'materials', 'Create/update material requests', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid);

-- Check table structure first
SELECT column_name FROM information_schema.columns WHERE table_name = 'role_authorization_objects';

-- Check users and roles
SELECT u.id, u.email, r.name as role_name
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.email LIKE '%@%';
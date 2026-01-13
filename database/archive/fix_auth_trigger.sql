-- Drop the problematic trigger
DROP TRIGGER IF EXISTS sync_auth_user_trigger ON auth.users;
DROP FUNCTION IF EXISTS sync_auth_user();

-- Delete and recreate users manually
DELETE FROM users;

-- Manually create users for each auth user
INSERT INTO users (id, email, role_id, created_at)
VALUES 
('7febcd41-4b34-4155-b306-8ea89d9f715e', 'admin@demo.com', (SELECT id FROM roles WHERE name = 'Admin'), NOW()),
('f82b1145-1d2b-4791-b008-befcb89789bd', 'manager@demo.com', (SELECT id FROM roles WHERE name = 'Manager'), NOW()),
('c55b12da-e5a6-421a-b2bd-f6edeb424a5f', 'engineer@demo.com', (SELECT id FROM roles WHERE name = 'Engineer'), NOW()),
('182043b2-e3f1-4dc2-91dd-8fe603a47d1c', 'finance@demo.com', (SELECT id FROM roles WHERE name = 'Finance'), NOW());

SELECT 'Trigger removed, users created manually' as status;
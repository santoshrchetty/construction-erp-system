-- Temporarily disable RLS to test
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE employees DISABLE ROW LEVEL SECURITY;

-- Check if users exist and have correct structure
SELECT id, email, role_id FROM users LIMIT 5;

SELECT 'RLS disabled for testing' as status;
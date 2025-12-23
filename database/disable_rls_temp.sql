-- Temporarily disable RLS for testing CORS issues
-- Run this in Supabase SQL editor

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;

-- Re-enable after testing:
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
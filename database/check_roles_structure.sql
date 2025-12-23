-- Check roles table structure
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'roles';

-- Check if roles have permissions column
SELECT * FROM roles WHERE id = '00e8b52d-e653-47c2-b679-7d9623973a44';
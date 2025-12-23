-- Check storage_locations table structure
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'storage_locations';
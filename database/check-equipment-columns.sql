SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'activity_equipment'
ORDER BY ordinal_position;
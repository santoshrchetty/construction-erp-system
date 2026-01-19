-- Compare materials and material_master tables

-- Check if both tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND table_name IN ('materials', 'material_master')
ORDER BY table_name;

-- Check columns in materials table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'materials'
ORDER BY ordinal_position;

-- Check columns in material_master table (if exists)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'material_master'
ORDER BY ordinal_position;

-- Count records in each
SELECT 'materials' as table_name, COUNT(*) as count FROM materials WHERE is_active = true;
SELECT 'material_master' as table_name, COUNT(*) as count FROM material_master WHERE is_active = true;

-- Sample data from materials
SELECT material_code, material_name, base_uom, standard_price FROM materials WHERE is_active = true LIMIT 3;

-- Sample data from material_master (if exists)
SELECT material_code, material_name FROM material_master WHERE is_active = true LIMIT 3;

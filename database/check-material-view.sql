-- Compare materials table vs material_master_view

-- Check what exists
SELECT table_name, table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name LIKE '%material%'
ORDER BY table_name;

-- Columns in materials table
SELECT 'materials' as source, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'materials'
ORDER BY ordinal_position;

-- Columns in material_master_view
SELECT 'material_master_view' as source, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'material_master_view'
ORDER BY ordinal_position;

-- Count records
SELECT 'materials' as source, COUNT(*) FROM materials WHERE is_active = true;
SELECT 'material_master_view' as source, COUNT(*) FROM material_master_view;

-- Sample from materials
SELECT 'materials' as source, material_code, material_name, base_uom, standard_price 
FROM materials WHERE is_active = true LIMIT 3;

-- Sample from view
SELECT 'view' as source, * FROM material_master_view LIMIT 3;

-- View definition
SELECT pg_get_viewdef('material_master_view', true);

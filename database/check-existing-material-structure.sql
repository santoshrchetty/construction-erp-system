-- CHECK EXISTING MATERIAL TABLES STRUCTURE

-- Check material_master_view structure
SELECT 'MATERIAL_MASTER_VIEW STRUCTURE' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'material_master_view' 
ORDER BY ordinal_position;

-- Check material_plant_data structure
SELECT 'MATERIAL_PLANT_DATA STRUCTURE' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'material_plant_data' 
ORDER BY ordinal_position;

-- Check material_groups structure
SELECT 'MATERIAL_GROUPS STRUCTURE' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'material_groups' 
ORDER BY ordinal_position;

-- Sample data from material_master_view
SELECT 'SAMPLE MATERIAL_MASTER_VIEW DATA' as section;
SELECT * FROM material_master_view LIMIT 3;

SELECT 'MATERIAL STRUCTURE CHECK COMPLETE' as status;
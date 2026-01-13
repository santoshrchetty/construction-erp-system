-- CHECK MATERIAL MASTER TABLE STRUCTURE

-- Check material_master table structure
SELECT 'MATERIAL_MASTER TABLE STRUCTURE' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'material_master' 
ORDER BY ordinal_position;

-- Check if material_plant_data table exists
SELECT 'MATERIAL_PLANT_DATA TABLE CHECK' as section;
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'material_plant_data') 
    THEN 'EXISTS' 
    ELSE 'MISSING' 
  END as material_plant_data_table;

-- Show sample material_master data
SELECT 'SAMPLE MATERIAL_MASTER DATA' as section;
SELECT * FROM material_master LIMIT 5;

SELECT 'MATERIAL MASTER STRUCTURE CHECK COMPLETE' as status;
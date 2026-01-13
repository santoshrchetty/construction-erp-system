-- Diagnostic: Check actual table structure and constraints
-- This will help us understand the real schema

-- 1. Check material_plant_data table structure
SELECT 'material_plant_data structure:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'material_plant_data' 
ORDER BY ordinal_position;

-- 2. Check foreign key constraints on material_plant_data
SELECT 'Foreign key constraints:' as info;
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name = 'material_plant_data';

-- 3. Check if our test material exists in both tables
SELECT 'Test material in materials table:' as info;
SELECT id, material_code, material_name FROM materials WHERE material_code = 'TEST-CEMENT-001';

SELECT 'Test material in stock_items table:' as info;
SELECT id, item_code FROM stock_items WHERE item_code = 'TEST-CEMENT-001';

-- 4. Check what table the foreign key actually references
SELECT 'Checking constraint details:' as info;
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint 
WHERE conname LIKE '%material_plant_data%' AND contype = 'f';
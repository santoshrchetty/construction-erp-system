-- Check material_storage_data schema and foreign keys

-- 1. Check table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'material_storage_data'
ORDER BY ordinal_position;

-- 2. Check foreign key constraints
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
WHERE tc.table_name = 'material_storage_data'
    AND tc.constraint_type = 'FOREIGN KEY';

-- 3. Check if stock_items table exists and has data
SELECT COUNT(*) as stock_items_count FROM stock_items WHERE is_active = true;

-- 4. Check relationship between materials and stock_items
SELECT 
    m.material_code,
    m.material_name,
    si.item_code,
    si.description
FROM materials m
LEFT JOIN stock_items si ON m.material_code = si.item_code
WHERE m.is_active = true
LIMIT 10;

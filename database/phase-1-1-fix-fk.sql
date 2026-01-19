-- Phase 1.1: Fix Foreign Key Constraint
-- Fix material_storage_data to reference materials instead of stock_items

-- Step 1: Check current constraint
SELECT 
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'material_storage_data'
    AND tc.constraint_type = 'FOREIGN KEY'
    AND kcu.column_name = 'material_id';

-- Step 2: Drop incorrect foreign key
ALTER TABLE material_storage_data 
DROP CONSTRAINT IF EXISTS material_storage_data_material_id_fkey;

-- Step 3: Add correct foreign key to materials table
ALTER TABLE material_storage_data 
ADD CONSTRAINT material_storage_data_material_id_fkey 
FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE;

-- Step 4: Verify the fix
SELECT 
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'material_storage_data'
    AND tc.constraint_type = 'FOREIGN KEY'
    AND kcu.column_name = 'material_id';

-- Success message
SELECT 'Phase 1.1 Complete: Foreign key now references materials table' as status;

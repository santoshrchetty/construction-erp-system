-- Debug Material Search Issue
-- Check if CEMENT-OPC-83 exists and why it's not found

-- 1. Check if material exists in materials table
SELECT 'Materials table check:' as info;
SELECT material_code, material_name, category, is_active
FROM materials 
WHERE material_code ILIKE '%CEMENT-OPC-83%' OR material_code ILIKE '%CEMENT%';

-- 2. Check if material exists in stock_items table (old structure)
SELECT 'Stock items table check:' as info;
SELECT material_code, material_name, category
FROM stock_items 
WHERE material_code ILIKE '%CEMENT-OPC-83%' OR material_code ILIKE '%CEMENT%'
LIMIT 10;

-- 3. Check if material_master_view exists and has data
SELECT 'Material master view check:' as info;
SELECT material_code, material_name, category, is_active
FROM material_master_view 
WHERE material_code ILIKE '%CEMENT-OPC-83%' OR material_code ILIKE '%CEMENT%'
LIMIT 10;

-- 4. Check view definition
SELECT 'View definition check:' as info;
SELECT table_name, view_definition 
FROM information_schema.views 
WHERE table_name = 'material_master_view';

-- 5. Check all cement materials
SELECT 'All cement materials:' as info;
SELECT material_code, material_name, category, material_type, is_active
FROM materials 
WHERE material_name ILIKE '%cement%' OR material_code ILIKE '%cement%'
ORDER BY material_code;

-- 6. Check exact material code
SELECT 'Exact material code check:' as info;
SELECT material_code, material_name, category, is_active
FROM materials 
WHERE material_code = 'CEMENT-OPC-83';
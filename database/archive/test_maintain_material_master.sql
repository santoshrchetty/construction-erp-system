-- Test Plan for Maintain Material Master Tile
-- Comprehensive testing of all functionality

-- STEP 1: Ensure test data exists
-- Add test materials if they don't exist
INSERT INTO materials (material_code, material_name, description, category, base_uom, material_type, is_active, created_by) VALUES
('TEST-CEMENT-001', 'Test Cement Material 001', 'Test cement for maintenance testing', 'CEMENT', 'BAG', 'FERT', true, 'system'),
('TEST-STEEL-001', 'Test Steel Bars 12mm', 'Test steel bars for maintenance testing', 'STEEL', 'TON', 'FERT', true, 'system'),
('TEST-SAND-001', 'Test River Sand', 'Test sand for maintenance testing', 'AGGREGATE', 'CUM', 'FERT', true, 'system')
ON CONFLICT (material_code) DO UPDATE SET
  material_name = EXCLUDED.material_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- STEP 2: Ensure categories exist
INSERT INTO material_categories (category_code, category_name, is_active) VALUES
('CEMENT', 'Cement Products', true),
('STEEL', 'Steel Products', true),
('AGGREGATE', 'Aggregates', true)
ON CONFLICT (category_code) DO UPDATE SET
  category_name = EXCLUDED.category_name;

-- STEP 3: Test queries that the service will use
-- Test direct material code search
SELECT 'Direct Code Search Test:' as test_type;
SELECT material_code, material_name, category, material_type, is_active
FROM materials 
WHERE material_code = 'TEST-CEMENT-001';

-- Test parameter-based search (material name)
SELECT 'Parameter Search Test (Name):' as test_type;
SELECT material_code, material_name, category, material_type
FROM materials 
WHERE material_name ILIKE '%cement%' AND is_active = true
LIMIT 5;

-- Test parameter-based search (category)
SELECT 'Parameter Search Test (Category):' as test_type;
SELECT material_code, material_name, category, material_type
FROM materials 
WHERE category = 'CEMENT' AND is_active = true
LIMIT 5;

-- Test parameter-based search (material type)
SELECT 'Parameter Search Test (Type):' as test_type;
SELECT material_code, material_name, category, material_type
FROM materials 
WHERE material_type = 'FERT' AND is_active = true
LIMIT 5;

-- STEP 4: Verify all test materials are accessible
SELECT 'All Test Materials:' as test_type;
SELECT material_code, material_name, category, material_type, is_active, created_at
FROM materials 
WHERE material_code LIKE 'TEST-%'
ORDER BY material_code;

-- STEP 5: Test update functionality
-- This simulates what happens when user updates a material
UPDATE materials 
SET material_name = 'Updated Test Cement Material 001',
    description = 'Updated description for testing',
    updated_at = NOW(),
    updated_by = 'test_user'
WHERE material_code = 'TEST-CEMENT-001';

-- Verify update worked
SELECT 'Update Test Result:' as test_type;
SELECT material_code, material_name, description, updated_at, updated_by
FROM materials 
WHERE material_code = 'TEST-CEMENT-001';
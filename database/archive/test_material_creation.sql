-- Test Material Creation - ERP Standard
-- This simulates what the "Create Material Master" tile should do

-- 1. Create a test material (global master data)
INSERT INTO materials (
  material_code,
  material_name,
  description,
  category,
  material_group,
  base_uom,
  material_type,
  is_active
) VALUES (
  'TEST-CEMENT-001',
  'Test Portland Cement',
  'High-grade Portland cement for testing ERP functionality',
  'CEMENT',
  'CEM-OPC',
  'BAG',
  'FERT',
  true
);

-- 2. Verify the material was created
SELECT 'Test Material Created:' as info;
SELECT material_code, material_name, category, material_group, base_uom, material_type
FROM materials 
WHERE material_code = 'TEST-CEMENT-001';

-- 3. Check available categories and groups for reference
SELECT 'Available Categories:' as info;
SELECT category_code, category_name FROM material_categories ORDER BY category_code;

SELECT 'Available Groups:' as info;
SELECT group_code, group_name, category_code FROM material_groups ORDER BY group_code;

-- 4. Test the material master view
SELECT 'Material Master View:' as info;
SELECT material_code, material_name, category_name, group_name, base_uom, plant_count
FROM material_master_view 
WHERE material_code = 'TEST-CEMENT-001';
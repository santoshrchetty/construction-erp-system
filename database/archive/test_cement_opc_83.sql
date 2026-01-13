-- Test CEMENT-OPC-83 Material for Maintain Material Master Tile
-- Ensure this specific material exists and can be maintained

-- 1. Create/Update CEMENT-OPC-83 material for testing
INSERT INTO materials (
  material_code, 
  material_name, 
  description, 
  category, 
  material_group,
  base_uom, 
  material_type,
  weight_unit,
  gross_weight,
  net_weight,
  volume_unit,
  volume,
  is_active, 
  created_by,
  created_at
) VALUES (
  'CEMENT-OPC-83', 
  'Ordinary Portland Cement 53 Grade Premium', 
  'High strength premium cement for heavy construction projects', 
  'CEMENT',
  'OPC',
  'BAG', 
  'FERT',
  'KG',
  50.5,
  50.0,
  'CUM',
  0.035,
  true, 
  'system',
  NOW()
)
ON CONFLICT (material_code) DO UPDATE SET
  material_name = EXCLUDED.material_name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  material_group = EXCLUDED.material_group,
  base_uom = EXCLUDED.base_uom,
  material_type = EXCLUDED.material_type,
  weight_unit = EXCLUDED.weight_unit,
  gross_weight = EXCLUDED.gross_weight,
  net_weight = EXCLUDED.net_weight,
  volume_unit = EXCLUDED.volume_unit,
  volume = EXCLUDED.volume,
  is_active = EXCLUDED.is_active,
  updated_at = NOW(),
  updated_by = 'system';

-- 2. Ensure required categories and groups exist
INSERT INTO material_categories (category_code, category_name, is_active) VALUES
('CEMENT', 'Cement Products', true)
ON CONFLICT (category_code) DO UPDATE SET
  category_name = EXCLUDED.category_name,
  is_active = EXCLUDED.is_active;

INSERT INTO material_groups (group_code, group_name, category_code, is_active) VALUES
('OPC', 'Ordinary Portland Cement', 'CEMENT', true)
ON CONFLICT (group_code) DO UPDATE SET
  group_name = EXCLUDED.group_name,
  category_code = EXCLUDED.category_code,
  is_active = EXCLUDED.is_active;

-- 3. Verify CEMENT-OPC-83 exists and is ready for maintenance
SELECT 'CEMENT-OPC-83 Material Ready for Maintenance:' as test_status;
SELECT 
  material_code,
  material_name,
  description,
  category,
  material_group,
  base_uom,
  material_type,
  weight_unit,
  gross_weight,
  net_weight,
  volume_unit,
  volume,
  is_active,
  created_at,
  updated_at
FROM materials 
WHERE material_code = 'CEMENT-OPC-83';

-- 4. Test the exact query that the service will use
SELECT 'Service Query Test:' as test_status;
SELECT *
FROM materials 
WHERE material_code = 'CEMENT-OPC-83' 
  AND is_active = true;

-- 5. Test parameter search that should find this material
SELECT 'Parameter Search Test (Name):' as test_status;
SELECT material_code, material_name, category, material_type
FROM materials 
WHERE material_name ILIKE '%cement%' 
  AND is_active = true
  AND material_code = 'CEMENT-OPC-83';

-- 6. Test category-based search
SELECT 'Category Search Test:' as test_status;
SELECT material_code, material_name, category, material_type
FROM materials 
WHERE category = 'CEMENT' 
  AND is_active = true
  AND material_code = 'CEMENT-OPC-83';
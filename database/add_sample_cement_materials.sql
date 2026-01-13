-- Add Sample Cement Materials for Testing
-- Ensure materials exist for testing the search functionality

-- 1. Insert sample cement materials if they don't exist
INSERT INTO materials (material_code, material_name, description, category, base_uom, material_type, is_active) VALUES
('CEMENT-OPC-83', 'Ordinary Portland Cement 53 Grade', 'High strength cement for construction', 'CEMENT', 'BAG', 'FERT', true),
('CEMENT-OPC-43', 'Ordinary Portland Cement 43 Grade', 'Standard cement for general construction', 'CEMENT', 'BAG', 'FERT', true),
('CEMENT-PPC-001', 'Portland Pozzolana Cement', 'Blended cement with pozzolanic materials', 'CEMENT', 'BAG', 'FERT', true)
ON CONFLICT (material_code) DO UPDATE SET
  material_name = EXCLUDED.material_name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  base_uom = EXCLUDED.base_uom,
  material_type = EXCLUDED.material_type,
  is_active = EXCLUDED.is_active;

-- 2. Ensure CEMENT category exists
INSERT INTO material_categories (category_code, category_name, is_active) VALUES
('CEMENT', 'Cement Products', true)
ON CONFLICT (category_code) DO UPDATE SET
  category_name = EXCLUDED.category_name,
  is_active = EXCLUDED.is_active;

-- 3. Verify materials were created
SELECT 'Sample cement materials created:' as info;
SELECT material_code, material_name, category, material_type, is_active
FROM materials 
WHERE material_code IN ('CEMENT-OPC-83', 'CEMENT-OPC-43', 'CEMENT-PPC-001')
ORDER BY material_code;
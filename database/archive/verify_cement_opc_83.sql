-- Verify Existing CEMENT-OPC-83 Material for Maintenance Testing
-- Check if material exists and is ready for MM02-style maintenance

-- 1. Verify CEMENT-OPC-83 exists
SELECT 'CEMENT-OPC-83 Material Status:' as info;
SELECT 
  material_code,
  material_name,
  description,
  category,
  base_uom,
  material_type,
  is_active
FROM materials 
WHERE material_code = 'CEMENT-OPC-83';

-- 2. Test the exact query the service uses
SELECT 'Service Query Result:' as info;
SELECT COUNT(*) as material_count
FROM materials 
WHERE material_code = 'CEMENT-OPC-83' 
  AND is_active = true;
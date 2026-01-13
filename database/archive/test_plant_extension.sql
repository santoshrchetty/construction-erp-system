-- Test Plant Extension - ERP Standard
-- This simulates what the "Extend Material to Plant" tile should do

-- 1. Check available plants
SELECT 'Available Plants:' as info;
SELECT plant_code, plant_name FROM plants WHERE is_active = true ORDER BY plant_code;

-- 2. Get the material ID and plant ID for the test
SELECT 'Material ID Lookup:' as info;
SELECT id as material_id, material_code, material_name 
FROM materials 
WHERE material_code = 'TEST-CEMENT-001';

SELECT 'Plant ID Lookup:' as info;
SELECT id as plant_id, plant_code, plant_name 
FROM plants 
WHERE plant_code = 'B001';

-- 3. Extend the test material to plant B001 (using both IDs and codes)
INSERT INTO material_plant_data (
  material_id,
  plant_id,
  material_code,
  plant_code,
  procurement_type,
  mrp_type,
  reorder_point,
  safety_stock,
  minimum_lot_size,
  planned_delivery_time,
  plant_status,
  is_active
) 
SELECT 
  m.id as material_id,
  p.id as plant_id,
  m.material_code,
  p.plant_code,
  'E' as procurement_type,        -- Purchase
  'PD' as mrp_type,              -- MRP Planning
  100.000 as reorder_point,      -- Reorder point
  50.000 as safety_stock,        -- Safety stock
  10.000 as minimum_lot_size,    -- Min lot size
  7 as planned_delivery_time,    -- 7 days delivery time
  'ACTIVE' as plant_status,
  true as is_active
FROM materials m, plants p
WHERE m.material_code = 'TEST-CEMENT-001'
  AND p.plant_code = 'B001';

-- 4. Verify the plant extension
SELECT 'Plant Extension Created:' as info;
SELECT m.material_code, p.plant_code, mpd.procurement_type, mpd.mrp_type, mpd.reorder_point, mpd.safety_stock, mpd.plant_status
FROM material_plant_data mpd
JOIN materials m ON mpd.material_id = m.id
JOIN plants p ON mpd.plant_id = p.id
WHERE m.material_code = 'TEST-CEMENT-001' AND p.plant_code = 'B001';

-- 5. Check updated material master view (should show plant_count = 1)
SELECT 'Updated Material Master View:' as info;
SELECT material_code, material_name, category_name, group_name, base_uom, plant_count
FROM material_master_view 
WHERE material_code = 'TEST-CEMENT-001';
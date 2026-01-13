-- Fix Conflicting Foreign Key Constraints
-- Remove the old constraint pointing to stock_items

-- 1. Drop the old foreign key constraint pointing to stock_items
ALTER TABLE material_plant_data 
DROP CONSTRAINT IF EXISTS material_plant_data_material_id_fkey;

-- 2. Verify remaining constraints
SELECT 'Remaining foreign key constraints:' as info;
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint 
WHERE conname LIKE '%material_plant_data%' AND contype = 'f';

-- 3. Now test the plant extension again
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

-- 4. Verify the plant extension was created
SELECT 'Plant Extension Created Successfully:' as info;
SELECT m.material_code, p.plant_code, mpd.procurement_type, mpd.mrp_type, mpd.reorder_point, mpd.safety_stock, mpd.plant_status
FROM material_plant_data mpd
JOIN materials m ON mpd.material_id = m.id
JOIN plants p ON mpd.plant_id = p.id
WHERE m.material_code = 'TEST-CEMENT-001' AND p.plant_code = 'B001';
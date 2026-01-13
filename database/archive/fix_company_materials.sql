-- Clean up Material Master organizational assignments
-- Remove existing assignments and orphaned materials

-- Delete existing cross-company assignments
DELETE FROM material_plant_data;
DELETE FROM material_storage_data;

-- Remove orphaned materials without proper organizational assignments
DELETE FROM stock_items 
WHERE id NOT IN (
  SELECT material_id FROM material_plant_data
  UNION
  SELECT material_id FROM material_storage_data
);
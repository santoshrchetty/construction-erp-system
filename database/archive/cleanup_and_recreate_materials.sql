-- Delete all existing materials and recreate using existing schema
-- Clean up existing data
DELETE FROM stock_movements;
DELETE FROM stock_balances;
DELETE FROM stock_items;

-- Create sample materials for both companies using existing schema
INSERT INTO stock_items (item_code, description, category, unit, reorder_level, is_active) VALUES
-- Company C001 Materials (Construction)
('CEM-OPC-53', 'Cement OPC 53 Grade', 'CEMENT', 'BAG', 100, true),
('STEEL-TMT-12', 'TMT Steel Bar 12mm', 'STEEL', 'KG', 500, true),
('STEEL-TMT-16', 'TMT Steel Bar 16mm', 'STEEL', 'KG', 400, true),
('SAND-RIVER', 'River Sand', 'AGGREGATE', 'M3', 50, true),
('AGGREGATE-20', 'Aggregate 20mm', 'AGGREGATE', 'M3', 30, true),
('BRICK-RED', 'Red Clay Bricks', 'MASONRY', 'NOS', 1000, true),
('CONCRETE-M25', 'Ready Mix Concrete M25', 'CONCRETE', 'M3', 20, true),
('REBAR-10MM', 'Reinforcement Bar 10mm', 'STEEL', 'KG', 300, true),
('TILE-CERAMIC', 'Ceramic Floor Tiles', 'FINISHING', 'SQM', 200, true),
('PAINT-EXTERIOR', 'Exterior Wall Paint', 'FINISHING', 'LTR', 100, true),

-- Company C002 Materials (Infrastructure)
('ASP-HMA', 'Hot Mix Asphalt', 'ASPHALT', 'TON', 100, true),
('ASP-CMA', 'Cold Mix Asphalt', 'ASPHALT', 'TON', 80, true),
('PWR-CABLE-11KV', 'Underground Cable 11KV', 'POWER', 'MTR', 50, true),
('PWR-TRANSFORMER', 'Distribution Transformer 500KVA', 'POWER', 'NOS', 2, true),
('DRN-PIPE-300', 'HDPE Drainage Pipe 300mm', 'DRAINAGE', 'MTR', 100, true),
('DRN-MANHOLE', 'Precast Manhole Cover', 'DRAINAGE', 'NOS', 25, true),
('SAF-GUARDRAIL', 'Steel Guardrail', 'SAFETY', 'MTR', 50, true),
('SAF-BOLLARD', 'Steel Bollard', 'SAFETY', 'NOS', 40, true),
('SGN-BOARD', 'Traffic Sign Board', 'SIGNAGE', 'NOS', 20, true),
('SGN-POST', 'Sign Post Galvanized', 'SIGNAGE', 'NOS', 30, true);

-- Create stock balances for C001 materials in P001 storage locations
INSERT INTO stock_balances (storage_location_id, stock_item_id, current_quantity, reserved_quantity, average_cost)
SELECT 
  (SELECT sl.id FROM storage_locations sl JOIN plants p ON sl.plant_id = p.id WHERE p.plant_code = 'P001' LIMIT 1),
  si.id,
  CASE 
    WHEN si.item_code IN ('CEM-OPC-53', 'SAND-RIVER', 'TILE-CERAMIC') THEN FLOOR(RANDOM() * 150) + 50
    WHEN si.item_code IN ('STEEL-TMT-12', 'AGGREGATE-20', 'PAINT-EXTERIOR') THEN FLOOR(RANDOM() * 40) + 5
    WHEN si.item_code IN ('STEEL-TMT-16', 'CONCRETE-M25') THEN 0
    WHEN si.item_code IN ('BRICK-RED', 'REBAR-10MM') THEN FLOOR(RANDOM() * 300) + 200
    ELSE FLOOR(RANDOM() * 100) + 20
  END,
  CASE WHEN RANDOM() > 0.8 THEN FLOOR(RANDOM() * 10) + 5 ELSE 0 END,
  CASE 
    WHEN si.category IN ('CEMENT', 'MASONRY') THEN 8.50
    WHEN si.category = 'STEEL' THEN 0.65
    WHEN si.category = 'AGGREGATE' THEN 25.00
    WHEN si.category = 'CONCRETE' THEN 120.00
    WHEN si.category = 'FINISHING' THEN 15.00
    ELSE 10.00
  END
FROM stock_items si
WHERE si.item_code IN ('CEM-OPC-53', 'STEEL-TMT-12', 'STEEL-TMT-16', 'SAND-RIVER', 'AGGREGATE-20', 'BRICK-RED', 'CONCRETE-M25', 'REBAR-10MM', 'TILE-CERAMIC', 'PAINT-EXTERIOR');

-- Create stock balances for C002 materials in P002 storage locations
INSERT INTO stock_balances (storage_location_id, stock_item_id, current_quantity, reserved_quantity, average_cost)
SELECT 
  (SELECT sl.id FROM storage_locations sl JOIN plants p ON sl.plant_id = p.id WHERE p.plant_code = 'P002' LIMIT 1),
  si.id,
  CASE 
    WHEN si.item_code IN ('ASP-HMA', 'PWR-CABLE-11KV', 'DRN-PIPE-300', 'SAF-GUARDRAIL', 'SGN-BOARD') THEN FLOOR(RANDOM() * 150) + 50
    WHEN si.item_code IN ('ASP-CMA', 'PWR-TRANSFORMER', 'DRN-MANHOLE', 'SAF-BOLLARD', 'SGN-POST') THEN FLOOR(RANDOM() * 40) + 5
    ELSE FLOOR(RANDOM() * 100) + 20
  END,
  CASE WHEN RANDOM() > 0.8 THEN FLOOR(RANDOM() * 10) + 5 ELSE 0 END,
  CASE 
    WHEN si.category = 'ASPHALT' THEN 150.00
    WHEN si.category = 'POWER' THEN 500.00
    WHEN si.category = 'DRAINAGE' THEN 25.00
    WHEN si.category = 'SAFETY' THEN 75.00
    WHEN si.category = 'SIGNAGE' THEN 100.00
    ELSE 50.00
  END
FROM stock_items si
WHERE si.item_code IN ('ASP-HMA', 'ASP-CMA', 'PWR-CABLE-11KV', 'PWR-TRANSFORMER', 'DRN-PIPE-300', 'DRN-MANHOLE', 'SAF-GUARDRAIL', 'SAF-BOLLARD', 'SGN-BOARD', 'SGN-POST');
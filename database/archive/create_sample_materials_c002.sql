-- Sample Materials for Company C002 (P002) with Organizational Assignments
-- Insert 25 sample materials for Infrastructure company
INSERT INTO stock_items (item_code, description, category, unit, reorder_level, is_active) VALUES
-- ASPHALT materials (5)
('ASP-HMA', 'Hot Mix Asphalt', 'ASPHALT', 'TON', 100, true),
('ASP-CMA', 'Cold Mix Asphalt', 'ASPHALT', 'TON', 80, true),
('ASP-EMULSION', 'Bitumen Emulsion', 'ASPHALT', 'LTR', 500, true),
('ASP-PRIMER', 'Bitumen Primer', 'ASPHALT', 'LTR', 300, true),
('ASP-TACK', 'Tack Coat', 'ASPHALT', 'LTR', 200, true),

-- POWER materials (5)
('PWR-CABLE-11KV', 'Underground Cable 11KV', 'POWER', 'MTR', 50, true),
('PWR-TRANSFORMER', 'Distribution Transformer 500KVA', 'POWER', 'NOS', 2, true),
('PWR-POLE', 'Concrete Electric Pole 12m', 'POWER', 'NOS', 10, true),
('PWR-SWITCH', 'HV Switch Gear', 'POWER', 'NOS', 5, true),
('PWR-METER', 'Energy Meter 3 Phase', 'POWER', 'NOS', 20, true),

-- DRAINAGE materials (5)
('DRN-PIPE-300', 'HDPE Drainage Pipe 300mm', 'DRAINAGE', 'MTR', 100, true),
('DRN-PIPE-450', 'HDPE Drainage Pipe 450mm', 'DRAINAGE', 'MTR', 80, true),
('DRN-MANHOLE', 'Precast Manhole Cover', 'DRAINAGE', 'NOS', 25, true),
('DRN-GRATING', 'Cast Iron Grating', 'DRAINAGE', 'NOS', 50, true),
('DRN-CHAMBER', 'Inspection Chamber', 'DRAINAGE', 'NOS', 15, true),

-- SAFETY materials (5)
('SAF-GUARDRAIL', 'Steel Guardrail', 'SAFETY', 'MTR', 50, true),
('SAF-BOLLARD', 'Steel Bollard', 'SAFETY', 'NOS', 40, true),
('SAF-BARRIER', 'Concrete Barrier', 'SAFETY', 'MTR', 30, true),
('SAF-REFLECTOR', 'Road Reflector', 'SAFETY', 'NOS', 100, true),
('SAF-CONE', 'Traffic Cone', 'SAFETY', 'NOS', 200, true),

-- SIGNAGE materials (5)
('SGN-BOARD', 'Traffic Sign Board', 'SIGNAGE', 'NOS', 20, true),
('SGN-POST', 'Sign Post Galvanized', 'SIGNAGE', 'NOS', 30, true),
('SGN-REFLECTIVE', 'Reflective Sheeting', 'SIGNAGE', 'SQM', 100, true),
('SGN-LED', 'LED Display Board', 'SIGNAGE', 'NOS', 5, true),
('SGN-ARROW', 'Direction Arrow Sign', 'SIGNAGE', 'NOS', 25, true)
ON CONFLICT (item_code) DO NOTHING;

-- Assign materials to Plant P002 (avoid duplicates)
INSERT INTO material_plant_data (material_id, plant_id, reorder_level, safety_stock, is_active)
SELECT 
  si.id,
  (SELECT id FROM plants WHERE plant_code = 'P002'),
  si.reorder_level,
  CASE 
    WHEN si.category = 'ASPHALT' THEN 50
    WHEN si.category = 'POWER' THEN 2
    WHEN si.category = 'DRAINAGE' THEN 20
    WHEN si.category = 'SAFETY' THEN 15
    ELSE 10
  END,
  true
FROM stock_items si
WHERE (si.item_code LIKE 'ASP-%' OR si.item_code LIKE 'PWR-%' OR si.item_code LIKE 'DRN-%' 
   OR si.item_code LIKE 'SAF-%' OR si.item_code LIKE 'SGN-%')
AND NOT EXISTS (
  SELECT 1 FROM material_plant_data mpd 
  WHERE mpd.material_id = si.id AND mpd.plant_id = (SELECT id FROM plants WHERE plant_code = 'P002')
);

-- Assign materials to storage locations with varied stock levels (avoid duplicates)
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock, reserved_stock)
SELECT 
  si.id,
  (SELECT id FROM storage_locations WHERE sloc_code = '0001' AND plant_id = (SELECT id FROM plants WHERE plant_code = 'P002')),
  CASE 
    -- Normal stock levels (50-200)
    WHEN si.item_code IN ('ASP-HMA', 'PWR-CABLE-11KV', 'DRN-PIPE-300', 'SAF-GUARDRAIL', 'SGN-BOARD') THEN FLOOR(RANDOM() * 150) + 50
    -- Low stock levels (5-49)
    WHEN si.item_code IN ('ASP-CMA', 'PWR-TRANSFORMER', 'DRN-MANHOLE', 'SAF-BOLLARD', 'SGN-POST') THEN FLOOR(RANDOM() * 40) + 5
    -- Zero stock
    WHEN si.item_code IN ('ASP-EMULSION', 'PWR-SWITCH', 'DRN-CHAMBER', 'SAF-BARRIER', 'SGN-LED') THEN 0
    -- High stock (200+)
    WHEN si.item_code IN ('ASP-PRIMER', 'PWR-METER', 'DRN-GRATING', 'SAF-REFLECTOR', 'SGN-REFLECTIVE') THEN FLOOR(RANDOM() * 300) + 200
    -- Random stock for others
    ELSE FLOOR(RANDOM() * 100) + 20
  END,
  CASE 
    WHEN RANDOM() > 0.8 THEN FLOOR(RANDOM() * 10) + 5
    ELSE 0
  END
FROM stock_items si
WHERE (si.item_code LIKE 'ASP-%' OR si.item_code LIKE 'PWR-%' OR si.item_code LIKE 'DRN-%' 
   OR si.item_code LIKE 'SAF-%' OR si.item_code LIKE 'SGN-%')
AND NOT EXISTS (
  SELECT 1 FROM material_storage_data msd 
  WHERE msd.material_id = si.id AND msd.storage_location_id = (SELECT id FROM storage_locations WHERE sloc_code = '0001' AND plant_id = (SELECT id FROM plants WHERE plant_code = 'P002'))
);
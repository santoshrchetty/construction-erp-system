-- Create plant for Company C002
INSERT INTO plants (company_code_id, plant_code, plant_name) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C002'), 'P006', 'Infrastructure Site 1')
ON CONFLICT (plant_code) DO NOTHING;

-- Create storage locations for the new plant
INSERT INTO storage_locations (plant_id, sloc_code, sloc_name) VALUES
((SELECT id FROM plants WHERE plant_code = 'P006'), '0001', 'Main Warehouse'),
((SELECT id FROM plants WHERE plant_code = 'P006'), '0003', 'Equipment Store')
ON CONFLICT (plant_id, sloc_code) DO NOTHING;

-- Create infrastructure materials for C002
INSERT INTO stock_items (item_code, description, category, unit, reorder_level, is_active) VALUES
('INFRA-ASP-HMA', 'Hot Mix Asphalt', 'ASPHALT', 'TON', 100, true),
('INFRA-ASP-CMA', 'Cold Mix Asphalt', 'ASPHALT', 'TON', 80, true),
('INFRA-PWR-CABLE', 'Underground Cable 11KV', 'POWER', 'MTR', 50, true),
('INFRA-PWR-TRANS', 'Distribution Transformer 500KVA', 'POWER', 'NOS', 2, true),
('INFRA-DRN-PIPE', 'HDPE Drainage Pipe 300mm', 'DRAINAGE', 'MTR', 100, true),
('INFRA-DRN-MANHOLE', 'Precast Manhole Cover', 'DRAINAGE', 'NOS', 25, true),
('INFRA-SAF-GUARD', 'Steel Guardrail', 'SAFETY', 'MTR', 50, true),
('INFRA-SAF-BOLLARD', 'Steel Bollard', 'SAFETY', 'NOS', 40, true),
('INFRA-SGN-BOARD', 'Traffic Sign Board', 'SIGNAGE', 'NOS', 20, true),
('INFRA-SGN-POST', 'Sign Post Galvanized', 'SIGNAGE', 'NOS', 30, true)
ON CONFLICT (item_code) DO NOTHING;

-- Create stock balances for C002 materials in P006 storage locations
INSERT INTO stock_balances (storage_location_id, stock_item_id, current_quantity, reserved_quantity, average_cost)
SELECT 
  sl.id,
  si.id,
  CASE 
    WHEN si.item_code IN ('INFRA-ASP-HMA', 'INFRA-PWR-CABLE', 'INFRA-DRN-PIPE', 'INFRA-SAF-GUARD', 'INFRA-SGN-BOARD') THEN FLOOR(RANDOM() * 150) + 50
    WHEN si.item_code IN ('INFRA-ASP-CMA', 'INFRA-PWR-TRANS', 'INFRA-DRN-MANHOLE', 'INFRA-SAF-BOLLARD', 'INFRA-SGN-POST') THEN FLOOR(RANDOM() * 40) + 5
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
CROSS JOIN storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE si.item_code LIKE 'INFRA-%' AND p.plant_code = 'P006';
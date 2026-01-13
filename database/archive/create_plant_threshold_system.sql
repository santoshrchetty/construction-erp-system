-- Create plant-specific stock thresholds table
CREATE TABLE IF NOT EXISTS plant_stock_thresholds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    material_category VARCHAR(100) NOT NULL,
    low_stock_threshold DECIMAL(15,4) NOT NULL,
    normal_stock_threshold DECIMAL(15,4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(plant_id, material_category)
);

-- Create plant for Company C002
INSERT INTO plants (company_code_id, plant_code, plant_name) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C002'), 'P006', 'Infrastructure Site 1')
ON CONFLICT (plant_code) DO NOTHING;

-- Create storage locations for the new plant
INSERT INTO storage_locations (plant_id, sloc_code, sloc_name) VALUES
((SELECT id FROM plants WHERE plant_code = 'P006'), '0001', 'Main Warehouse'),
((SELECT id FROM plants WHERE plant_code = 'P006'), '0003', 'Equipment Store')
ON CONFLICT (plant_id, sloc_code) DO NOTHING;

-- Insert plant-specific stock thresholds for P001 (Construction)
INSERT INTO plant_stock_thresholds (plant_id, material_category, low_stock_threshold, normal_stock_threshold) VALUES
((SELECT id FROM plants WHERE plant_code = 'P001'), 'CEMENT', 20, 50),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'STEEL', 100, 300),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'AGGREGATE', 30, 80),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'MASONRY', 500, 1500),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'CONCRETE', 10, 30),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'FINISHING', 50, 150)
ON CONFLICT (plant_id, material_category) DO NOTHING;

-- Insert plant-specific stock thresholds for P006 (Infrastructure)
INSERT INTO plant_stock_thresholds (plant_id, material_category, low_stock_threshold, normal_stock_threshold) VALUES
((SELECT id FROM plants WHERE plant_code = 'P006'), 'ASPHALT', 50, 150),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'POWER', 3, 10),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'DRAINAGE', 20, 60),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'SAFETY', 15, 40),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'SIGNAGE', 10, 25)
ON CONFLICT (plant_id, material_category) DO NOTHING;

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

-- Update existing stock balances with specific quantities for testing thresholds
INSERT INTO stock_balances (storage_location_id, stock_item_id, current_quantity, reserved_quantity, average_cost)
SELECT 
  sl.id,
  si.id,
  CASE 
    -- Zero stock items
    WHEN si.item_code = 'INFRA-ASP-CMA' THEN 0
    -- Low stock items (below plant threshold)
    WHEN si.item_code = 'INFRA-PWR-TRANS' THEN 2  -- Below 3 threshold for POWER
    WHEN si.item_code = 'INFRA-DRN-MANHOLE' THEN 15  -- Below 20 threshold for DRAINAGE
    WHEN si.item_code = 'INFRA-SAF-BOLLARD' THEN 10  -- Below 15 threshold for SAFETY
    WHEN si.item_code = 'INFRA-SGN-POST' THEN 8   -- Below 10 threshold for SIGNAGE
    -- Normal stock items (above plant threshold)
    WHEN si.item_code = 'INFRA-ASP-HMA' THEN 200  -- Above 150 threshold for ASPHALT
    WHEN si.item_code = 'INFRA-PWR-CABLE' THEN 15  -- Above 10 threshold for POWER
    WHEN si.item_code = 'INFRA-DRN-PIPE' THEN 80   -- Above 60 threshold for DRAINAGE
    WHEN si.item_code = 'INFRA-SAF-GUARD' THEN 50  -- Above 40 threshold for SAFETY
    WHEN si.item_code = 'INFRA-SGN-BOARD' THEN 30  -- Above 25 threshold for SIGNAGE
    ELSE 25
  END,
  CASE WHEN RANDOM() > 0.8 THEN FLOOR(RANDOM() * 5) + 1 ELSE 0 END,
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
WHERE si.item_code LIKE 'INFRA-%' AND p.plant_code = 'P006'
ON CONFLICT (storage_location_id, stock_item_id) 
DO UPDATE SET 
  current_quantity = EXCLUDED.current_quantity,
  reserved_quantity = EXCLUDED.reserved_quantity,
  average_cost = EXCLUDED.average_cost;
-- Sample Materials for Company C001 (P001) with Organizational Assignments
-- Insert 25 sample materials
INSERT INTO stock_items (item_code, description, category, unit, reorder_level, is_active) VALUES
-- CEMENT materials (5)
('CEM-OPC-53', 'OPC 53 Grade Cement', 'CEMENT', 'BAG', 100, true),
('CEM-PPC', 'PPC Cement', 'CEMENT', 'BAG', 100, true),
('CEM-PSC', 'PSC Cement', 'CEMENT', 'BAG', 80, true),
('CEM-OPC-43', 'OPC 43 Grade Cement', 'CEMENT', 'BAG', 90, true),
('CEM-WHITE', 'White Cement', 'CEMENT', 'BAG', 50, true),

-- STEEL materials (5)
('STL-TMT-8MM', 'TMT Steel Bars 8mm', 'STEEL', 'TON', 5, true),
('STL-TMT-12MM', 'TMT Steel Bars 12mm', 'STEEL', 'TON', 5, true),
('STL-TMT-16MM', 'TMT Steel Bars 16mm', 'STEEL', 'TON', 3, true),
('STL-ANGLE', 'Steel Angle 50x50', 'STEEL', 'KG', 100, true),
('STL-CHANNEL', 'Steel Channel 100mm', 'STEEL', 'KG', 80, true),

-- AGGREGATE materials (5)
('AGG-SAND', 'River Sand', 'AGGREGATE', 'CUM', 50, true),
('AGG-GRAVEL-20', '20mm Gravel', 'AGGREGATE', 'CUM', 30, true),
('AGG-GRAVEL-40', '40mm Gravel', 'AGGREGATE', 'CUM', 25, true),
('AGG-MSAND', 'Manufactured Sand', 'AGGREGATE', 'CUM', 40, true),
('AGG-DUST', 'Stone Dust', 'AGGREGATE', 'CUM', 35, true),

-- ELECTRICAL materials (5)
('ELE-WIRE-2.5', 'Copper Wire 2.5mm', 'ELECTRICAL', 'MTR', 500, true),
('ELE-WIRE-4.0', 'Copper Wire 4.0mm', 'ELECTRICAL', 'MTR', 300, true),
('ELE-SWITCH', 'Electrical Switch', 'ELECTRICAL', 'NOS', 50, true),
('ELE-SOCKET', 'Power Socket', 'ELECTRICAL', 'NOS', 40, true),
('ELE-CABLE', 'Armoured Cable 4 Core', 'ELECTRICAL', 'MTR', 200, true),

-- PLUMBING materials (5)
('PLU-PVC-4IN', 'PVC Pipe 4 inch', 'PLUMBING', 'MTR', 100, true),
('PLU-PVC-6IN', 'PVC Pipe 6 inch', 'PLUMBING', 'MTR', 80, true),
('PLU-VALVE', 'Gate Valve 2 inch', 'PLUMBING', 'NOS', 20, true),
('PLU-FITTING', 'PVC Elbow 4 inch', 'PLUMBING', 'NOS', 100, true),
('PLU-CPVC', 'CPVC Pipe 1 inch', 'PLUMBING', 'MTR', 150, true)
ON CONFLICT (item_code) DO NOTHING;

-- Assign materials to Plant P001
INSERT INTO material_plant_data (material_id, plant_id, reorder_level, safety_stock, is_active)
SELECT 
  si.id,
  (SELECT id FROM plants WHERE plant_code = 'P001'),
  si.reorder_level,
  CASE 
    WHEN si.category = 'CEMENT' THEN 50
    WHEN si.category = 'STEEL' THEN 2
    WHEN si.category = 'AGGREGATE' THEN 20
    ELSE 10
  END,
  true
FROM stock_items si;

-- Assign materials to storage locations with varied stock levels
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock, reserved_stock)
SELECT 
  si.id,
  (SELECT id FROM storage_locations WHERE sloc_code = '0001' AND plant_id = (SELECT id FROM plants WHERE plant_code = 'P001')),
  CASE 
    -- Normal stock levels (50-200)
    WHEN si.item_code IN ('CEM-OPC-53', 'STL-TMT-12MM', 'AGG-SAND', 'ELE-WIRE-4.0', 'PLU-PVC-4IN') THEN FLOOR(RANDOM() * 150) + 50
    -- Low stock levels (5-49)
    WHEN si.item_code IN ('CEM-PPC', 'STL-TMT-8MM', 'ELE-WIRE-2.5', 'PLU-VALVE', 'AGG-DUST') THEN FLOOR(RANDOM() * 40) + 5
    -- Zero stock
    WHEN si.item_code IN ('CEM-PSC', 'STL-ANGLE', 'ELE-SOCKET', 'PLU-FITTING', 'CEM-WHITE') THEN 0
    -- High stock (200+)
    WHEN si.item_code IN ('PLU-PVC-6IN', 'ELE-SWITCH', 'AGG-GRAVEL-20', 'STL-CHANNEL', 'CEM-OPC-43') THEN FLOOR(RANDOM() * 300) + 200
    -- Random stock for others
    ELSE FLOOR(RANDOM() * 100) + 20
  END,
  CASE 
    WHEN RANDOM() > 0.8 THEN FLOOR(RANDOM() * 10) + 5
    ELSE 0
  END
FROM stock_items si;
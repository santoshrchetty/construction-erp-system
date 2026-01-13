-- 25 Sample Materials for Testing
-- ================================

-- Ensure basic organizational structure exists
INSERT INTO company_codes (company_code, company_name, legal_entity_name, currency, country) VALUES
('C001', 'Construction Corp Ltd', 'Construction Corp Ltd', 'USD', 'US'),
('C002', 'Infrastructure Solutions Inc', 'Infrastructure Solutions Inc', 'EUR', 'DE')
ON CONFLICT (company_code) DO NOTHING;

-- Ensure plants exist
INSERT INTO plants (plant_code, plant_name, company_code_id, address) VALUES
('P001', 'Main Construction Plant', (SELECT id FROM company_codes WHERE company_code = 'C001'), 'Main Construction Site'),
('P002', 'Berlin Infrastructure Plant', (SELECT id FROM company_codes WHERE company_code = 'C002'), 'Berlin Industrial Zone')
ON CONFLICT (plant_code) DO NOTHING;

-- Ensure storage locations exist
INSERT INTO storage_locations (plant_id, sloc_code, sloc_name, location_type) VALUES
((SELECT id FROM plants WHERE plant_code = 'P001'), '0001', 'Main Warehouse', 'WAREHOUSE'),
((SELECT id FROM plants WHERE plant_code = 'P001'), '0002', 'Raw Materials Store', 'WAREHOUSE'),
((SELECT id FROM plants WHERE plant_code = 'P002'), '0001', 'Berlin Main Store', 'WAREHOUSE'),
((SELECT id FROM plants WHERE plant_code = 'P002'), '0003', 'Heavy Equipment Store', 'WAREHOUSE')
ON CONFLICT (plant_id, sloc_code) DO NOTHING;

-- Insert sample materials (Company C001)
INSERT INTO stock_items (item_code, description, category, unit, reorder_level, is_active) VALUES
('CEM-OPC-53', 'OPC 53 Grade Cement - Ordinary Portland Cement 53 Grade', 'CEMENT', 'BAG', 100, true),
('CEM-PPC', 'PPC Cement - Portland Pozzolana Cement', 'CEMENT', 'BAG', 100, true),
('STL-TMT-8MM', 'TMT Steel Bars 8mm', 'STEEL', 'TON', 5, true),
('STL-TMT-12MM', 'TMT Steel Bars 12mm', 'STEEL', 'TON', 5, true),
('STL-TMT-16MM', 'TMT Steel Bars 16mm', 'STEEL', 'TON', 5, true),
('SND-RIVER', 'River Sand - Fine aggregate for concrete', 'AGGREGATE', 'CUM', 50, true),
('SND-M', 'M-Sand - Manufactured sand', 'AGGREGATE', 'CUM', 50, true),
('GRV-20MM', '20mm Gravel - Coarse aggregate 20mm', 'AGGREGATE', 'CUM', 50, true),
('GRV-40MM', '40mm Gravel - Coarse aggregate 40mm', 'AGGREGATE', 'CUM', 50, true),
('BRK-RED', 'Red Clay Bricks - Standard red clay bricks', 'MASONRY', 'NOS', 1000, true),
('BLK-AAC', 'AAC Blocks', 'MASONRY', 'NOS', 500, true),
('PIP-PVC-4IN', 'PVC Pipe 4 inch - PVC drainage pipe 4 inch', 'PLUMBING', 'MTR', 100, true),
('PIP-PVC-6IN', 'PVC Pipe 6 inch - PVC drainage pipe 6 inch', 'PLUMBING', 'MTR', 100, true),
('WIR-CU-2.5', 'Copper Wire 2.5 - Copper wire 2.5 sqmm', 'ELECTRICAL', 'MTR', 500, true),
('WIR-CU-4.0', 'Copper Wire 4.0 - Copper wire 4.0 sqmm', 'ELECTRICAL', 'MTR', 500, true),
('PNT-EMULSION', 'Emulsion Paint - Interior emulsion paint', 'PAINT', 'LTR', 50, true),
('PNT-ENAMEL', 'Enamel Paint - Exterior enamel paint', 'PAINT', 'LTR', 50, true),
('TIL-CER-2X2', 'Ceramic Tiles - Ceramic floor tiles', 'TILES', 'SQM', 100, true),
('TIL-VITRIFIED', 'Vitrified Tiles - Polished vitrified tiles', 'TILES', 'SQM', 100, true),
('DOR-WOOD', 'Wooden Door - Teak wood door', 'DOORS', 'NOS', 10, true),
('WIN-ALUMINUM', 'Aluminum Window - Aluminum sliding window', 'WINDOWS', 'SQM', 20, true),
('CON-M20', 'Concrete M20 - Ready mix concrete M20', 'CONCRETE', 'CUM', 20, true),
('CON-M25', 'Concrete M25 - Ready mix concrete M25', 'CONCRETE', 'CUM', 20, true),
('WTR-MEMBRANE', 'Waterproof Membrane - Waterproofing membrane', 'WATERPROOF', 'SQM', 100, true),
('INS-THERMAL', 'Thermal Insulation', 'INSULATION', 'SQM', 100, true),

-- Insert sample materials (Company C002 - Infrastructure)
('INF-ASPHALT', 'Hot Mix Asphalt - Road surface material', 'ASPHALT', 'TON', 100, true),
('INF-BITUMEN', 'Bitumen 60/70 - Road binding agent', 'BITUMEN', 'TON', 20, true),
('INF-GEOTEXT', 'Geotextile Fabric - Soil reinforcement', 'GEOTEXTILE', 'SQM', 500, true),
('INF-CULVERT', 'Concrete Culvert 1200mm - Drainage system', 'CULVERT', 'MTR', 10, true),
('INF-GUARDRAIL', 'Steel Guardrail - Highway safety barrier', 'SAFETY', 'MTR', 50, true),
('INF-SIGNAGE', 'Traffic Sign Board - Road signage', 'SIGNAGE', 'NOS', 20, true),
('INF-LIGHTING', 'LED Street Light - Road illumination', 'LIGHTING', 'NOS', 15, true),
('INF-MANHOLE', 'Precast Manhole Cover - Utility access', 'UTILITY', 'NOS', 25, true),
('INF-KERB', 'Concrete Kerb Stone - Road edging', 'KERB', 'MTR', 200, true),
('INF-PAVING', 'Interlocking Paving Blocks', 'PAVING', 'SQM', 300, true),
('INF-DRAINAGE', 'HDPE Drainage Pipe 300mm', 'DRAINAGE', 'MTR', 100, true),
('INF-CABLE', 'Underground Power Cable 11KV', 'POWER', 'MTR', 50, true),
('INF-TRANSFORMER', 'Distribution Transformer 500KVA', 'POWER', 'NOS', 2, true),
('INF-POLE', 'Concrete Electric Pole 12m', 'POWER', 'NOS', 10, true),
('INF-FIBER', 'Fiber Optic Cable - Communication', 'TELECOM', 'MTR', 200, true),
('INF-JUNCTION', 'Cable Junction Box - Electrical connection', 'ELECTRICAL', 'NOS', 30, true),
('INF-VALVE', 'Gate Valve 200mm - Water control', 'WATER', 'NOS', 15, true),
('INF-HYDRANT', 'Fire Hydrant - Emergency water access', 'SAFETY', 'NOS', 5, true),
('INF-GRATING', 'Cast Iron Grating - Drain cover', 'DRAINAGE', 'NOS', 50, true),
('INF-BOLLARD', 'Steel Bollard - Traffic control', 'SAFETY', 'NOS', 40, true),
('INF-BARRIER', 'Concrete Barrier - Traffic separation', 'SAFETY', 'MTR', 30, true),
('INF-GEOGRID', 'Geogrid Reinforcement - Soil stabilization', 'GEOTEXTILE', 'SQM', 400, true),
('INF-AGGREGATE', 'Crushed Stone Base Course', 'AGGREGATE', 'TON', 200, true),
('INF-TOPSOIL', 'Topsoil for Landscaping', 'LANDSCAPING', 'CUM', 100, true),
('INF-SEEDMIX', 'Grass Seed Mix - Erosion control', 'LANDSCAPING', 'KG', 50, true)
ON CONFLICT (item_code) DO NOTHING;

-- Insert sample material plant data
INSERT INTO material_plant_data (material_id, plant_id, reorder_level, safety_stock, is_active)
SELECT 
  si.id,
  pl.id,
  CASE 
    WHEN si.category IN ('CEMENT', 'ASPHALT') THEN 100
    WHEN si.category IN ('STEEL', 'BITUMEN') THEN 5
    WHEN si.category IN ('AGGREGATE', 'GEOTEXTILE') THEN 50
    WHEN si.category IN ('POWER', 'TELECOM') THEN 10
    ELSE 20
  END,
  CASE 
    WHEN si.category IN ('CEMENT', 'ASPHALT') THEN 50
    WHEN si.category IN ('STEEL', 'BITUMEN') THEN 2
    WHEN si.category IN ('AGGREGATE', 'GEOTEXTILE') THEN 20
    WHEN si.category IN ('POWER', 'TELECOM') THEN 5
    ELSE 10
  END,
  true
FROM stock_items si
CROSS JOIN plants pl
WHERE si.item_code LIKE 'CEM-%' OR si.item_code LIKE 'STL-%' OR si.item_code LIKE 'SND-%' 
   OR si.item_code LIKE 'GRV-%' OR si.item_code LIKE 'BRK-%' OR si.item_code LIKE 'BLK-%'
   OR si.item_code LIKE 'PIP-%' OR si.item_code LIKE 'WIR-%' OR si.item_code LIKE 'PNT-%'
   OR si.item_code LIKE 'TIL-%' OR si.item_code LIKE 'DOR-%' OR si.item_code LIKE 'WIN-%'
   OR si.item_code LIKE 'CON-%' OR si.item_code LIKE 'WTR-%' OR si.item_code LIKE 'INS-%'
   OR si.item_code LIKE 'INF-%'
ON CONFLICT (material_id, plant_id) DO NOTHING;

-- Insert sample material storage data
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock, reserved_stock, bin_location)
SELECT 
  si.id,
  sl.id,
  CASE 
    WHEN si.category IN ('CEMENT', 'ASPHALT') THEN FLOOR(RANDOM() * 500) + 100
    WHEN si.category IN ('STEEL', 'BITUMEN') THEN FLOOR(RANDOM() * 10) + 2
    WHEN si.category IN ('AGGREGATE', 'GEOTEXTILE') THEN FLOOR(RANDOM() * 100) + 50
    WHEN si.category IN ('ELECTRICAL', 'POWER', 'TELECOM') THEN FLOOR(RANDOM() * 1000) + 100
    WHEN si.category IN ('SAFETY', 'SIGNAGE') THEN FLOOR(RANDOM() * 20) + 5
    ELSE FLOOR(RANDOM() * 50) + 10
  END,
  CASE 
    WHEN RANDOM() > 0.7 THEN FLOOR(RANDOM() * 20) + 5
    ELSE 0
  END,
  NULL
FROM stock_items si
CROSS JOIN storage_locations sl
WHERE si.item_code LIKE 'CEM-%' OR si.item_code LIKE 'STL-%' OR si.item_code LIKE 'SND-%' 
   OR si.item_code LIKE 'GRV-%' OR si.item_code LIKE 'BRK-%' OR si.item_code LIKE 'BLK-%'
   OR si.item_code LIKE 'PIP-%' OR si.item_code LIKE 'WIR-%' OR si.item_code LIKE 'PNT-%'
   OR si.item_code LIKE 'TIL-%' OR si.item_code LIKE 'DOR-%' OR si.item_code LIKE 'WIN-%'
   OR si.item_code LIKE 'CON-%' OR si.item_code LIKE 'WTR-%' OR si.item_code LIKE 'INS-%'
   OR si.item_code LIKE 'INF-%'
ON CONFLICT (material_id, storage_location_id) DO NOTHING;

-- Verify sample data
SELECT 
  'SAMPLE DATA SUMMARY' as status,
  COUNT(*) as total_materials,
  COUNT(DISTINCT category) as categories
FROM stock_items si
WHERE si.item_code LIKE 'CEM-%' OR si.item_code LIKE 'STL-%' OR si.item_code LIKE 'SND-%' 
   OR si.item_code LIKE 'GRV-%' OR si.item_code LIKE 'BRK-%' OR si.item_code LIKE 'BLK-%'
   OR si.item_code LIKE 'PIP-%' OR si.item_code LIKE 'WIR-%' OR si.item_code LIKE 'PNT-%'
   OR si.item_code LIKE 'TIL-%' OR si.item_code LIKE 'DOR-%' OR si.item_code LIKE 'WIN-%'
   OR si.item_code LIKE 'CON-%' OR si.item_code LIKE 'WTR-%' OR si.item_code LIKE 'INS-%'
   OR si.item_code LIKE 'INF-%';
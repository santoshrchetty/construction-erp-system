-- Complete Account Determination Setup and Sample Data
-- This implements the SAP-style Materials Management system

-- First, ensure we have the basic company structure
INSERT INTO company_codes (company_code, company_name, legal_entity_name, currency, country) VALUES
('1000', 'Construction Corp Ltd', 'Construction Corp Ltd', 'USD', 'US')
ON CONFLICT (company_code) DO NOTHING;

-- Complete Account Determination Setup
-- This is the heart of the ERP system - determines GL accounts for each transaction
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id) VALUES
-- Raw Materials (3000) - Construction Materials
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '140000')), -- Inventory Account

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_code = '160000')), -- GR/IR Clearing

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '500000')), -- Material Consumption

-- Finished Products (7920) - Equipment/Assets
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7920'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '150000')), -- Plant & Equipment

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7920'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_code = '160000')), -- GR/IR Clearing

-- Trading Goods (7900) - Construction Materials
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7900'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '140000')), -- Inventory Account

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7900'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_code = '160000')), -- GR/IR Clearing

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7900'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '510000')), -- Project Direct Cost

-- Services (9000) - External Services
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '9000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '530000')) -- External Services Cost

ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Sample Material Master Data
INSERT INTO materials (material_code, material_name, description, base_uom, material_type, standard_price) VALUES
-- Raw Materials (ROH) - Construction Materials
('CEM-OPC-53', 'Cement OPC 53 Grade', 'Ordinary Portland Cement 53 Grade 50kg bag', 'BAG', 'ROH', 8.50),
('STEEL-TMT-12', 'TMT Steel Bar 12mm', '12mm TMT Steel Reinforcement Bar', 'KG', 'ROH', 0.65),
('STEEL-TMT-16', 'TMT Steel Bar 16mm', '16mm TMT Steel Reinforcement Bar', 'KG', 'ROH', 0.68),
('SAND-RIVER', 'River Sand', 'Fine River Sand for Construction', 'M3', 'ROH', 25.00),
('AGGREGATE-20', 'Aggregate 20mm', '20mm Crushed Stone Aggregate', 'M3', 'ROH', 30.00),
('BRICK-RED', 'Red Clay Bricks', 'Standard Red Clay Building Bricks', 'NOS', 'ROH', 0.12),

-- Finished Goods (FERT) - Equipment/Assets  
('DG-SET-125', 'Diesel Generator 125KVA', '125KVA Diesel Generator Set', 'EA', 'FERT', 15000.00),
('CRANE-TOWER', 'Tower Crane', 'Construction Tower Crane', 'EA', 'FERT', 85000.00),
('MIXER-CONCRETE', 'Concrete Mixer', 'Portable Concrete Mixer Machine', 'EA', 'FERT', 2500.00),

-- Services (SERV) - External Services
('LAB-INST-ELEC', 'Electrical Installation', 'Electrical Installation Labor Service', 'HRS', 'SERV', 25.00),
('LAB-INST-PLUMB', 'Plumbing Installation', 'Plumbing Installation Labor Service', 'HRS', 'SERV', 22.00),
('CONSULT-STRUCT', 'Structural Consulting', 'Structural Engineering Consulting', 'HRS', 'SERV', 75.00)

ON CONFLICT (material_code) DO NOTHING;

-- Update materials with proper valuation classes
UPDATE materials SET 
    valuation_class_id = (SELECT id FROM valuation_classes WHERE class_code = '7900')
WHERE material_type = 'ROH';

UPDATE materials SET 
    valuation_class_id = (SELECT id FROM valuation_classes WHERE class_code = '7920')
WHERE material_type = 'FERT';

UPDATE materials SET 
    valuation_class_id = (SELECT id FROM valuation_classes WHERE class_code = '9000')
WHERE material_type = 'SERV';

-- Sample Stock Levels for Materials
INSERT INTO stock_levels (material_id, current_stock, available_stock) 
SELECT m.id, 
    CASE 
        WHEN m.material_type = 'ROH' THEN 500.0
        WHEN m.material_type = 'FERT' THEN 2.0
        ELSE 0.0
    END,
    CASE 
        WHEN m.material_type = 'ROH' THEN 500.0
        WHEN m.material_type = 'FERT' THEN 2.0
        ELSE 0.0
    END
FROM materials m 
ON CONFLICT (material_id, storage_location) DO NOTHING;

-- Sample Material Movements (Business Transactions)
INSERT INTO material_movements (material_id, movement_type, quantity, unit_price, reference_doc, movement_date, posting_date) VALUES
-- Goods Receipt (101) - Cement
((SELECT id FROM materials WHERE material_code = 'CEM-OPC-53'), '101', 100.0, 8.50, 'PO-001', CURRENT_DATE, CURRENT_DATE),
-- Goods Receipt (101) - Steel
((SELECT id FROM materials WHERE material_code = 'STEEL-TMT-12'), '101', 1000.0, 0.65, 'PO-002', CURRENT_DATE, CURRENT_DATE),
-- Issue to Project (261) - Cement to Project
((SELECT id FROM materials WHERE material_code = 'CEM-OPC-53'), '261', -80.0, 8.50, 'WBS-FOUND', CURRENT_DATE, CURRENT_DATE),
-- Issue to Project (261) - Steel to Project  
((SELECT id FROM materials WHERE material_code = 'STEEL-TMT-12'), '261', -800.0, 0.65, 'WBS-STRUCT', CURRENT_DATE, CURRENT_DATE),
-- Issue to Cost Center (201) - Materials for Site Office
((SELECT id FROM materials WHERE material_code = 'BRICK-RED'), '201', -50.0, 0.12, 'CC-SITE', CURRENT_DATE, CURRENT_DATE)

ON CONFLICT DO NOTHING;

-- Sample Purchase Orders
INSERT INTO purchase_orders (po_number, vendor_id, po_date, delivery_date, total_amount, status) VALUES
('PO-001', (SELECT id FROM vendors WHERE vendor_code = 'VEN-001'), CURRENT_DATE, CURRENT_DATE + INTERVAL '7 days', 8500.00, 'OPEN'),
('PO-002', (SELECT id FROM vendors WHERE vendor_code = 'VEN-002'), CURRENT_DATE, CURRENT_DATE + INTERVAL '10 days', 6500.00, 'OPEN')
ON CONFLICT (po_number) DO NOTHING;

-- Sample Purchase Order Items
INSERT INTO purchase_order_items (po_id, item_number, material_id, quantity, unit_price, total_price, delivery_date) VALUES
((SELECT id FROM purchase_orders WHERE po_number = 'PO-001'), 10, (SELECT id FROM materials WHERE material_code = 'CEM-OPC-53'), 100.0, 8.50, 850.00, CURRENT_DATE + INTERVAL '7 days'),
((SELECT id FROM purchase_orders WHERE po_number = 'PO-002'), 10, (SELECT id FROM materials WHERE material_code = 'STEEL-TMT-12'), 1000.0, 0.65, 650.00, CURRENT_DATE + INTERVAL '10 days')
ON CONFLICT (po_id, item_number) DO NOTHING;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_materials_type_valuation ON materials(material_type, valuation_class_id);
CREATE INDEX IF NOT EXISTS idx_material_movements_material_type ON material_movements(material_id, movement_type);
CREATE INDEX IF NOT EXISTS idx_account_determination_company_valuation ON account_determination(company_code_id, valuation_class_id);
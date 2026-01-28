-- Add standard SAP material types
INSERT INTO material_types (material_type_code, material_type_name, description, is_active)
VALUES
    ('FERT', 'Finished Product', 'Finished goods ready for sale', true),
    ('HALB', 'Semi-Finished Product', 'Semi-finished goods for further processing', true),
    ('ROH', 'Raw Material', 'Raw materials for production', true),
    ('HIBE', 'Operating Supplies', 'Operating supplies and consumables', true),
    ('VERP', 'Packaging Material', 'Packaging materials', true),
    ('HAWA', 'Trading Goods', 'Goods for resale', true),
    ('DIEN', 'Services', 'Service materials', true),
    ('NLAG', 'Non-Stock Material', 'Non-stock materials', true)
ON CONFLICT (material_type_code) DO NOTHING;

-- Verify
SELECT material_type_code, material_type_name FROM material_types ORDER BY material_type_code;

-- Data Migration Script: stock_items to ERP-Standard Materials
-- Step 1.2: Migrate existing data to new structure

-- 1. Backup existing data (optional - for safety)
CREATE TABLE IF NOT EXISTS stock_items_backup AS 
SELECT * FROM stock_items WHERE 1=1;

-- 2. Add missing categories from stock_items to material_categories
INSERT INTO material_categories (category_code, category_name, description)
SELECT DISTINCT 
  category as category_code,
  category as category_name,
  'Migrated from stock_items' as description
FROM stock_items 
WHERE category IS NOT NULL 
  AND category NOT IN (SELECT category_code FROM material_categories)
ON CONFLICT (category_code) DO NOTHING;

-- 3. Add missing columns and constraints to material_plant_data for ERP business logic
DO $$
BEGIN
    -- Add procurement columns
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'procurement_type') THEN
        ALTER TABLE material_plant_data ADD COLUMN procurement_type VARCHAR(20) DEFAULT 'E';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'mrp_type') THEN
        ALTER TABLE material_plant_data ADD COLUMN mrp_type VARCHAR(20) DEFAULT 'PD';
    END IF;
    
    -- Add stock parameters
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'reorder_point') THEN
        ALTER TABLE material_plant_data ADD COLUMN reorder_point DECIMAL(15,3) DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'safety_stock') THEN
        ALTER TABLE material_plant_data ADD COLUMN safety_stock DECIMAL(15,3) DEFAULT 0;
    END IF;
    
    -- Add planning parameters
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'minimum_lot_size') THEN
        ALTER TABLE material_plant_data ADD COLUMN minimum_lot_size DECIMAL(15,3) DEFAULT 1;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'planned_delivery_time') THEN
        ALTER TABLE material_plant_data ADD COLUMN planned_delivery_time INTEGER DEFAULT 0;
    END IF;
    
    -- Add status and audit columns
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'plant_status') THEN
        ALTER TABLE material_plant_data ADD COLUMN plant_status VARCHAR(20) DEFAULT 'ACTIVE';
    END IF;
    
    -- Add unique constraint if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'material_plant_data' AND constraint_name = 'material_plant_data_material_code_plant_code_key') THEN
        ALTER TABLE material_plant_data ADD CONSTRAINT material_plant_data_material_code_plant_code_key UNIQUE (material_code, plant_code);
    END IF;
END $$;

-- 4. Check actual structure of material_plant_data table
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'material_plant_data' 
ORDER BY ordinal_position;

-- 5. Check what columns exist in stock_items table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'stock_items' 
ORDER BY ordinal_position;

-- 6. Migrate materials to new materials table (using available columns)
INSERT INTO materials (
  material_code,
  material_name,
  description,
  category,
  base_uom,
  material_type,
  is_active
)
SELECT DISTINCT
  COALESCE(item_code, id::text) as material_code,
  COALESCE(item_code, 'Unknown Material') as material_name,
  COALESCE(description, item_code, 'Unknown Material') as description,
  COALESCE(category, 'CEMENT') as category,
  COALESCE(unit, 'EA') as base_uom,
  'FERT' as material_type,
  COALESCE(is_active, true) as is_active
FROM stock_items
WHERE COALESCE(item_code, id::text) IS NOT NULL
ON CONFLICT (material_code) DO NOTHING;

-- 7. Create default plant extensions for existing materials (skip for now)
-- Note: material_plant_data table structure needs to be verified first
-- Uncomment after confirming correct column names
/*
INSERT INTO material_plant_data (
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
  m.material_code,
  p.plant_code,
  'E' as procurement_type, -- Default to Purchase
  'PD' as mrp_type, -- Default to MRP
  0 as reorder_point,
  0 as safety_stock,
  1 as minimum_lot_size,
  0 as planned_delivery_time,
  'ACTIVE' as plant_status,
  true as is_active
FROM materials m
CROSS JOIN plants p
WHERE p.is_active = true
ON CONFLICT (material_code, plant_code) DO NOTHING;
*/

-- 8. Migrate pricing data to new structure (skip for now)
-- Note: Need to check actual price column names in stock_items
-- Uncomment after confirming correct column names
/*
INSERT INTO material_pricing (
  material_code,
  company_code,
  plant_code,
  price_type,
  price,
  currency,
  valid_from,
  created_at,
  is_active
)
SELECT DISTINCT
  COALESCE(si.item_code, si.id::text) as material_code,
  cc.company_code,
  p.plant_code,
  'STD' as price_type,
  COALESCE(si.price, si.unit_price, 0) as price,
  COALESCE(cc.currency, 'USD') as currency,
  CURRENT_DATE as valid_from,
  NOW() as created_at,
  true as is_active
FROM stock_items si
JOIN plants p ON p.is_active = true
JOIN company_codes cc ON p.company_code_id = cc.id
WHERE COALESCE(si.item_code, si.id::text) IS NOT NULL
  AND COALESCE(si.price, si.unit_price, 0) > 0
ON CONFLICT (material_code, company_code, plant_code, price_type, valid_from) DO NOTHING;
*/

-- 9. Update stock_balances to reference new material structure
-- Add material_code column if it doesn't exist
ALTER TABLE stock_balances 
ADD COLUMN IF NOT EXISTS material_code VARCHAR(50);

-- Update material_code in stock_balances from stock_items
UPDATE stock_balances sb
SET material_code = COALESCE(si.item_code, si.id::text)
FROM stock_items si
WHERE sb.stock_item_id = si.id
  AND sb.material_code IS NULL;

-- 10. Create foreign key constraint (after data is populated)
ALTER TABLE stock_balances 
ADD CONSTRAINT fk_stock_balances_material 
FOREIGN KEY (material_code) REFERENCES materials(material_code);

-- 11. Verification queries
SELECT 'Migration Summary' as info;
SELECT 'Original stock_items count' as description, COUNT(*) as count FROM stock_items;
SELECT 'Migrated materials count' as description, COUNT(*) as count FROM materials;
SELECT 'Material plant extensions count' as description, COUNT(*) as count FROM material_plant_data;
SELECT 'Material pricing records count' as description, COUNT(*) as count FROM material_pricing;
SELECT 'Stock balances with material_code' as description, COUNT(*) as count FROM stock_balances WHERE material_code IS NOT NULL;

-- 12. Sample data verification
SELECT 'Sample migrated materials:' as info;
SELECT material_code, material_name, category, base_uom, material_type 
FROM materials 
ORDER BY material_code 
LIMIT 5;

SELECT 'Sample plant extensions:' as info;
SELECT mpd.material_code, mpd.plant_code, mpd.procurement_type, mpd.mrp_type, mpd.plant_status
FROM material_plant_data mpd
JOIN materials m ON mpd.material_code = m.material_code
ORDER BY mpd.material_code, mpd.plant_code
LIMIT 5;

SELECT 'Sample pricing data:' as info;
SELECT mp.material_code, mp.company_code, mp.plant_code, mp.price, mp.currency
FROM material_pricing mp
JOIN materials m ON mp.material_code = m.material_code
ORDER BY mp.material_code, mp.company_code
LIMIT 5;
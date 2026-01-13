-- STEP 3: MATERIAL MASTER INTEGRATION

-- Add material validation fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS material_description VARCHAR(100),
ADD COLUMN IF NOT EXISTS base_unit VARCHAR(10),
ADD COLUMN IF NOT EXISTS standard_price DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS price_unit INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS material_group VARCHAR(20),
ADD COLUMN IF NOT EXISTS procurement_type VARCHAR(1) DEFAULT 'F'; -- F=External, E=Internal

-- Create material validation function
CREATE OR REPLACE FUNCTION validate_material_for_po(
    p_material_code VARCHAR(50),
    p_plant_code VARCHAR(10) DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    description VARCHAR(100),
    base_unit VARCHAR(10),
    standard_price DECIMAL(12,2),
    material_group VARCHAR(20),
    error_message TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN mm.material_code IS NOT NULL THEN true ELSE false END as is_valid,
        mm.description,
        mm.base_unit,
        mm.standard_price,
        mm.material_group,
        CASE 
            WHEN mm.material_code IS NULL THEN 'Material not found in master data'
            WHEN mm.is_active = false THEN 'Material is inactive'
            WHEN p_plant_code IS NOT NULL AND NOT EXISTS (
                SELECT 1 FROM material_plant_data mpd 
                WHERE mpd.material_code = mm.material_code 
                AND mpd.plant_code = p_plant_code
            ) THEN 'Material not extended to plant ' || p_plant_code
            ELSE NULL
        END as error_message
    FROM material_master mm
    WHERE mm.material_code = p_material_code;
    
    -- If no record found, return invalid result
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::VARCHAR(100), NULL::VARCHAR(10), NULL::DECIMAL(12,2), NULL::VARCHAR(20), 'Material not found'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create function to get material price from history
CREATE OR REPLACE FUNCTION get_material_price(
    p_material_code VARCHAR(50),
    p_vendor_code VARCHAR(20),
    p_price_date DATE DEFAULT CURRENT_DATE
) RETURNS DECIMAL(12,2) AS $$
DECLARE
    v_price DECIMAL(12,2);
BEGIN
    -- Get latest price from price history
    SELECT price INTO v_price
    FROM material_price_history 
    WHERE material_code = p_material_code 
      AND vendor_code = p_vendor_code
      AND p_price_date BETWEEN valid_from AND valid_to
    ORDER BY created_at DESC
    LIMIT 1;
    
    -- If no price history, get standard price from material master
    IF v_price IS NULL THEN
        SELECT standard_price INTO v_price
        FROM material_master 
        WHERE material_code = p_material_code;
    END IF;
    
    RETURN COALESCE(v_price, 0);
END;
$$ LANGUAGE plpgsql;

-- Create function to auto-populate material data in PO items
CREATE OR REPLACE FUNCTION populate_material_data()
RETURNS TRIGGER AS $$
DECLARE
    v_material_data RECORD;
BEGIN
    -- Get material master data
    SELECT * INTO v_material_data
    FROM validate_material_for_po(NEW.material_code, NEW.plant_code);
    
    -- Populate material fields if valid
    IF v_material_data.is_valid THEN
        NEW.material_description := v_material_data.description;
        NEW.base_unit := v_material_data.base_unit;
        NEW.material_group := v_material_data.material_group;
        
        -- Set unit to base unit if not specified
        IF NEW.unit IS NULL OR NEW.unit = '' THEN
            NEW.unit := v_material_data.base_unit;
        END IF;
        
        -- Get price if not specified
        IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
            NEW.unit_price := get_material_price(
                NEW.material_code, 
                (SELECT vendor_code FROM purchase_orders WHERE po_number = NEW.po_number)
            );
        END IF;
        
        -- Calculate line total
        NEW.line_total := NEW.quantity * NEW.unit_price;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for material data population
DROP TRIGGER IF EXISTS trg_populate_material_data ON purchase_order_items;
CREATE TRIGGER trg_populate_material_data
    BEFORE INSERT OR UPDATE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION populate_material_data();

-- Create function to update material price history
CREATE OR REPLACE FUNCTION update_material_price_history(
    p_material_code VARCHAR(50),
    p_vendor_code VARCHAR(20),
    p_price DECIMAL(12,2),
    p_unit VARCHAR(10),
    p_valid_from DATE DEFAULT CURRENT_DATE
) RETURNS VOID AS $$
BEGIN
    -- End current price validity
    UPDATE material_price_history 
    SET valid_to = p_valid_from - INTERVAL '1 day'
    WHERE material_code = p_material_code 
      AND vendor_code = p_vendor_code
      AND valid_to = '9999-12-31';
    
    -- Insert new price
    INSERT INTO material_price_history (
        material_code, vendor_code, price, unit, valid_from, valid_to
    ) VALUES (
        p_material_code, p_vendor_code, p_price, p_unit, p_valid_from, '9999-12-31'
    );
END;
$$ LANGUAGE plpgsql;

-- Create view for material search with pricing
CREATE OR REPLACE VIEW v_material_search AS
SELECT 
    mm.material_code,
    mm.description,
    mm.base_unit,
    mm.standard_price,
    mm.material_group,
    mm.material_type,
    COALESCE(mph.price, mm.standard_price) as latest_price,
    mph.vendor_code as price_vendor,
    mph.valid_from as price_date
FROM material_master mm
LEFT JOIN LATERAL (
    SELECT DISTINCT ON (material_code) 
        material_code, vendor_code, price, valid_from
    FROM material_price_history 
    WHERE material_code = mm.material_code
      AND CURRENT_DATE BETWEEN valid_from AND valid_to
    ORDER BY material_code, created_at DESC
) mph ON true
WHERE mm.is_active = true;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_material_price_history_lookup 
ON material_price_history(material_code, vendor_code, valid_from, valid_to);

CREATE INDEX IF NOT EXISTS idx_poi_material_lookup 
ON purchase_order_items(material_code, po_number);

SELECT 'STEP 3 COMPLETE - MATERIAL MASTER INTEGRATED' as status;
-- STEP 3: MATERIAL MASTER INTEGRATION (USING EXISTING TABLES)

-- Add material validation fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS material_description VARCHAR(100),
ADD COLUMN IF NOT EXISTS base_unit VARCHAR(10),
ADD COLUMN IF NOT EXISTS standard_price DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS material_group VARCHAR(20),
ADD COLUMN IF NOT EXISTS material_type VARCHAR(10);

-- Create material validation function using existing tables
CREATE OR REPLACE FUNCTION validate_material_for_po(
    p_material_code VARCHAR(50),
    p_plant_code VARCHAR(10) DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    description VARCHAR(100),
    base_unit VARCHAR(10),
    standard_price DECIMAL(12,2),
    material_group VARCHAR(20),
    material_type VARCHAR(10),
    error_message TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN mmv.material_code IS NOT NULL THEN true ELSE false END as is_valid,
        mmv.description,
        mmv.base_unit,
        mmv.standard_price,
        mmv.material_group,
        mmv.material_type,
        CASE 
            WHEN mmv.material_code IS NULL THEN 'Material not found in master data'
            WHEN p_plant_code IS NOT NULL AND NOT EXISTS (
                SELECT 1 FROM material_plant_data mpd 
                WHERE mpd.material_code = mmv.material_code 
                AND mpd.plant_code = p_plant_code
            ) THEN 'Material not extended to plant ' || p_plant_code
            ELSE NULL
        END as error_message
    FROM material_master_view mmv
    WHERE mmv.material_code = p_material_code;
    
    -- If no record found, return invalid result
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::VARCHAR(100), NULL::VARCHAR(10), NULL::DECIMAL(12,2), NULL::VARCHAR(20), NULL::VARCHAR(10), 'Material not found'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create function to get material price from history or standard price
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
    
    -- If no price history, get standard price from material master view
    IF v_price IS NULL THEN
        SELECT standard_price INTO v_price
        FROM material_master_view 
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
    v_vendor_code VARCHAR(20);
BEGIN
    -- Skip if material_code is empty
    IF NEW.material_code IS NULL OR NEW.material_code = '' THEN
        RETURN NEW;
    END IF;
    
    -- Get vendor code from PO
    SELECT vendor_code INTO v_vendor_code
    FROM purchase_orders 
    WHERE po_number = NEW.po_number;
    
    -- Get material master data
    SELECT * INTO v_material_data
    FROM validate_material_for_po(NEW.material_code, NEW.plant_code);
    
    -- Populate material fields if valid
    IF v_material_data.is_valid THEN
        NEW.material_description := v_material_data.description;
        NEW.base_unit := v_material_data.base_unit;
        NEW.material_group := v_material_data.material_group;
        NEW.material_type := v_material_data.material_type;
        
        -- Set unit to base unit if not specified
        IF NEW.unit IS NULL OR NEW.unit = '' THEN
            NEW.unit := v_material_data.base_unit;
        END IF;
        
        -- Get price if not specified
        IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
            NEW.unit_price := get_material_price(NEW.material_code, v_vendor_code);
            NEW.standard_price := v_material_data.standard_price;
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

-- Create function to search materials
CREATE OR REPLACE FUNCTION search_materials(
    p_search_term VARCHAR(100) DEFAULT NULL,
    p_material_group VARCHAR(20) DEFAULT NULL,
    p_plant_code VARCHAR(10) DEFAULT NULL
) RETURNS TABLE (
    material_code VARCHAR(50),
    description VARCHAR(100),
    base_unit VARCHAR(10),
    standard_price DECIMAL(12,2),
    material_group VARCHAR(20),
    material_type VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mmv.material_code,
        mmv.description,
        mmv.base_unit,
        mmv.standard_price,
        mmv.material_group,
        mmv.material_type
    FROM material_master_view mmv
    WHERE (p_search_term IS NULL OR 
           mmv.material_code ILIKE '%' || p_search_term || '%' OR 
           mmv.description ILIKE '%' || p_search_term || '%')
      AND (p_material_group IS NULL OR mmv.material_group = p_material_group)
      AND (p_plant_code IS NULL OR EXISTS (
          SELECT 1 FROM material_plant_data mpd 
          WHERE mpd.material_code = mmv.material_code 
          AND mpd.plant_code = p_plant_code
      ))
    ORDER BY mmv.material_code
    LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- Create view for material search with pricing
CREATE OR REPLACE VIEW v_material_search_with_prices AS
SELECT 
    mmv.material_code,
    mmv.description,
    mmv.base_unit,
    mmv.standard_price,
    mmv.material_group,
    mmv.material_type,
    mph.vendor_code,
    mph.price as vendor_price,
    mph.valid_from as price_date
FROM material_master_view mmv
LEFT JOIN material_price_history mph ON mmv.material_code = mph.material_code
    AND CURRENT_DATE BETWEEN mph.valid_from AND mph.valid_to;

-- Create function to update material price history from PO
CREATE OR REPLACE FUNCTION update_material_price_from_po()
RETURNS TRIGGER AS $$
DECLARE
    v_vendor_code VARCHAR(20);
BEGIN
    -- Get vendor code from PO
    SELECT vendor_code INTO v_vendor_code
    FROM purchase_orders 
    WHERE po_number = NEW.po_number;
    
    -- Update price history if material and price are valid
    IF NEW.material_code IS NOT NULL AND NEW.unit_price > 0 AND v_vendor_code IS NOT NULL THEN
        -- End current price validity
        UPDATE material_price_history 
        SET valid_to = CURRENT_DATE - INTERVAL '1 day'
        WHERE material_code = NEW.material_code 
          AND vendor_code = v_vendor_code
          AND valid_to = '9999-12-31';
        
        -- Insert new price
        INSERT INTO material_price_history (
            material_code, vendor_code, price, unit, valid_from, valid_to
        ) VALUES (
            NEW.material_code, v_vendor_code, NEW.unit_price, NEW.unit, 
            CURRENT_DATE, '9999-12-31'
        )
        ON CONFLICT (material_code, vendor_code, valid_from) DO UPDATE SET
            price = EXCLUDED.price,
            unit = EXCLUDED.unit;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update price history from PO
DROP TRIGGER IF EXISTS trg_update_price_history ON purchase_order_items;
CREATE TRIGGER trg_update_price_history
    AFTER INSERT OR UPDATE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_material_price_from_po();

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_material_master_view_search 
ON material_master_view(material_code, description, material_group);

CREATE INDEX IF NOT EXISTS idx_material_plant_data_lookup 
ON material_plant_data(material_code, plant_code);

CREATE INDEX IF NOT EXISTS idx_poi_material_validation 
ON purchase_order_items(material_code, plant_code);

SELECT 'STEP 3 COMPLETE - MATERIAL MASTER INTEGRATED WITH EXISTING TABLES' as status;
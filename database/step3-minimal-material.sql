-- STEP 3: MINIMAL MATERIAL INTEGRATION (CORRECT COLUMNS)

-- Add material fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS material_description VARCHAR(100),
ADD COLUMN IF NOT EXISTS base_unit VARCHAR(10);

-- Create simple material lookup function
CREATE OR REPLACE FUNCTION get_material_info(p_material_code VARCHAR(50))
RETURNS TABLE (
    description VARCHAR(100),
    base_unit VARCHAR(10),
    standard_price DECIMAL(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mmv.description,
        mmv.base_uom as base_unit,
        mmv.standard_price
    FROM material_master_view mmv
    WHERE mmv.material_code = p_material_code;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-populate material data
CREATE OR REPLACE FUNCTION auto_populate_material()
RETURNS TRIGGER AS $$
DECLARE
    v_material RECORD;
BEGIN
    IF NEW.material_code IS NOT NULL AND NEW.material_code != '' THEN
        SELECT * INTO v_material FROM get_material_info(NEW.material_code);
        
        IF FOUND THEN
            NEW.material_description := v_material.description;
            NEW.base_unit := v_material.base_unit;
            
            IF NEW.unit IS NULL OR NEW.unit = '' THEN
                NEW.unit := v_material.base_unit;
            END IF;
            
            IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
                NEW.unit_price := COALESCE(v_material.standard_price, 0);
            END IF;
        END IF;
    END IF;
    
    -- Calculate line total
    NEW.line_total := NEW.quantity * NEW.unit_price;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trg_auto_populate_material ON purchase_order_items;
CREATE TRIGGER trg_auto_populate_material
    BEFORE INSERT OR UPDATE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION auto_populate_material();

SELECT 'STEP 3 COMPLETE - MINIMAL MATERIAL INTEGRATION' as status;
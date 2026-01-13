-- STEP 3: SIMPLIFIED MATERIAL INTEGRATION (WITHOUT MATERIAL MASTER)

-- Add material fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS material_description VARCHAR(100),
ADD COLUMN IF NOT EXISTS base_unit VARCHAR(10),
ADD COLUMN IF NOT EXISTS standard_price DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS material_group VARCHAR(20);

-- Create simple material validation function using price history
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
    
    RETURN COALESCE(v_price, 0);
END;
$$ LANGUAGE plpgsql;

-- Create function to auto-calculate line totals
CREATE OR REPLACE FUNCTION calculate_po_line_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate line total
    NEW.line_total := NEW.quantity * NEW.unit_price;
    
    -- Calculate tax amount if tax rate is specified
    IF NEW.tax_rate IS NOT NULL AND NEW.tax_rate > 0 THEN
        NEW.tax_amount := NEW.line_total * (NEW.tax_rate / 100);
    END IF;
    
    -- Calculate net amount
    NEW.net_amount := NEW.line_total + COALESCE(NEW.tax_amount, 0) - COALESCE(NEW.discount_amount, 0);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for line total calculation
DROP TRIGGER IF EXISTS trg_calculate_line_total ON purchase_order_items;
CREATE TRIGGER trg_calculate_line_total
    BEFORE INSERT OR UPDATE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION calculate_po_line_total();

-- Create function to update PO totals when items change
CREATE OR REPLACE FUNCTION update_po_totals()
RETURNS TRIGGER AS $$
DECLARE
    v_po_number VARCHAR(20);
    v_total_amount DECIMAL(15,2);
    v_tax_amount DECIMAL(15,2);
    v_net_amount DECIMAL(15,2);
BEGIN
    -- Get PO number from NEW or OLD record
    v_po_number := COALESCE(NEW.po_number, OLD.po_number);
    
    -- Calculate totals from all items
    SELECT 
        COALESCE(SUM(line_total), 0),
        COALESCE(SUM(tax_amount), 0),
        COALESCE(SUM(net_amount), 0)
    INTO v_total_amount, v_tax_amount, v_net_amount
    FROM purchase_order_items 
    WHERE po_number = v_po_number;
    
    -- Update PO header totals
    UPDATE purchase_orders 
    SET 
        total_amount = v_total_amount,
        tax_amount = v_tax_amount,
        net_amount = v_net_amount
    WHERE po_number = v_po_number;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create trigger for PO total updates
DROP TRIGGER IF EXISTS trg_update_po_totals ON purchase_order_items;
CREATE TRIGGER trg_update_po_totals
    AFTER INSERT OR UPDATE OR DELETE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_po_totals();

-- Create function to update material price history from PO
CREATE OR REPLACE FUNCTION update_material_price_from_po(
    p_material_code VARCHAR(50),
    p_vendor_code VARCHAR(20),
    p_price DECIMAL(12,2),
    p_unit VARCHAR(10),
    p_po_date DATE DEFAULT CURRENT_DATE
) RETURNS VOID AS $$
BEGIN
    -- Insert/update price history
    INSERT INTO material_price_history (
        material_code, vendor_code, price, unit, valid_from, valid_to
    ) VALUES (
        p_material_code, p_vendor_code, p_price, p_unit, p_po_date, '9999-12-31'
    )
    ON CONFLICT (material_code, vendor_code, valid_from) 
    DO UPDATE SET 
        price = EXCLUDED.price,
        unit = EXCLUDED.unit;
END;
$$ LANGUAGE plpgsql;

-- Create view for material price lookup
CREATE OR REPLACE VIEW v_material_prices AS
SELECT 
    material_code,
    vendor_code,
    price,
    unit,
    valid_from,
    valid_to,
    ROW_NUMBER() OVER (PARTITION BY material_code, vendor_code ORDER BY valid_from DESC) as rn
FROM material_price_history
WHERE CURRENT_DATE BETWEEN valid_from AND valid_to;

-- Create function to get materials with recent prices
CREATE OR REPLACE FUNCTION get_materials_with_prices(p_search VARCHAR(50) DEFAULT NULL)
RETURNS TABLE (
    material_code VARCHAR(50),
    description VARCHAR(100),
    unit VARCHAR(10),
    latest_price DECIMAL(12,2),
    vendor_code VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        poi.material_code,
        poi.material_description as description,
        poi.unit,
        mp.price as latest_price,
        mp.vendor_code
    FROM purchase_order_items poi
    LEFT JOIN v_material_prices mp ON poi.material_code = mp.material_code AND mp.rn = 1
    WHERE (p_search IS NULL OR 
           poi.material_code ILIKE '%' || p_search || '%' OR 
           poi.material_description ILIKE '%' || p_search || '%')
      AND poi.material_code IS NOT NULL
    ORDER BY poi.material_code;
END;
$$ LANGUAGE plpgsql;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_material_price_history_lookup 
ON material_price_history(material_code, vendor_code, valid_from, valid_to);

CREATE INDEX IF NOT EXISTS idx_poi_material_lookup 
ON purchase_order_items(material_code, po_number);

CREATE INDEX IF NOT EXISTS idx_poi_totals_lookup 
ON purchase_order_items(po_number, line_total, tax_amount);

SELECT 'STEP 3 COMPLETE - SIMPLIFIED MATERIAL INTEGRATION' as status;
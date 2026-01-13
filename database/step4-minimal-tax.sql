-- STEP 4: MINIMAL TAX CALCULATION ENGINE

-- Create tax codes master table
CREATE TABLE IF NOT EXISTS tax_codes (
    tax_code VARCHAR(10) PRIMARY KEY,
    tax_name VARCHAR(50) NOT NULL,
    tax_rate DECIMAL(5,2) NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Insert standard GST tax codes
INSERT INTO tax_codes (tax_code, tax_name, tax_rate) VALUES
('GST0', 'GST 0%', 0.00),
('GST5', 'GST 5%', 5.00),
('GST12', 'GST 12%', 12.00),
('GST18', 'GST 18%', 18.00),
('GST28', 'GST 28%', 28.00)
ON CONFLICT (tax_code) DO NOTHING;

-- Add tax breakdown fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS po_id INTEGER,
ADD COLUMN IF NOT EXISTS cgst_rate DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS sgst_rate DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS igst_rate DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cgst_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS sgst_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS igst_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_tax_amount DECIMAL(15,2) DEFAULT 0;

-- Create simple tax calculation function
CREATE OR REPLACE FUNCTION calculate_item_tax()
RETURNS TRIGGER AS $$
DECLARE
    v_tax_rate DECIMAL(5,2) := 18.00;
BEGIN
    -- Get tax rate from tax codes
    SELECT tc.tax_rate INTO v_tax_rate
    FROM tax_codes tc
    WHERE tc.tax_code = COALESCE(NEW.tax_code, 'GST18') AND tc.is_active = true;
    
    v_tax_rate := COALESCE(v_tax_rate, 18.00);
    
    -- Calculate line total
    NEW.line_total := NEW.quantity * NEW.unit_price;
    
    -- Apply discount
    IF NEW.discount_percent > 0 THEN
        NEW.discount_amount := NEW.line_total * NEW.discount_percent / 100;
        NEW.line_total := NEW.line_total - NEW.discount_amount;
    END IF;
    
    -- Calculate tax (assume intrastate - CGST + SGST)
    NEW.cgst_rate := v_tax_rate / 2;
    NEW.sgst_rate := v_tax_rate / 2;
    NEW.igst_rate := 0;
    NEW.cgst_amount := ROUND(NEW.line_total * (v_tax_rate / 2) / 100, 2);
    NEW.sgst_amount := ROUND(NEW.line_total * (v_tax_rate / 2) / 100, 2);
    NEW.igst_amount := 0;
    NEW.total_tax_amount := NEW.cgst_amount + NEW.sgst_amount;
    NEW.tax_amount := NEW.total_tax_amount;
    NEW.net_amount := NEW.line_total + NEW.total_tax_amount;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trg_calculate_item_tax ON purchase_order_items;
CREATE TRIGGER trg_calculate_item_tax
    BEFORE INSERT OR UPDATE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION calculate_item_tax();

SELECT 'STEP 4 COMPLETE - MINIMAL TAX CALCULATION' as status;
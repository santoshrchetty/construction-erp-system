-- STEP 4: TAX CALCULATION ENGINE

-- Create tax codes master table
CREATE TABLE IF NOT EXISTS tax_codes (
    tax_code VARCHAR(10) PRIMARY KEY,
    tax_name VARCHAR(50) NOT NULL,
    tax_rate DECIMAL(5,2) NOT NULL,
    tax_type VARCHAR(20) DEFAULT 'GST', -- GST, IGST, CGST, SGST
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert standard GST tax codes
INSERT INTO tax_codes (tax_code, tax_name, tax_rate, tax_type) VALUES
('GST0', 'GST 0%', 0.00, 'GST'),
('GST5', 'GST 5%', 5.00, 'GST'),
('GST12', 'GST 12%', 12.00, 'GST'),
('GST18', 'GST 18%', 18.00, 'GST'),
('GST28', 'GST 28%', 28.00, 'GST'),
('IGST5', 'IGST 5%', 5.00, 'IGST'),
('IGST12', 'IGST 12%', 12.00, 'IGST'),
('IGST18', 'IGST 18%', 18.00, 'IGST'),
('IGST28', 'IGST 28%', 28.00, 'IGST')
ON CONFLICT (tax_code) DO NOTHING;

-- Add tax breakdown fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS cgst_rate DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS sgst_rate DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS igst_rate DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cgst_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS sgst_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS igst_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_tax_amount DECIMAL(15,2) DEFAULT 0;

-- Create function to calculate GST breakdown
CREATE OR REPLACE FUNCTION calculate_gst_breakdown(
    p_tax_code VARCHAR(10),
    p_line_amount DECIMAL(15,2),
    p_vendor_state VARCHAR(50) DEFAULT NULL,
    p_company_state VARCHAR(50) DEFAULT 'MAHARASHTRA'
) RETURNS TABLE (
    cgst_rate DECIMAL(5,2),
    sgst_rate DECIMAL(5,2),
    igst_rate DECIMAL(5,2),
    cgst_amount DECIMAL(15,2),
    sgst_amount DECIMAL(15,2),
    igst_amount DECIMAL(15,2),
    total_tax_amount DECIMAL(15,2)
) AS $$
DECLARE
    v_tax_rate DECIMAL(5,2);
    v_is_interstate BOOLEAN;
BEGIN
    -- Get tax rate from tax codes
    SELECT tc.tax_rate INTO v_tax_rate
    FROM tax_codes tc
    WHERE tc.tax_code = p_tax_code AND tc.is_active = true;
    
    -- Default to 18% if tax code not found
    v_tax_rate := COALESCE(v_tax_rate, 18.00);
    
    -- Determine if interstate transaction
    v_is_interstate := (UPPER(COALESCE(p_vendor_state, '')) != UPPER(p_company_state));
    
    -- Calculate tax breakdown
    IF v_is_interstate THEN
        -- Interstate: IGST only
        RETURN QUERY SELECT 
            0.00::DECIMAL(5,2) as cgst_rate,
            0.00::DECIMAL(5,2) as sgst_rate,
            v_tax_rate as igst_rate,
            0.00::DECIMAL(15,2) as cgst_amount,
            0.00::DECIMAL(15,2) as sgst_amount,
            ROUND(p_line_amount * v_tax_rate / 100, 2) as igst_amount,
            ROUND(p_line_amount * v_tax_rate / 100, 2) as total_tax_amount;
    ELSE
        -- Intrastate: CGST + SGST (split equally)
        RETURN QUERY SELECT 
            (v_tax_rate / 2) as cgst_rate,
            (v_tax_rate / 2) as sgst_rate,
            0.00::DECIMAL(5,2) as igst_rate,
            ROUND(p_line_amount * (v_tax_rate / 2) / 100, 2) as cgst_amount,
            ROUND(p_line_amount * (v_tax_rate / 2) / 100, 2) as sgst_amount,
            0.00::DECIMAL(15,2) as igst_amount,
            ROUND(p_line_amount * v_tax_rate / 100, 2) as total_tax_amount;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create function to auto-calculate taxes on PO items
CREATE OR REPLACE FUNCTION calculate_po_item_taxes()
RETURNS TRIGGER AS $$
DECLARE
    v_tax_breakdown RECORD;
    v_vendor_state VARCHAR(50);
BEGIN
    -- Get vendor state from vendors table
    SELECT v.state INTO v_vendor_state
    FROM vendors v
    JOIN purchase_orders po ON po.vendor_code = v.vendor_code
    WHERE po.po_number = NEW.purchase_order_id;
    
    -- Calculate line total first
    NEW.line_total := NEW.quantity * NEW.unit_price;
    
    -- Apply discount if any
    IF NEW.discount_percent > 0 THEN
        NEW.discount_amount := NEW.line_total * NEW.discount_percent / 100;
        NEW.line_total := NEW.line_total - NEW.discount_amount;
    END IF;
    
    -- Calculate tax breakdown
    SELECT * INTO v_tax_breakdown
    FROM calculate_gst_breakdown(
        COALESCE(NEW.tax_code, 'GST18'),
        NEW.line_total,
        v_vendor_state,
        'MAHARASHTRA'
    );
    
    -- Update tax fields
    NEW.cgst_rate := v_tax_breakdown.cgst_rate;
    NEW.sgst_rate := v_tax_breakdown.sgst_rate;
    NEW.igst_rate := v_tax_breakdown.igst_rate;
    NEW.cgst_amount := v_tax_breakdown.cgst_amount;
    NEW.sgst_amount := v_tax_breakdown.sgst_amount;
    NEW.igst_amount := v_tax_breakdown.igst_amount;
    NEW.total_tax_amount := v_tax_breakdown.total_tax_amount;
    NEW.tax_amount := v_tax_breakdown.total_tax_amount;
    
    -- Calculate net amount
    NEW.net_amount := NEW.line_total + NEW.total_tax_amount;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tax calculation
DROP TRIGGER IF EXISTS trg_calculate_taxes ON purchase_order_items;
CREATE TRIGGER trg_calculate_taxes
    BEFORE INSERT OR UPDATE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION calculate_po_item_taxes();

-- Create function to update PO header tax totals
CREATE OR REPLACE FUNCTION update_po_tax_totals()
RETURNS TRIGGER AS $$
DECLARE
    v_po_number VARCHAR(20);
    v_totals RECORD;
BEGIN
    v_po_number := COALESCE(NEW.purchase_order_id, OLD.purchase_order_id);
    
    -- Calculate totals from all items
    SELECT 
        COALESCE(SUM(line_total), 0) as total_amount,
        COALESCE(SUM(cgst_amount), 0) as cgst_total,
        COALESCE(SUM(sgst_amount), 0) as sgst_total,
        COALESCE(SUM(igst_amount), 0) as igst_total,
        COALESCE(SUM(total_tax_amount), 0) as tax_amount,
        COALESCE(SUM(discount_amount), 0) as discount_amount,
        COALESCE(SUM(net_amount), 0) as net_amount
    INTO v_totals
    FROM purchase_order_items 
    WHERE purchase_order_id = v_po_number;
    
    -- Update PO header
    UPDATE purchase_orders 
    SET 
        total_amount = v_totals.total_amount,
        tax_amount = v_totals.tax_amount,
        discount_amount = v_totals.discount_amount,
        net_amount = v_totals.net_amount
    WHERE po_number = v_po_number;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create trigger for PO tax total updates
DROP TRIGGER IF EXISTS trg_update_po_tax_totals ON purchase_order_items;
CREATE TRIGGER trg_update_po_tax_totals
    AFTER INSERT OR UPDATE OR DELETE ON purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_po_tax_totals();

-- Create view for tax summary
CREATE OR REPLACE VIEW v_po_tax_summary AS
SELECT 
    po.po_number,
    po.vendor_code,
    po.total_amount,
    po.tax_amount,
    po.net_amount,
    COALESCE(SUM(poi.cgst_amount), 0) as total_cgst,
    COALESCE(SUM(poi.sgst_amount), 0) as total_sgst,
    COALESCE(SUM(poi.igst_amount), 0) as total_igst,
    COUNT(poi.id) as item_count
FROM purchase_orders po
LEFT JOIN purchase_order_items poi ON po.po_number = poi.purchase_order_id
GROUP BY po.po_number, po.vendor_code, po.total_amount, po.tax_amount, po.net_amount;

-- Add indexes for tax calculations
CREATE INDEX IF NOT EXISTS idx_tax_codes_lookup ON tax_codes(tax_code, is_active);
CREATE INDEX IF NOT EXISTS idx_poi_tax_summary ON purchase_order_items(purchase_order_id, total_tax_amount);

SELECT 'STEP 4 COMPLETE - TAX CALCULATION ENGINE' as status;
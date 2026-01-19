-- Update existing vendors table (skip rename since it already exists)

-- 1. Add vendor_type column
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS vendor_type VARCHAR(20) DEFAULT 'subcontractor';

-- 2. Add material vendor fields (nullable)
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS credit_limit DECIMAL(15,2);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS delivery_terms VARCHAR(50);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS material_category VARCHAR(50);

-- 3. Rename subcontractor_code to vendor_code (if not already renamed)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendors' AND column_name = 'subcontractor_code') THEN
        ALTER TABLE vendors RENAME COLUMN subcontractor_code TO vendor_code;
    END IF;
END $$;

-- 4. Add check constraint
ALTER TABLE vendors DROP CONSTRAINT IF EXISTS chk_vendor_type;
ALTER TABLE vendors ADD CONSTRAINT chk_vendor_type 
CHECK (vendor_type IN ('material', 'equipment', 'service', 'subcontractor', 'consultant'));

-- 5. Update existing records
UPDATE vendors SET vendor_type = 'subcontractor' WHERE vendor_type IS NULL OR vendor_type = 'subcontractor';

-- 6. Add sample material vendors
INSERT INTO vendors (vendor_code, company_name, vendor_type, contact_person, email, mobile, payment_terms, credit_limit, material_category, status) VALUES
('VEN-001', 'Supreme Cement Suppliers', 'material', 'Rakesh Mehta', 'rakesh@supremecement.com', '+91-9876502001', 'Net 45', 5000000.00, 'cement', 'active'),
('VEN-002', 'Steel World Trading', 'material', 'Sanjay Gupta', 'sanjay@steelworld.com', '+91-9876502002', 'Net 60', 8000000.00, 'steel', 'active'),
('VEN-003', 'BuildMart Equipment Rental', 'equipment', 'Arjun Reddy', 'arjun@buildmart.com', '+91-9876502003', 'Net 15', 2000000.00, 'equipment_rental', 'active')
ON CONFLICT (vendor_code) DO NOTHING;

-- 7. Update indexes
CREATE INDEX IF NOT EXISTS idx_vendors_type ON vendors(vendor_type);
CREATE INDEX IF NOT EXISTS idx_vendors_trade ON vendors(trade) WHERE vendor_type = 'subcontractor';

-- 8. Verify
SELECT vendor_type, COUNT(*) as count
FROM vendors
GROUP BY vendor_type;

SELECT vendor_code, company_name, vendor_type, trade, credit_limit FROM vendors;

COMMENT ON TABLE vendors IS 'Unified Vendors Master (SAP Standard) - All external parties';

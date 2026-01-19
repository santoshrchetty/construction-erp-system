-- Refactor to Single Vendors Table (SAP Standard)

-- 1. Rename subcontractors to vendors
ALTER TABLE subcontractors RENAME TO vendors;

-- 2. Add vendor_type column
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS vendor_type VARCHAR(20) DEFAULT 'subcontractor';

-- 3. Add material vendor fields (nullable)
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS credit_limit DECIMAL(15,2);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS delivery_terms VARCHAR(50);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS material_category VARCHAR(50);

-- 4. Rename subcontractor_code to vendor_code for consistency
ALTER TABLE vendors RENAME COLUMN subcontractor_code TO vendor_code;

-- 5. Add check constraint for vendor_type
ALTER TABLE vendors ADD CONSTRAINT chk_vendor_type 
CHECK (vendor_type IN ('material', 'equipment', 'service', 'subcontractor', 'consultant'));

-- 6. Update existing records to be subcontractors
UPDATE vendors SET vendor_type = 'subcontractor' WHERE vendor_type IS NULL;

-- 7. Add sample material vendors
INSERT INTO vendors (vendor_code, company_name, vendor_type, contact_person, email, mobile, payment_terms, credit_limit, material_category, status) VALUES
('VEN-001', 'Supreme Cement Suppliers', 'material', 'Rakesh Mehta', 'rakesh@supremecement.com', '+91-9876502001', 'Net 45', 5000000.00, 'cement', 'active'),
('VEN-002', 'Steel World Trading', 'material', 'Sanjay Gupta', 'sanjay@steelworld.com', '+91-9876502002', 'Net 60', 8000000.00, 'steel', 'active'),
('VEN-003', 'BuildMart Equipment Rental', 'equipment', 'Arjun Reddy', 'arjun@buildmart.com', '+91-9876502003', 'Net 15', 2000000.00, 'equipment_rental', 'active')
ON CONFLICT (vendor_code) DO NOTHING;

-- 8. Update indexes
DROP INDEX IF EXISTS idx_subcontractors_code;
DROP INDEX IF EXISTS idx_subcontractors_trade;
CREATE INDEX IF NOT EXISTS idx_vendors_code ON vendors(vendor_code);
CREATE INDEX IF NOT EXISTS idx_vendors_type ON vendors(vendor_type);
CREATE INDEX IF NOT EXISTS idx_vendors_trade ON vendors(trade) WHERE vendor_type = 'subcontractor';

-- 9. Verify
SELECT 
    vendor_type,
    COUNT(*) as count,
    STRING_AGG(vendor_code, ', ') as sample_codes
FROM vendors
GROUP BY vendor_type;

SELECT vendor_code, company_name, vendor_type, trade, credit_limit FROM vendors LIMIT 5;

COMMENT ON TABLE vendors IS 'Unified Vendors Master (SAP Standard) - All external parties: material suppliers, equipment vendors, service providers, subcontractors';
COMMENT ON COLUMN vendors.vendor_type IS 'material, equipment, service, subcontractor, consultant';
COMMENT ON COLUMN vendors.trade IS 'For subcontractors: civil, mep, finishing, etc. NULL for other vendor types';
COMMENT ON COLUMN vendors.credit_limit IS 'For material/equipment vendors. NULL for subcontractors';

-- Update existing vendors table structure

-- 1. Add company_code for multi-company support
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

-- 2. Add vendor_type column
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS vendor_type VARCHAR(20) DEFAULT 'material';

-- 2. Add subcontractor-specific fields
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS trade VARCHAR(50);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS specialization TEXT;
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS rating DECIMAL(3,2);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS mobile VARCHAR(50);

-- 3. Add material vendor fields
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS credit_limit DECIMAL(15,2);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS delivery_terms VARCHAR(50);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS payment_terms VARCHAR(50);

-- 4. Add check constraint
ALTER TABLE vendors DROP CONSTRAINT IF EXISTS chk_vendor_type;
ALTER TABLE vendors ADD CONSTRAINT chk_vendor_type 
CHECK (vendor_type IN ('material', 'equipment', 'service', 'subcontractor', 'consultant'));

-- 5. Insert subcontractor vendors (matching our earlier subcontractors)
INSERT INTO vendors (vendor_code, vendor_name, vendor_type, trade, specialization, contact_person, email, mobile, phone, payment_terms, rating, company_code, is_active) VALUES
('SUB-001', 'ABC Civil Contractors', 'subcontractor', 'civil', 'Earthwork, Foundation, Structural', 'Ramesh Gupta', 'ramesh@abccivil.com', '+91-9876501234', '+91-11-23456789', 'Net 30', 4.5, 'C001', true),
('SUB-002', 'XYZ Survey Services', 'subcontractor', 'survey', 'Land Survey, Topographic Survey', 'Suresh Kumar', 'suresh@xyzsurvey.com', '+91-9876501235', '+91-11-23456790', 'Net 15', 4.8, 'C001', true),
('SUB-003', 'Prime MEP Solutions', 'subcontractor', 'mep', 'Mechanical, Electrical, Plumbing', 'Anil Sharma', 'anil@primemep.com', '+91-9876501236', '+91-11-23456791', 'Net 45', 4.2, 'C001', true),
('SUB-004', 'Elite Finishing Works', 'subcontractor', 'finishing', 'Plastering, Painting, Flooring', 'Vijay Patel', 'vijay@elitefin.com', '+91-9876501237', '+91-11-23456792', 'Net 30', 4.0, 'C001', true),
('SUB-005', 'SafetyFirst Consultants', 'subcontractor', 'safety', 'Safety Audits, Training', 'Rajiv Singh', 'rajiv@safetyfirst.com', '+91-9876501238', '+91-11-23456793', 'Net 15', 4.7, 'C001', true),
('SUB-006', 'GreenScape Landscaping', 'subcontractor', 'landscaping', 'Site Clearing, Landscaping', 'Priya Reddy', 'priya@greenscape.com', '+91-9876501239', '+91-11-23456794', 'Net 30', 4.3, 'C001', true),
('SUB-007', 'TechTest Labs', 'subcontractor', 'testing', 'Material Testing, Soil Testing', 'Dr. Mohan Das', 'mohan@techtest.com', '+91-9876501240', '+91-11-23456795', 'Net 7', 4.9, 'C001', true),
('SUB-008', 'RoadMasters Paving', 'subcontractor', 'paving', 'Asphalt Paving, Road Construction', 'Karthik Iyer', 'karthik@roadmasters.com', '+91-9876501241', '+91-11-23456796', 'Net 45', 4.4, 'C001', true)
ON CONFLICT (vendor_code) DO NOTHING;

-- 6. Insert material/equipment vendors
INSERT INTO vendors (vendor_code, vendor_name, vendor_type, contact_person, email, mobile, phone, payment_terms, credit_limit, company_code, is_active) VALUES
('VEN-001', 'Supreme Cement Suppliers', 'material', 'Rakesh Mehta', 'rakesh@supremecement.com', '+91-9876502001', '+91-11-24567890', 'Net 45', 5000000.00, 'C001', true),
('VEN-002', 'Steel World Trading', 'material', 'Sanjay Gupta', 'sanjay@steelworld.com', '+91-9876502002', '+91-11-24567891', 'Net 60', 8000000.00, 'C001', true),
('VEN-003', 'BuildMart Equipment Rental', 'equipment', 'Arjun Reddy', 'arjun@buildmart.com', '+91-9876502003', '+91-11-24567892', 'Net 15', 2000000.00, 'C001', true)
ON CONFLICT (vendor_code) DO NOTHING;

-- 7. Create indexes
CREATE INDEX IF NOT EXISTS idx_vendors_type ON vendors(vendor_type);
CREATE INDEX IF NOT EXISTS idx_vendors_company ON vendors(company_code);
CREATE INDEX IF NOT EXISTS idx_vendors_trade ON vendors(trade) WHERE vendor_type = 'subcontractor';

-- 8. Verify
SELECT vendor_type, COUNT(*) as count FROM vendors GROUP BY vendor_type;
SELECT vendor_code, vendor_name, vendor_type, trade, credit_limit, rating FROM vendors ORDER BY vendor_type, vendor_code;

COMMENT ON TABLE vendors IS 'Unified Vendors Master (SAP Standard) - Material suppliers, equipment vendors, service providers, and subcontractors';
COMMENT ON COLUMN vendors.vendor_type IS 'material, equipment, service, subcontractor, consultant';

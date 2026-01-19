-- Subcontractors Master Table
CREATE TABLE IF NOT EXISTS subcontractors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcontractor_code VARCHAR(50) UNIQUE NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    
    -- Trade/Specialization
    trade VARCHAR(50) NOT NULL,
    specialization TEXT,
    
    -- Contact Information
    contact_person VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    mobile VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    
    -- Business Details
    registration_number VARCHAR(100),
    tax_id VARCHAR(100),
    license_number VARCHAR(100),
    license_expiry DATE,
    
    -- Financial
    payment_terms VARCHAR(50),
    credit_limit DECIMAL(15,2),
    
    -- Performance
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    total_contracts INTEGER DEFAULT 0,
    completed_contracts INTEGER DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blacklisted', 'suspended')),
    is_active BOOLEAN DEFAULT true,
    
    -- System
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_subcontractors_code ON subcontractors(subcontractor_code);
CREATE INDEX idx_subcontractors_trade ON subcontractors(trade);
CREATE INDEX idx_subcontractors_status ON subcontractors(status, is_active);

-- Sample Subcontractors
INSERT INTO subcontractors (
    subcontractor_code, company_name, trade, specialization,
    contact_person, email, phone, mobile,
    payment_terms, rating, status
) VALUES
('SUB-001', 'ABC Civil Contractors Pvt Ltd', 'civil', 'Earthwork, Foundation, Structural Work',
 'Ramesh Gupta', 'ramesh@abccivil.com', '+91-11-23456789', '+91-9876501234',
 'Net 30', 4.5, 'active'),
 
('SUB-002', 'XYZ Survey Services', 'survey', 'Land Survey, Topographic Survey, GPS Survey',
 'Suresh Kumar', 'suresh@xyzsurvey.com', '+91-11-23456790', '+91-9876501235',
 'Net 15', 4.8, 'active'),
 
('SUB-003', 'Prime MEP Solutions', 'mep', 'Mechanical, Electrical, Plumbing',
 'Anil Sharma', 'anil@primemep.com', '+91-11-23456791', '+91-9876501236',
 'Net 45', 4.2, 'active'),
 
('SUB-004', 'Elite Finishing Works', 'finishing', 'Plastering, Painting, Flooring, Tiling',
 'Vijay Patel', 'vijay@elitefin.com', '+91-11-23456792', '+91-9876501237',
 'Net 30', 4.0, 'active'),
 
('SUB-005', 'SafetyFirst Consultants', 'safety', 'Safety Audits, Training, Compliance',
 'Rajiv Singh', 'rajiv@safetyfirst.com', '+91-11-23456793', '+91-9876501238',
 'Net 15', 4.7, 'active'),
 
('SUB-006', 'GreenScape Landscaping', 'landscaping', 'Site Clearing, Landscaping, Horticulture',
 'Priya Reddy', 'priya@greenscape.com', '+91-11-23456794', '+91-9876501239',
 'Net 30', 4.3, 'active'),
 
('SUB-007', 'TechTest Labs', 'testing', 'Material Testing, Soil Testing, NDT',
 'Dr. Mohan Das', 'mohan@techtest.com', '+91-11-23456795', '+91-9876501240',
 'Net 7', 4.9, 'active'),
 
('SUB-008', 'RoadMasters Paving', 'paving', 'Asphalt Paving, Road Construction',
 'Karthik Iyer', 'karthik@roadmasters.com', '+91-11-23456796', '+91-9876501241',
 'Net 45', 4.4, 'active')
 
ON CONFLICT (subcontractor_code) DO NOTHING;

-- Verify
SELECT COUNT(*) as subcontractor_count FROM subcontractors;
SELECT subcontractor_code, company_name, trade, rating FROM subcontractors;

COMMENT ON TABLE subcontractors IS 'Subcontractors Master - Vendor management for construction trades';
COMMENT ON COLUMN subcontractors.trade IS 'civil, mep, finishing, survey, safety, landscaping, testing, paving, etc.';

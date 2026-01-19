-- Drop and recreate subcontractors table
DROP TABLE IF EXISTS subcontractors CASCADE;

CREATE TABLE subcontractors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcontractor_code VARCHAR(50) UNIQUE NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    trade VARCHAR(50) NOT NULL,
    specialization TEXT,
    contact_person VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    mobile VARCHAR(50),
    payment_terms VARCHAR(50),
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    status VARCHAR(20) DEFAULT 'active',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_subcontractors_code ON subcontractors(subcontractor_code);
CREATE INDEX idx_subcontractors_trade ON subcontractors(trade);

-- Insert sample subcontractors
INSERT INTO subcontractors (subcontractor_code, company_name, trade, specialization, contact_person, email, mobile, payment_terms, rating) VALUES
('SUB-001', 'ABC Civil Contractors', 'civil', 'Earthwork, Foundation, Structural', 'Ramesh Gupta', 'ramesh@abccivil.com', '+91-9876501234', 'Net 30', 4.5),
('SUB-002', 'XYZ Survey Services', 'survey', 'Land Survey, Topographic Survey', 'Suresh Kumar', 'suresh@xyzsurvey.com', '+91-9876501235', 'Net 15', 4.8),
('SUB-003', 'Prime MEP Solutions', 'mep', 'Mechanical, Electrical, Plumbing', 'Anil Sharma', 'anil@primemep.com', '+91-9876501236', 'Net 45', 4.2),
('SUB-004', 'Elite Finishing Works', 'finishing', 'Plastering, Painting, Flooring', 'Vijay Patel', 'vijay@elitefin.com', '+91-9876501237', 'Net 30', 4.0),
('SUB-005', 'SafetyFirst Consultants', 'safety', 'Safety Audits, Training', 'Rajiv Singh', 'rajiv@safetyfirst.com', '+91-9876501238', 'Net 15', 4.7),
('SUB-006', 'GreenScape Landscaping', 'landscaping', 'Site Clearing, Landscaping', 'Priya Reddy', 'priya@greenscape.com', '+91-9876501239', 'Net 30', 4.3),
('SUB-007', 'TechTest Labs', 'testing', 'Material Testing, Soil Testing', 'Dr. Mohan Das', 'mohan@techtest.com', '+91-9876501240', 'Net 7', 4.9),
('SUB-008', 'RoadMasters Paving', 'paving', 'Asphalt Paving, Road Construction', 'Karthik Iyer', 'karthik@roadmasters.com', '+91-9876501241', 'Net 45', 4.4);

-- Verify
SELECT COUNT(*) as count FROM subcontractors;
SELECT subcontractor_code, company_name, trade, rating FROM subcontractors;

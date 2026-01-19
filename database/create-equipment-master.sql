-- Create Equipment Master Table
CREATE TABLE IF NOT EXISTS equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    equipment_code VARCHAR(50) UNIQUE NOT NULL,
    equipment_name VARCHAR(200) NOT NULL,
    equipment_type VARCHAR(50),
    category VARCHAR(50),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    hourly_rate DECIMAL(10,2) DEFAULT 0,
    daily_rate DECIMAL(10,2) DEFAULT 0,
    ownership_type VARCHAR(20) CHECK (ownership_type IN ('owned', 'rented', 'leased')),
    status VARCHAR(20) DEFAULT 'available',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert Sample Equipment
INSERT INTO equipment (equipment_code, equipment_name, equipment_type, category, hourly_rate, ownership_type) VALUES
('EQ-EXC-001', 'Hydraulic Excavator CAT 320', 'excavator', 'earthmoving', 180.00, 'owned'),
('EQ-BULL-001', 'Bulldozer D6', 'bulldozer', 'earthmoving', 150.00, 'owned'),
('EQ-GRAD-001', 'Motor Grader CAT 140', 'grader', 'earthmoving', 140.00, 'rented'),
('EQ-ROLL-001', 'Vibratory Roller 10T', 'roller', 'compaction', 85.00, 'rented'),
('EQ-DUMP-001', 'Dump Truck 20T', 'truck', 'hauling', 95.00, 'owned'),
('EQ-CRANE-001', 'Mobile Crane 50T', 'crane', 'lifting', 200.00, 'rented'),
('EQ-CONC-001', 'Concrete Mixer', 'mixer', 'concrete', 45.00, 'owned'),
('EQ-PUMP-001', 'Concrete Pump', 'pump', 'concrete', 120.00, 'rented'),
('EQ-PAVER-001', 'Asphalt Paver', 'paver', 'paving', 160.00, 'rented'),
('EQ-SURVEY-001', 'Total Station', 'survey', 'surveying', 15.00, 'owned')
ON CONFLICT (equipment_code) DO NOTHING;

-- Verify
SELECT COUNT(*) as equipment_count FROM equipment;
SELECT equipment_code, equipment_name, hourly_rate FROM equipment LIMIT 5;

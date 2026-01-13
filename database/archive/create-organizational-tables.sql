-- Create organizational tables
CREATE TABLE IF NOT EXISTS persons_responsible (
    id SERIAL PRIMARY KEY,
    person_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cost_centers (
    id SERIAL PRIMARY KEY,
    cost_center_id VARCHAR(20) UNIQUE NOT NULL,
    cost_center_name VARCHAR(255) NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS profit_centers (
    id SERIAL PRIMARY KEY,
    profit_center_id VARCHAR(20) UNIQUE NOT NULL,
    profit_center_name VARCHAR(255) NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS plants (
    id SERIAL PRIMARY KEY,
    plant_id VARCHAR(20) UNIQUE NOT NULL,
    plant_name VARCHAR(255) NOT NULL,
    address TEXT,
    company_code VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data
INSERT INTO persons_responsible (person_id, first_name, last_name, email, company_code) VALUES
('PR001', 'John', 'Smith', 'john.smith@company.com', 'C001'),
('PR002', 'Sarah', 'Johnson', 'sarah.johnson@company.com', 'C001'),
('PR003', 'Mike', 'Davis', 'mike.davis@company.com', 'C001')
ON CONFLICT DO NOTHING;

INSERT INTO cost_centers (cost_center_id, cost_center_name, company_code) VALUES
('CC001', 'Construction Operations', 'C001'),
('CC002', 'Project Management', 'C001'),
('CC003', 'Engineering Services', 'C001')
ON CONFLICT DO NOTHING;

INSERT INTO profit_centers (profit_center_id, profit_center_name, company_code) VALUES
('PC001', 'Residential Construction', 'C001'),
('PC002', 'Commercial Construction', 'C001')
ON CONFLICT DO NOTHING;

INSERT INTO plants (plant_id, plant_name, address, company_code) VALUES
('PL001', 'Main Construction Site', '123 Construction Ave', 'C001'),
('PL002', 'Equipment Yard', '456 Equipment Blvd', 'C001')
ON CONFLICT DO NOTHING;
-- Add storage location context to approval policies
ALTER TABLE approval_policies 
ADD COLUMN storage_location_code VARCHAR(30),
ADD COLUMN storage_type VARCHAR(20), -- HAZMAT, SECURE, CLIMATE_CONTROLLED, STANDARD
ADD COLUMN access_level VARCHAR(20); -- PUBLIC, RESTRICTED, CONFIDENTIAL, TOP_SECRET

-- Create storage location approval policies
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, plant_code, storage_location_code, storage_type, access_level,
    is_active, created_at
) VALUES
-- Hazardous materials storage approval
('550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440001',
 'Hazmat Storage Approval Policy', 'MR', 'NB', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}',
 'C001', 'USA', 'PLANT_NYC', 'HAZMAT-001', 'HAZMAT', 'RESTRICTED', true, NOW()),

-- High-value secure storage
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440001',
 'Secure Storage High Value Policy', 'MR', 'NB', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 50000, "max": 999999999, "currency": "USD"}',
 'C001', 'USA', 'PLANT_NYC', 'SECURE-WAREHOUSE', 'SECURE', 'RESTRICTED', true, NOW()),

-- Climate controlled storage
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440001',
 'Climate Controlled Storage Policy', 'MR', 'SP', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 100000, "currency": "USD"}',
 'C001', 'USA', 'PLANT_CHI', 'CLIMATE-CTRL-A', 'CLIMATE_CONTROLLED', 'RESTRICTED', true, NOW());

-- Create storage location master data
CREATE TABLE IF NOT EXISTS storage_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    location_code VARCHAR(30) NOT NULL,
    location_name VARCHAR(100) NOT NULL,
    plant_code VARCHAR(20),
    storage_type VARCHAR(20), -- HAZMAT, SECURE, CLIMATE_CONTROLLED, STANDARD
    access_level VARCHAR(20), -- PUBLIC, RESTRICTED, CONFIDENTIAL
    capacity_limit DECIMAL(15,2),
    temperature_range VARCHAR(50), -- "-5°C to +25°C"
    special_requirements TEXT,
    safety_certifications JSONB,
    responsible_person_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample storage locations
INSERT INTO storage_locations (
    customer_id, location_code, location_name, plant_code, storage_type, access_level,
    capacity_limit, temperature_range, special_requirements, safety_certifications
) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'HAZMAT-001', 'Hazardous Materials Vault A', 'PLANT_NYC', 'HAZMAT', 'RESTRICTED',
 1000.00, '15°C to 25°C', 'Fire suppression system, ventilation, spill containment',
 '{"fire_marshal": "FM-2024-001", "epa_permit": "EPA-HAZ-2024", "osha_compliance": "OSHA-2024-NYC"}'),

('550e8400-e29b-41d4-a716-446655440001', 'SECURE-WAREHOUSE', 'High Security Equipment Storage', 'PLANT_NYC', 'SECURE', 'RESTRICTED',
 50000.00, 'Ambient', '24/7 surveillance, access card required, inventory tracking',
 '{"security_clearance": "SEC-LEVEL-3", "insurance_coverage": "INS-2024-EQUIP"}'),

('550e8400-e29b-41d4-a716-446655440001', 'CLIMATE-CTRL-A', 'Climate Controlled Storage A', 'PLANT_CHI', 'CLIMATE_CONTROLLED', 'RESTRICTED',
 25000.00, '2°C to 8°C', 'Temperature monitoring, humidity control, backup power',
 '{"temperature_cert": "TEMP-2024-001", "pharma_grade": "FDA-STORAGE-2024"}');

-- Verify storage location policies
SELECT 
    p.policy_name,
    p.approval_object_type,
    p.storage_location_code,
    p.storage_type,
    p.access_level,
    s.location_name,
    s.special_requirements
FROM approval_policies p
LEFT JOIN storage_locations s ON p.storage_location_code = s.location_code
WHERE p.storage_location_code IS NOT NULL;
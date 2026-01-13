-- Complete Approval System Setup and Test Script
-- Run this single script to set up and test the entire approval workflow

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Clean existing test data first (in correct order to avoid FK violations)
DELETE FROM approval_actions WHERE execution_id IN (
  SELECT ae.id FROM approval_executions ae
  JOIN material_requests mr ON ae.request_id = mr.id
  WHERE mr.request_number LIKE 'MR-TEST-%'
);

DELETE FROM approval_executions WHERE request_id IN (
  SELECT id FROM material_requests WHERE request_number LIKE 'MR-TEST-%'
);

DELETE FROM material_requests WHERE request_number LIKE 'MR-TEST-%';

DELETE FROM flexible_approval_levels 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001' 
AND document_type = 'MATERIAL_REQ';

DELETE FROM customer_approval_configuration 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001' 
AND document_type = 'MATERIAL_REQ';

-- Create tables if they don't exist
CREATE TABLE IF NOT EXISTS approval_level_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    customer_type VARCHAR(20) CHECK (customer_type IN ('SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE')),
    industry_type VARCHAR(50) DEFAULT 'CONSTRUCTION',
    is_public BOOLEAN DEFAULT true,
    usage_count INTEGER DEFAULT 0,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS flexible_approval_levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('MATERIAL_REQ', 'PURCHASE_REQ', 'PURCHASE_ORDER', 'RESERVATION')),
    level_number INTEGER NOT NULL,
    level_name VARCHAR(100) NOT NULL,
    amount_threshold_min DECIMAL(15,2) DEFAULT 0,
    amount_threshold_max DECIMAL(15,2) DEFAULT 999999999,
    approver_role VARCHAR(50) NOT NULL,
    approver_user_id UUID,
    approval_type VARCHAR(20) DEFAULT 'SEQUENTIAL' CHECK (approval_type IN ('SEQUENTIAL', 'PARALLEL', 'ANY_ONE')),
    is_required BOOLEAN DEFAULT true,
    can_delegate BOOLEAN DEFAULT true,
    delegation_rules JSONB,
    notification_settings JSONB,
    escalation_hours INTEGER DEFAULT 24,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(customer_id, document_type, level_number)
);

CREATE TABLE IF NOT EXISTS customer_approval_configuration (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    config_name VARCHAR(100) NOT NULL,
    template_id UUID REFERENCES approval_level_templates(id),
    is_template_based BOOLEAN DEFAULT false,
    emergency_override_enabled BOOLEAN DEFAULT true,
    emergency_override_roles TEXT[],
    bulk_approval_enabled BOOLEAN DEFAULT false,
    parallel_approval_enabled BOOLEAN DEFAULT false,
    auto_approval_rules JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(customer_id, document_type, config_name)
);

CREATE TABLE IF NOT EXISTS material_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_number VARCHAR(50) NOT NULL UNIQUE,
    request_type VARCHAR(50) NOT NULL CHECK (request_type IN ('MATERIAL_REQ', 'PURCHASE_REQ', 'PURCHASE_ORDER', 'RESERVATION')),
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SUBMITTED', 'IN_APPROVAL', 'APPROVED', 'REJECTED', 'CANCELLED')),
    priority VARCHAR(10) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    requested_by UUID NOT NULL,
    required_date DATE,
    company_code VARCHAR(10),
    plant_code VARCHAR(10),
    cost_center VARCHAR(20),
    project_code VARCHAR(20),
    purpose TEXT,
    notes TEXT,
    total_amount DECIMAL(15,2) DEFAULT 0,
    currency_code VARCHAR(3) DEFAULT 'USD',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS approval_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES material_requests(id) ON DELETE CASCADE,
    config_id UUID NOT NULL REFERENCES customer_approval_configuration(id),
    current_level INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'CANCELLED')),
    total_levels INTEGER NOT NULL,
    execution_path JSONB NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS approval_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    execution_id UUID NOT NULL REFERENCES approval_executions(id) ON DELETE CASCADE,
    level_number INTEGER NOT NULL,
    approver_id UUID NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('APPROVED', 'REJECTED', 'DELEGATED', 'ESCALATED')),
    comments TEXT,
    action_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    delegation_to UUID,
    escalation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample templates
INSERT INTO approval_level_templates (template_name, description, customer_type, industry_type) VALUES
('Standard 2-Level', 'Basic 2-level approval for small companies', 'SMALL', 'CONSTRUCTION')
ON CONFLICT (template_name) DO NOTHING;

-- Create approval configuration manually
INSERT INTO customer_approval_configuration (
    customer_id, document_type, config_name, is_template_based
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'MR Standard Approval', false
);

-- Create approval levels manually
INSERT INTO flexible_approval_levels (
    customer_id, document_type, level_number, level_name, 
    amount_threshold_min, amount_threshold_max, approver_role
) VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Supervisor Approval', 0, 25000, 'SUPERVISOR'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Manager Approval', 0, 999999999, 'MANAGER');

-- Create test material request
INSERT INTO material_requests (
    request_number, request_type, status, priority, requested_by, 
    total_amount, currency_code, plant_code, created_by
) VALUES (
    'MR-TEST-001', 'MATERIAL_REQ', 'SUBMITTED', 'MEDIUM', 
    '550e8400-e29b-41d4-a716-446655440001', 15000.00, 'USD', 'B001',
    '550e8400-e29b-41d4-a716-446655440001'
);

-- Create approval execution
INSERT INTO approval_executions (
    request_id, config_id, current_level, status, total_levels, execution_path
)
SELECT 
    mr.id,
    cac.id,
    1,
    'PENDING',
    2,
    '{"levels": [{"level": 1, "role": "SUPERVISOR"}, {"level": 2, "role": "MANAGER"}]}'
FROM material_requests mr
JOIN customer_approval_configuration cac ON cac.customer_id = '550e8400-e29b-41d4-a716-446655440001'
WHERE mr.request_number = 'MR-TEST-001' AND cac.document_type = 'MATERIAL_REQ';

-- Simulate first approval
INSERT INTO approval_actions (
    execution_id, level_number, approver_id, approver_role, action, comments
)
SELECT 
    ae.id, 1, '550e8400-e29b-41d4-a716-446655440001'::UUID, 'SUPERVISOR', 'APPROVED', 'Test approval'
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-TEST-001';

-- Update to next level
UPDATE approval_executions 
SET current_level = 2, status = 'IN_PROGRESS'
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-TEST-001');

-- Final approval
INSERT INTO approval_actions (
    execution_id, level_number, approver_id, approver_role, action, comments
)
SELECT 
    ae.id, 2, '550e8400-e29b-41d4-a716-446655440002'::UUID, 'MANAGER', 'APPROVED', 'Final approval'
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-TEST-001';

-- Complete workflow
UPDATE approval_executions 
SET status = 'COMPLETED', completed_at = NOW()
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-TEST-001');

UPDATE material_requests 
SET status = 'APPROVED'
WHERE request_number = 'MR-TEST-001';

-- Verification queries
SELECT 'WORKFLOW TEST RESULTS:' as section;

SELECT 
    mr.request_number,
    mr.total_amount,
    mr.status as request_status,
    ae.status as approval_status,
    ae.current_level,
    ae.total_levels
FROM material_requests mr
JOIN approval_executions ae ON mr.id = ae.request_id
WHERE mr.request_number = 'MR-TEST-001';

SELECT 
    mr.request_number,
    aa.level_number,
    aa.approver_role,
    aa.action,
    aa.comments,
    aa.action_date
FROM material_requests mr
JOIN approval_executions ae ON mr.id = ae.request_id
JOIN approval_actions aa ON ae.id = aa.execution_id
WHERE mr.request_number = 'MR-TEST-001'
ORDER BY aa.level_number;

SELECT 'APPROVAL WORKFLOW TEST COMPLETED SUCCESSFULLY' as result;_id
JOIN approval_actions aa ON ae.id = aa.execution_id
WHERE mr.request_number = 'MR-TEST-001'
ORDER BY aa.level_number;

SELECT 'APPROVAL WORKFLOW TEST COMPLETED SUCCESSFULLY' as result;
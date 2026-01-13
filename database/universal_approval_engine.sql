-- Enhanced Universal Approval Engine Schema
-- Supports ALL approval types: Financial, Document, Storage, Travel, HR, etc.

-- Enhanced approval_policies table with universal fields
ALTER TABLE approval_policies 
ADD COLUMN object_category VARCHAR(30), -- FINANCIAL, DOCUMENT, STORAGE, TRAVEL, HR
ADD COLUMN object_subtype VARCHAR(30), -- For granular control
ADD COLUMN approval_context JSONB, -- Flexible context data
ADD COLUMN business_rules JSONB, -- Custom business logic
ADD COLUMN escalation_rules JSONB; -- Escalation configuration

-- Universal object types and document types
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, object_subtype, approval_strategy, approval_pattern,
    amount_thresholds, company_code, country_code, plant_code, project_code,
    approval_context, business_rules, is_active, created_at
) VALUES
-- Financial Approvals
('550e8400-e29b-41d4-a716-446655440400', '550e8400-e29b-41d4-a716-446655440001',
 'Purchase Order Standard Policy', 'PO', 'NB', 'FINANCIAL', 'PROCUREMENT', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}', 'C001', 'USA', 'PLANT_NYC', NULL,
 '{"requires_budget_check": true, "vendor_approval_required": false}',
 '{"auto_approve_below": 1000, "require_three_quotes_above": 10000}', true, NOW()),

-- Document Approvals  
('550e8400-e29b-41d4-a716-446655440401', '550e8400-e29b-41d4-a716-446655440001',
 'Drawing Revision Major Policy', 'DRAWING', 'REVISION', 'DOCUMENT', 'TECHNICAL_DRAWING', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}', 'C001', 'USA', NULL, 'PROJ_ALPHA_2024',
 '{"revision_type": "MAJOR", "discipline": "STRUCTURAL", "regulatory_impact": true}',
 '{"parallel_approval": false, "client_approval_required": true, "regulatory_review": true}', true, NOW()),

-- Storage Location Approvals
('550e8400-e29b-41d4-a716-446655440402', '550e8400-e29b-41d4-a716-446655440001',
 'Hazmat Storage Assignment Policy', 'STORAGE', 'ASSIGNMENT', 'STORAGE', 'HAZMAT', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}', 'C001', 'USA', 'PLANT_NYC', NULL,
 '{"storage_type": "HAZMAT", "access_level": "RESTRICTED", "location_code": "HAZMAT-001"}',
 '{"safety_officer_required": true, "fire_marshal_approval": true, "epa_notification": true}', true, NOW()),

-- Travel Approvals
('550e8400-e29b-41d4-a716-446655440403', '550e8400-e29b-41d4-a716-446655440001',
 'Business Travel Policy', 'TRAVEL', 'BUSINESS', 'TRAVEL', 'DOMESTIC', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 10000, "currency": "USD"}', 'C001', 'USA', NULL, NULL,
 '{"travel_type": "DOMESTIC", "advance_required": false}',
 '{"auto_approve_below": 500, "require_justification_above": 2000}', true, NOW()),

-- HR Approvals
('550e8400-e29b-41d4-a716-446655440404', '550e8400-e29b-41d4-a716-446655440001',
 'Leave Request Policy', 'LEAVE', 'ANNUAL', 'HR', 'TIME_OFF', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}', 'C001', 'USA', NULL, NULL,
 '{"leave_type": "ANNUAL", "max_consecutive_days": 14}',
 '{"auto_approve_below_days": 3, "require_coverage_plan_above": 5}', true, NOW());

-- Universal approval object types master data
CREATE TABLE IF NOT EXISTS approval_object_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    object_type VARCHAR(30) NOT NULL,
    object_category VARCHAR(30) NOT NULL, -- FINANCIAL, DOCUMENT, STORAGE, TRAVEL, HR
    object_name VARCHAR(100) NOT NULL,
    description TEXT,
    default_strategy VARCHAR(30), -- ROLE_BASED, AMOUNT_BASED, HYBRID
    required_fields JSONB, -- Fields required for this object type
    validation_rules JSONB, -- Validation logic
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert universal object types
INSERT INTO approval_object_types (
    customer_id, object_type, object_category, object_name, description,
    default_strategy, required_fields, validation_rules
) VALUES
-- Financial Objects
('550e8400-e29b-41d4-a716-446655440001', 'PO', 'FINANCIAL', 'Purchase Order', 'Purchase orders for goods and services', 'AMOUNT_BASED',
 '["vendor_id", "amount", "currency", "plant_code"]', '{"min_amount": 0, "max_amount": 10000000}'),
('550e8400-e29b-41d4-a716-446655440001', 'MR', 'FINANCIAL', 'Material Request', 'Internal material requisitions', 'ROLE_BASED',
 '["material_code", "quantity", "plant_code", "cost_center"]', '{"max_quantity": 10000}'),

-- Document Objects  
('550e8400-e29b-41d4-a716-446655440001', 'DRAWING', 'DOCUMENT', 'Technical Drawing', 'Engineering drawings and revisions', 'ROLE_BASED',
 '["document_number", "revision", "discipline", "project_code"]', '{"max_revision_level": 99}'),
('550e8400-e29b-41d4-a716-446655440001', 'SPECIFICATION', 'DOCUMENT', 'Technical Specification', 'Technical specifications and standards', 'ROLE_BASED',
 '["spec_number", "version", "discipline"]', '{"version_format": "semantic"}'),

-- Storage Objects
('550e8400-e29b-41d4-a716-446655440001', 'STORAGE', 'STORAGE', 'Storage Assignment', 'Material storage location assignments', 'ROLE_BASED',
 '["material_code", "storage_location", "storage_type"]', '{"valid_storage_types": ["STANDARD", "HAZMAT", "SECURE", "CLIMATE_CONTROLLED"]}'),

-- Travel Objects
('550e8400-e29b-41d4-a716-446655440001', 'TRAVEL', 'TRAVEL', 'Travel Request', 'Business travel requests and expenses', 'AMOUNT_BASED',
 '["destination", "start_date", "end_date", "estimated_cost"]', '{"max_trip_duration": 30, "advance_booking_days": 7}'),

-- HR Objects
('550e8400-e29b-41d4-a716-446655440001', 'LEAVE', 'HR', 'Leave Request', 'Employee leave and time-off requests', 'ROLE_BASED',
 '["leave_type", "start_date", "end_date", "days_requested"]', '{"max_consecutive_days": 30, "min_notice_days": 2}');

-- Verify universal approval engine
SELECT 
    aot.object_category,
    aot.object_type,
    aot.object_name,
    COUNT(ap.id) as policy_count,
    STRING_AGG(DISTINCT ap.approval_strategy, ', ') as strategies_used
FROM approval_object_types aot
LEFT JOIN approval_policies ap ON aot.object_type = ap.approval_object_type
WHERE aot.customer_id = '550e8400-e29b-41d4-a716-446655440001'
GROUP BY aot.object_category, aot.object_type, aot.object_name
ORDER BY aot.object_category, aot.object_type;
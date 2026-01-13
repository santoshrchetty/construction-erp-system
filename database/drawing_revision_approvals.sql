-- Drawing/Document Revision Approval System
-- Add document-specific fields to approval policies
ALTER TABLE approval_policies 
ADD COLUMN document_category VARCHAR(30), -- DRAWING, SPECIFICATION, PROCEDURE, MANUAL
ADD COLUMN document_discipline VARCHAR(30), -- STRUCTURAL, MECHANICAL, ELECTRICAL, ARCHITECTURAL
ADD COLUMN revision_type VARCHAR(30), -- MINOR, MAJOR, CRITICAL, EMERGENCY
ADD COLUMN regulatory_impact BOOLEAN DEFAULT false;

-- Create document revision approval policies
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, project_code, document_category, document_discipline, revision_type,
    regulatory_impact, is_active, created_at
) VALUES
-- Structural drawing revisions
('550e8400-e29b-41d4-a716-446655440300', '550e8400-e29b-41d4-a716-446655440001',
 'Structural Drawing Major Revision Policy', 'DRAWING', 'REVISION', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}',
 'C001', 'USA', 'PROJ_ALPHA_2024', 'DRAWING', 'STRUCTURAL', 'MAJOR', true, NOW()),

-- MEP drawing revisions
('550e8400-e29b-41d4-a716-446655440301', '550e8400-e29b-41d4-a716-446655440001',
 'MEP Drawing Minor Revision Policy', 'DRAWING', 'REVISION', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}',
 'C001', 'USA', 'PROJ_ALPHA_2024', 'DRAWING', 'MECHANICAL', 'MINOR', false, NOW()),

-- Emergency drawing corrections
('550e8400-e29b-41d4-a716-446655440302', '550e8400-e29b-41d4-a716-446655440001',
 'Emergency Drawing Correction Policy', 'DRAWING', 'CORRECTION', 'HYBRID', 'PARALLEL_APPROVAL',
 '{"min": 0, "max": 999999999, "currency": "USD"}',
 'C001', 'USA', NULL, 'DRAWING', 'ANY', 'EMERGENCY', true, NOW()),

-- Specification document revisions
('550e8400-e29b-41d4-a716-446655440303', '550e8400-e29b-41d4-a716-446655440001',
 'Technical Specification Revision Policy', 'SPECIFICATION', 'REVISION', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}',
 'C001', 'USA', 'PROJ_ALPHA_2024', 'SPECIFICATION', 'TECHNICAL', 'MAJOR', true, NOW());

-- Create document revision tracking table
CREATE TABLE IF NOT EXISTS document_revisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    document_number VARCHAR(50) NOT NULL,
    document_title VARCHAR(200) NOT NULL,
    current_revision VARCHAR(10) NOT NULL,
    previous_revision VARCHAR(10),
    revision_date DATE NOT NULL,
    revision_reason TEXT NOT NULL,
    document_category VARCHAR(30), -- DRAWING, SPECIFICATION, PROCEDURE
    document_discipline VARCHAR(30), -- STRUCTURAL, MECHANICAL, ELECTRICAL
    revision_type VARCHAR(30), -- MINOR, MAJOR, CRITICAL, EMERGENCY
    project_code VARCHAR(30),
    created_by UUID NOT NULL,
    approved_by UUID,
    approval_date TIMESTAMP WITH TIME ZONE,
    approval_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    regulatory_impact BOOLEAN DEFAULT false,
    impact_assessment TEXT,
    affected_documents JSONB, -- List of related documents affected
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample document revisions
INSERT INTO document_revisions (
    customer_id, document_number, document_title, current_revision, previous_revision,
    revision_date, revision_reason, document_category, document_discipline, revision_type,
    project_code, created_by, regulatory_impact, impact_assessment, affected_documents
) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'STR-001-A', 'Foundation Plan - Building A', 'Rev-03', 'Rev-02',
 '2024-01-15', 'Updated foundation depth due to soil test results', 'DRAWING', 'STRUCTURAL', 'MAJOR',
 'PROJ_ALPHA_2024', '550e8400-e29b-41d4-a716-446655440010', true,
 'Requires structural engineer approval, impacts construction schedule by 2 weeks',
 '["STR-002-A", "STR-003-A", "SITE-PLAN-001"]'),

('550e8400-e29b-41d4-a716-446655440001', 'MEP-HVAC-001', 'HVAC Layout - Floor 1', 'Rev-02', 'Rev-01',
 '2024-01-16', 'Relocated air handling unit due to space constraints', 'DRAWING', 'MECHANICAL', 'MINOR',
 'PROJ_ALPHA_2024', '550e8400-e29b-41d4-a716-446655440020', false,
 'Minor change, no impact on other systems',
 '["MEP-HVAC-002", "ARCH-FLOOR-001"]'),

('550e8400-e29b-41d4-a716-446655440001', 'ELEC-PANEL-001', 'Main Electrical Panel Schedule', 'Rev-04', 'Rev-03',
 '2024-01-17', 'Emergency correction - wrong breaker specifications', 'DRAWING', 'ELECTRICAL', 'EMERGENCY',
 'PROJ_ALPHA_2024', '550e8400-e29b-41d4-a716-446655440030', true,
 'Critical safety issue, immediate approval required',
 '["ELEC-SINGLE-001", "ELEC-LIGHTING-001"]');

-- Create approval workflow for document revisions
CREATE TABLE IF NOT EXISTS document_approval_workflow (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_revision_id UUID NOT NULL REFERENCES document_revisions(id),
    step_number INTEGER NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    approver_user_id UUID,
    approval_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    approval_date TIMESTAMP WITH TIME ZONE,
    approval_comments TEXT,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample approval workflow for structural drawing
INSERT INTO document_approval_workflow (
    document_revision_id, step_number, approver_role, approver_user_id, is_required
) VALUES
-- Structural drawing major revision workflow
((SELECT id FROM document_revisions WHERE document_number = 'STR-001-A'), 1, 'Structural Engineer', '550e8400-e29b-41d4-a716-446655440010', true),
((SELECT id FROM document_revisions WHERE document_number = 'STR-001-A'), 2, 'Chief Engineer', '550e8400-e29b-41d4-a716-446655440008', true),
((SELECT id FROM document_revisions WHERE document_number = 'STR-001-A'), 3, 'Project Manager', '550e8400-e29b-41d4-a716-446655440002', true),
((SELECT id FROM document_revisions WHERE document_number = 'STR-001-A'), 4, 'Client Representative', '550e8400-e29b-41d4-a716-446655440001', true);

-- Verify drawing revision policies and workflows
SELECT 
    p.policy_name,
    p.document_category,
    p.document_discipline,
    p.revision_type,
    p.regulatory_impact,
    dr.document_number,
    dr.document_title,
    dr.current_revision,
    dr.approval_status
FROM approval_policies p
LEFT JOIN document_revisions dr ON p.project_code = dr.project_code
WHERE p.document_category IS NOT NULL
ORDER BY p.document_category, p.revision_type;
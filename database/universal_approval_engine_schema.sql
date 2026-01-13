-- UNIVERSAL ENTERPRISE APPROVAL ENGINE - MASTER SCHEMA
-- SAP Release Strategy + Oracle AME + Dynamics 365 Equivalent

-- 1. APPROVAL OBJECT REGISTRY (Document-Agnostic)
CREATE TABLE IF NOT EXISTS approval_object_registry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    approval_object_type VARCHAR(20) NOT NULL,           -- PO, PR, MR, CLAIM, DOC_REVIEW
    approval_object_document_type VARCHAR(10) NOT NULL,  -- NB, EM, CR, SP
    object_name VARCHAR(100) NOT NULL,
    check_for_value BOOLEAN DEFAULT false,
    default_strategy VARCHAR(20) DEFAULT 'ROLE_BASED' CHECK (default_strategy IN ('ROLE_BASED', 'AMOUNT_BASED', 'HYBRID')),
    required_functional_domains TEXT[] DEFAULT '{}',     -- FINANCE, LEGAL, SAFETY, QUALITY
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(approval_object_type, approval_object_document_type)
);

-- 2. APPROVAL POLICIES (Rules, Not Sequences)
CREATE TABLE IF NOT EXISTS approval_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    policy_name VARCHAR(100) NOT NULL,
    approval_object_type VARCHAR(20) NOT NULL,
    approval_object_document_type VARCHAR(10) NOT NULL,
    company_code VARCHAR(10),
    country_code VARCHAR(3),
    department_code VARCHAR(20),
    plant_code VARCHAR(10),
    project_code VARCHAR(20),
    approval_strategy VARCHAR(20) NOT NULL CHECK (approval_strategy IN ('ROLE_BASED', 'AMOUNT_BASED', 'HYBRID')),
    approval_pattern VARCHAR(30) NOT NULL CHECK (approval_pattern IN ('HIERARCHY_ONLY', 'FUNCTIONAL_THEN_HIERARCHY', 'HIERARCHY_THEN_FUNCTIONAL', 'PARALLEL_FUNCTIONAL', 'ESCALATED_GLOBAL')),
    functional_domains JSONB DEFAULT '{}',               -- {FINANCE: {mandatory: true, scope: COUNTRY}, LEGAL: {mandatory: false, scope: GLOBAL}}
    amount_thresholds JSONB DEFAULT '{}',                -- {currency: USD, thresholds: [{min: 0, max: 50000, authority: MANAGER}]}
    special_conditions JSONB DEFAULT '{}',               -- Emergency overrides, critical escalations
    priority_order INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(customer_id, policy_name)
);

-- 3. ORGANIZATIONAL HIERARCHY (Read-Only Master Data)
CREATE TABLE IF NOT EXISTS organizational_hierarchy (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    manager_id UUID,
    company_code VARCHAR(10) NOT NULL,
    country_code VARCHAR(3) NOT NULL,
    department_code VARCHAR(20) NOT NULL,
    plant_code VARCHAR(10),
    position_title VARCHAR(100),
    approval_limit DECIMAL(15,2) DEFAULT 0,
    approval_limit_currency VARCHAR(3) DEFAULT 'USD',
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. FUNCTIONAL APPROVER ASSIGNMENTS (Policy-Driven)
CREATE TABLE IF NOT EXISTS functional_approver_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    functional_domain VARCHAR(20) NOT NULL CHECK (functional_domain IN ('FINANCE', 'LEGAL', 'SAFETY', 'QUALITY', 'PROJECT_CONTROLS', 'COMPLIANCE')),
    approver_user_id UUID NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    approval_scope VARCHAR(20) NOT NULL CHECK (approval_scope IN ('DEPARTMENT', 'COUNTRY', 'MULTI_COUNTRY', 'GLOBAL')),
    company_code VARCHAR(10),
    country_code VARCHAR(3),
    department_code VARCHAR(20),
    plant_code VARCHAR(10),
    approval_limit DECIMAL(15,2),
    approval_limit_currency VARCHAR(3) DEFAULT 'USD',
    execution_mode VARCHAR(20) DEFAULT 'SEQUENTIAL' CHECK (execution_mode IN ('SEQUENTIAL', 'PARALLEL')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. APPROVAL INSTANCES (Runtime Generated, Immutable)
CREATE TABLE IF NOT EXISTS approval_instances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL,
    approval_object_type VARCHAR(20) NOT NULL,
    approval_object_document_type VARCHAR(10) NOT NULL,
    document_value DECIMAL(15,2),
    currency VARCHAR(3),
    requestor_user_id UUID NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    country_code VARCHAR(3) NOT NULL,
    department_code VARCHAR(20) NOT NULL,
    plant_code VARCHAR(10),
    project_code VARCHAR(20),
    resolved_strategy VARCHAR(20) NOT NULL,
    resolved_pattern VARCHAR(30) NOT NULL,
    approval_flow JSONB NOT NULL,                        -- Immutable approval sequence
    audit_explanation JSONB NOT NULL,                    -- Why each step was included
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'CANCELLED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 6. APPROVAL STEPS (Generated from Instance)
CREATE TABLE IF NOT EXISTS approval_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instance_id UUID NOT NULL REFERENCES approval_instances(id) ON DELETE CASCADE,
    sequence_number INTEGER NOT NULL,
    approver_user_id UUID NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    approval_type VARCHAR(20) NOT NULL CHECK (approval_type IN ('FUNCTIONAL', 'SUPERVISORY')),
    approval_domain VARCHAR(20),                         -- FINANCE, LEGAL, HIERARCHY
    approval_scope VARCHAR(20) NOT NULL CHECK (approval_scope IN ('DEPT', 'COUNTRY', 'GLOBAL')),
    approval_limit_used DECIMAL(15,2),
    execution_mode VARCHAR(20) DEFAULT 'SEQUENTIAL' CHECK (execution_mode IN ('SEQUENTIAL', 'PARALLEL')),
    parallel_group INTEGER,                              -- For parallel execution grouping
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'DELEGATED', 'SKIPPED')),
    action_date TIMESTAMP WITH TIME ZONE,
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(instance_id, sequence_number)
);

-- 7. DELEGATIONS AND SUBSTITUTIONS
CREATE TABLE IF NOT EXISTS approval_delegations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delegator_user_id UUID NOT NULL,
    delegate_user_id UUID NOT NULL,
    delegation_scope VARCHAR(20) DEFAULT 'ALL' CHECK (delegation_scope IN ('ALL', 'FUNCTIONAL', 'SUPERVISORY')),
    functional_domains TEXT[],                           -- Specific domains if scope is FUNCTIONAL
    approval_object_types TEXT[],                        -- Specific object types
    amount_limit DECIMAL(15,2),
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    reason TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_approval_policies_lookup ON approval_policies(customer_id, approval_object_type, approval_object_document_type, company_code, country_code);
CREATE INDEX IF NOT EXISTS idx_org_hierarchy_manager ON organizational_hierarchy(manager_id, is_active);
CREATE INDEX IF NOT EXISTS idx_org_hierarchy_user ON organizational_hierarchy(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_functional_approvers_domain ON functional_approver_assignments(functional_domain, approval_scope, is_active);
CREATE INDEX IF NOT EXISTS idx_approval_instances_document ON approval_instances(document_id, approval_object_type);
CREATE INDEX IF NOT EXISTS idx_approval_steps_instance ON approval_steps(instance_id, sequence_number);
CREATE INDEX IF NOT EXISTS idx_delegations_active ON approval_delegations(delegator_user_id, is_active, valid_from, valid_to);

-- 9. SEED APPROVAL OBJECT REGISTRY
INSERT INTO approval_object_registry (approval_object_type, approval_object_document_type, object_name, check_for_value, default_strategy, required_functional_domains) VALUES
('PO', 'NB', 'Standard Purchase Order', true, 'AMOUNT_BASED', '{FINANCE}'),
('PO', 'EM', 'Emergency Purchase Order', true, 'AMOUNT_BASED', '{FINANCE}'),
('PO', 'CR', 'Critical Purchase Order', true, 'HYBRID', '{FINANCE,LEGAL}'),
('PR', 'NB', 'Standard Purchase Request', false, 'ROLE_BASED', '{}'),
('PR', 'EM', 'Emergency Purchase Request', false, 'ROLE_BASED', '{}'),
('PR', 'SP', 'Special Purchase Request', false, 'HYBRID', '{LEGAL}'),
('MR', 'NB', 'Standard Material Request', false, 'ROLE_BASED', '{}'),
('MR', 'EM', 'Emergency Material Request', false, 'ROLE_BASED', '{}'),
('MR', 'CR', 'Critical Material Request', false, 'ROLE_BASED', '{SAFETY}'),
('CLAIM', 'NB', 'Standard Claim', true, 'HYBRID', '{FINANCE,LEGAL}'),
('CLAIM', 'EM', 'Emergency Claim', true, 'HYBRID', '{FINANCE,LEGAL}'),
('DOC_REVIEW', 'NB', 'Document Review', false, 'ROLE_BASED', '{LEGAL}'),
('SITE_CLAIM', 'NB', 'Site Claim', true, 'HYBRID', '{FINANCE,SAFETY}');

SELECT 'UNIVERSAL ENTERPRISE APPROVAL ENGINE SCHEMA CREATED' as status;
SELECT 'Ready for Policy Configuration and Runtime Engine Implementation' as next_step;
-- Step 1.1: Enhance approval_policies table with universal fields
ALTER TABLE approval_policies 
ADD COLUMN IF NOT EXISTS object_category VARCHAR(30), -- FINANCIAL, DOCUMENT, STORAGE, TRAVEL, HR
ADD COLUMN IF NOT EXISTS object_subtype VARCHAR(30), -- Granular control
ADD COLUMN IF NOT EXISTS approval_context JSONB, -- Flexible context data
ADD COLUMN IF NOT EXISTS business_rules JSONB, -- Custom business logic
ADD COLUMN IF NOT EXISTS escalation_rules JSONB, -- Escalation configuration
ADD COLUMN IF NOT EXISTS storage_location_code VARCHAR(30),
ADD COLUMN IF NOT EXISTS storage_type VARCHAR(20),
ADD COLUMN IF NOT EXISTS document_category VARCHAR(30),
ADD COLUMN IF NOT EXISTS document_discipline VARCHAR(30),
ADD COLUMN IF NOT EXISTS revision_type VARCHAR(30);

-- Step 1.2: Create approval_object_types master table
CREATE TABLE IF NOT EXISTS approval_object_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    object_type VARCHAR(30) NOT NULL,
    object_category VARCHAR(30) NOT NULL,
    object_name VARCHAR(100) NOT NULL,
    description TEXT,
    default_strategy VARCHAR(30),
    required_fields JSONB,
    validation_rules JSONB,
    form_config JSONB, -- UI form configuration
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 1.3: Create approval_instances table for tracking
CREATE TABLE IF NOT EXISTS approval_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    object_type VARCHAR(30) NOT NULL,
    object_id VARCHAR(50) NOT NULL, -- Reference to actual object
    policy_id UUID REFERENCES approval_policies(id),
    current_step INTEGER DEFAULT 1,
    total_steps INTEGER,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, CANCELLED
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Step 1.4: Create approval_steps table for workflow tracking
CREATE TABLE IF NOT EXISTS approval_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    approval_instance_id UUID NOT NULL REFERENCES approval_instances(id),
    step_number INTEGER NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    approver_user_id UUID,
    status VARCHAR(20) DEFAULT 'PENDING',
    approved_at TIMESTAMP WITH TIME ZONE,
    comments TEXT,
    is_required BOOLEAN DEFAULT true
);
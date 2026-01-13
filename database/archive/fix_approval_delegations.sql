-- FIX: Update approval_delegations table structure
-- This script fixes the column naming issue

-- Check if the table exists and what columns it has
SELECT 'CHECKING EXISTING APPROVAL_DELEGATIONS TABLE:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'approval_delegations' 
ORDER BY ordinal_position;

-- Drop and recreate the table with correct structure
DROP TABLE IF EXISTS approval_delegations CASCADE;

-- Recreate with correct column names
CREATE TABLE approval_delegations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delegator_user_id UUID NOT NULL,
    delegate_user_id UUID NOT NULL,
    delegation_scope VARCHAR(20) DEFAULT 'ALL' CHECK (delegation_scope IN ('ALL', 'FUNCTIONAL', 'SUPERVISORY')),
    functional_domains TEXT[],
    approval_object_types TEXT[],
    amount_limit DECIMAL(15,2),
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    reason TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recreate the index
CREATE INDEX IF NOT EXISTS idx_delegations_active ON approval_delegations(delegator_user_id, is_active, valid_from, valid_to);

SELECT 'APPROVAL_DELEGATIONS TABLE FIXED' as status;
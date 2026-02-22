-- Cleanup Script: Remove redundant approval columns and old workflow approach
-- Keep only status field on material_requests, workflow engine handles rest

-- 1. Drop old approval columns from material_requests (if they exist)
ALTER TABLE material_requests
DROP COLUMN IF EXISTS submitted_at,
DROP COLUMN IF EXISTS approved_by,
DROP COLUMN IF EXISTS approved_date,
DROP COLUMN IF EXISTS rejected_by,
DROP COLUMN IF EXISTS rejected_date,
DROP COLUMN IF EXISTS rejection_reason,
DROP COLUMN IF EXISTS primary_workflow_id,
DROP COLUMN IF EXISTS workflow_strategy;

-- 2. Drop old workflow trigger (if exists)
DROP TRIGGER IF EXISTS trg_mr_approval_workflow ON material_requests;
DROP FUNCTION IF EXISTS trigger_mr_approval_workflow();

-- 3. Ensure status field has correct values
ALTER TABLE material_requests
DROP CONSTRAINT IF EXISTS material_requests_status_check;

ALTER TABLE material_requests
ADD CONSTRAINT material_requests_status_check 
CHECK (status IN ('DRAFT', 'SUBMITTED', 'IN_APPROVAL', 'APPROVED', 'REJECTED', 'CANCELLED'));

-- 4. Update existing records with old status values
UPDATE material_requests SET status = 'IN_APPROVAL' WHERE status = 'SUBMITTED';

-- 5. Drop old approval tables (if they exist and are not needed)
DROP TABLE IF EXISTS approval_history CASCADE;
DROP TABLE IF EXISTS approval_workflow_steps CASCADE;
DROP TABLE IF EXISTS approval_workflows CASCADE;
DROP TABLE IF EXISTS workflow_start_conditions CASCADE;

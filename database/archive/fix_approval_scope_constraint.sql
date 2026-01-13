-- FIX: Update approval_steps table constraint for approval_scope
-- The constraint expects 'DEPT' but the function is using 'DEPARTMENT'

-- Drop the existing constraint
ALTER TABLE approval_steps DROP CONSTRAINT IF EXISTS approval_steps_approval_scope_check;

-- Add the correct constraint that matches what the function generates
ALTER TABLE approval_steps ADD CONSTRAINT approval_steps_approval_scope_check 
CHECK (approval_scope IN ('DEPARTMENT', 'COUNTRY', 'GLOBAL', 'DEPT'));

SELECT 'APPROVAL_STEPS CONSTRAINT FIXED' as status;
SELECT 'Now approval_scope accepts: DEPARTMENT, COUNTRY, GLOBAL, DEPT' as info;
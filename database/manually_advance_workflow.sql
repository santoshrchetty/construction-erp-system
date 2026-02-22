-- Manually advance workflow to step 2 for testing
UPDATE workflow_instances
SET current_step_sequence = 2
WHERE id = '2b56596c-00d8-4d57-8a56-99dcc318d9d7';

-- Verify the update
SELECT id, status, current_step_sequence
FROM workflow_instances
WHERE id = '2b56596c-00d8-4d57-8a56-99dcc318d9d7';

-- Now check if we need to manually create step 2 instances
-- First, get the workflow step definition for step 2
SELECT id, step_sequence, step_name
FROM workflow_steps
WHERE workflow_id = (
  SELECT workflow_id FROM workflow_instances WHERE id = '2b56596c-00d8-4d57-8a56-99dcc318d9d7'
)
AND step_sequence = 2;

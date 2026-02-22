-- Check workflow instance context_data
SELECT 
  id,
  context_data,
  requester_id,
  object_id
FROM workflow_instances
WHERE id = 'ef6ba83d-a16d-4c87-853e-953aafba2dd8';

-- Make tenant_id nullable in workflow_instances
ALTER TABLE workflow_instances 
ALTER COLUMN tenant_id DROP NOT NULL;

-- Verify the change
SELECT column_name, is_nullable, data_type
FROM information_schema.columns 
WHERE table_name = 'workflow_instances'
AND column_name = 'tenant_id';

-- Make authorization_objects tenant-specific
ALTER TABLE authorization_objects DROP CONSTRAINT IF EXISTS authorization_objects_object_name_key;
ALTER TABLE authorization_objects ADD CONSTRAINT authorization_objects_object_name_tenant_key UNIQUE (object_name, tenant_id);

-- Verify
SELECT 'Constraint updated' as status;

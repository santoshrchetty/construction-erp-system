-- Step 4: Make tenant_id NOT NULL and add indexes
-- Run this AFTER Step 3 (after all data has tenant_id populated)

-- Make tenant_id NOT NULL in authorization_objects
ALTER TABLE authorization_objects 
ALTER COLUMN tenant_id SET NOT NULL;

-- Make tenant_id NOT NULL in authorization_fields
ALTER TABLE authorization_fields 
ALTER COLUMN tenant_id SET NOT NULL;

-- Make tenant_id NOT NULL in role_authorization_objects
ALTER TABLE role_authorization_objects 
ALTER COLUMN tenant_id SET NOT NULL;

-- Make tenant_id NOT NULL in roles
ALTER TABLE roles 
ALTER COLUMN tenant_id SET NOT NULL;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_auth_objects_tenant 
ON authorization_objects(tenant_id);

CREATE INDEX IF NOT EXISTS idx_auth_fields_tenant 
ON authorization_fields(tenant_id);

CREATE INDEX IF NOT EXISTS idx_role_auth_objects_tenant 
ON role_authorization_objects(tenant_id);

CREATE INDEX IF NOT EXISTS idx_roles_tenant 
ON roles(tenant_id);

-- Add composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_auth_objects_tenant_module 
ON authorization_objects(tenant_id, module);

CREATE INDEX IF NOT EXISTS idx_role_auth_objects_tenant_role 
ON role_authorization_objects(tenant_id, role_id);

-- Verify constraints and indexes
SELECT 
    t.table_name,
    c.column_name,
    c.is_nullable,
    CASE 
        WHEN i.indexname IS NOT NULL THEN '✅ Indexed'
        ELSE '❌ Not Indexed'
    END as index_status
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name
LEFT JOIN pg_indexes i ON t.table_name = i.tablename 
    AND i.indexdef LIKE '%' || c.column_name || '%'
WHERE t.table_name IN (
    'authorization_objects',
    'authorization_fields',
    'role_authorization_objects',
    'roles'
)
AND c.column_name = 'tenant_id'
ORDER BY t.table_name;

-- Summary
SELECT '✅ Step 4 Complete: tenant_id is now NOT NULL with indexes' as status;

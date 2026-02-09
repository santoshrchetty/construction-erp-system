-- Step 3: Populate tenant_id for existing data
-- Run this AFTER Step 2 if tenant_id columns were added

-- First, check if there's a default tenant or get the first tenant
DO $$
DECLARE
    default_tenant_id UUID;
    tenant_count INTEGER;
BEGIN
    -- Count tenants
    SELECT COUNT(*) INTO tenant_count FROM tenants;
    
    IF tenant_count = 0 THEN
        RAISE EXCEPTION '❌ No tenants found! Create a tenant first.';
    END IF;
    
    -- Get first tenant (or specific tenant if you know the ID)
    SELECT id INTO default_tenant_id FROM tenants LIMIT 1;
    
    RAISE NOTICE '📌 Using tenant_id: %', default_tenant_id;
    
    -- Update authorization_objects
    UPDATE authorization_objects 
    SET tenant_id = default_tenant_id 
    WHERE tenant_id IS NULL;
    
    RAISE NOTICE '✅ Updated % authorization_objects', 
        (SELECT COUNT(*) FROM authorization_objects WHERE tenant_id = default_tenant_id);
    
    -- Update authorization_fields
    UPDATE authorization_fields 
    SET tenant_id = default_tenant_id 
    WHERE tenant_id IS NULL;
    
    RAISE NOTICE '✅ Updated % authorization_fields', 
        (SELECT COUNT(*) FROM authorization_fields WHERE tenant_id = default_tenant_id);
    
    -- Update role_authorization_objects
    UPDATE role_authorization_objects 
    SET tenant_id = default_tenant_id 
    WHERE tenant_id IS NULL;
    
    RAISE NOTICE '✅ Updated % role_authorization_objects', 
        (SELECT COUNT(*) FROM role_authorization_objects WHERE tenant_id = default_tenant_id);
    
    -- Update roles
    UPDATE roles 
    SET tenant_id = default_tenant_id 
    WHERE tenant_id IS NULL;
    
    RAISE NOTICE '✅ Updated % roles', 
        (SELECT COUNT(*) FROM roles WHERE tenant_id = default_tenant_id);
END $$;

-- Verify all records have tenant_id
SELECT 
    'authorization_objects' as table_name,
    COUNT(*) as total_rows,
    COUNT(tenant_id) as rows_with_tenant,
    COUNT(*) - COUNT(tenant_id) as rows_without_tenant
FROM authorization_objects
UNION ALL
SELECT 
    'authorization_fields',
    COUNT(*),
    COUNT(tenant_id),
    COUNT(*) - COUNT(tenant_id)
FROM authorization_fields
UNION ALL
SELECT 
    'role_authorization_objects',
    COUNT(*),
    COUNT(tenant_id),
    COUNT(*) - COUNT(tenant_id)
FROM role_authorization_objects
UNION ALL
SELECT 
    'roles',
    COUNT(*),
    COUNT(tenant_id),
    COUNT(*) - COUNT(tenant_id)
FROM roles;

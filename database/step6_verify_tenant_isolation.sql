-- Step 6: Verify tenant isolation is working
-- Run this to test that data is properly isolated by tenant

-- Get list of all tenants
SELECT id, name, subdomain FROM tenants ORDER BY name;

-- Check data distribution by tenant
SELECT 
    'authorization_objects' as table_name,
    tenant_id,
    t.name as tenant_name,
    COUNT(*) as record_count
FROM authorization_objects ao
LEFT JOIN tenants t ON ao.tenant_id = t.id
GROUP BY tenant_id, t.name
ORDER BY tenant_name;

SELECT 
    'authorization_fields' as table_name,
    tenant_id,
    t.name as tenant_name,
    COUNT(*) as record_count
FROM authorization_fields af
LEFT JOIN tenants t ON af.tenant_id = t.id
GROUP BY tenant_id, t.name
ORDER BY tenant_name;

SELECT 
    'role_authorization_objects' as table_name,
    tenant_id,
    t.name as tenant_name,
    COUNT(*) as record_count
FROM role_authorization_objects rao
LEFT JOIN tenants t ON rao.tenant_id = t.id
GROUP BY tenant_id, t.name
ORDER BY tenant_name;

SELECT 
    'roles' as table_name,
    tenant_id,
    t.name as tenant_name,
    COUNT(*) as record_count
FROM roles r
LEFT JOIN tenants t ON r.tenant_id = t.id
GROUP BY tenant_id, t.name
ORDER BY tenant_name;

-- Test query: Simulate what API should return for a specific tenant
-- Replace 'YOUR_TENANT_ID' with actual tenant ID
DO $$
DECLARE
    test_tenant_id UUID;
BEGIN
    -- Get first tenant for testing
    SELECT id INTO test_tenant_id FROM tenants LIMIT 1;
    
    RAISE NOTICE '🧪 Testing tenant isolation for tenant: %', test_tenant_id;
    
    -- Show what this tenant should see
    RAISE NOTICE '📊 Authorization Objects: %', 
        (SELECT COUNT(*) FROM authorization_objects WHERE tenant_id = test_tenant_id);
    
    RAISE NOTICE '📊 Authorization Fields: %', 
        (SELECT COUNT(*) FROM authorization_fields WHERE tenant_id = test_tenant_id);
    
    RAISE NOTICE '📊 Role Assignments: %', 
        (SELECT COUNT(*) FROM role_authorization_objects WHERE tenant_id = test_tenant_id);
    
    RAISE NOTICE '📊 Roles: %', 
        (SELECT COUNT(*) FROM roles WHERE tenant_id = test_tenant_id);
END $$;

-- Verify NO NULL tenant_ids exist
SELECT 
    'authorization_objects' as table_name,
    COUNT(*) FILTER (WHERE tenant_id IS NULL) as null_tenant_count,
    CASE 
        WHEN COUNT(*) FILTER (WHERE tenant_id IS NULL) = 0 THEN '✅ All records have tenant_id'
        ELSE '❌ Found records without tenant_id'
    END as status
FROM authorization_objects
UNION ALL
SELECT 
    'authorization_fields',
    COUNT(*) FILTER (WHERE tenant_id IS NULL),
    CASE 
        WHEN COUNT(*) FILTER (WHERE tenant_id IS NULL) = 0 THEN '✅ All records have tenant_id'
        ELSE '❌ Found records without tenant_id'
    END
FROM authorization_fields
UNION ALL
SELECT 
    'role_authorization_objects',
    COUNT(*) FILTER (WHERE tenant_id IS NULL),
    CASE 
        WHEN COUNT(*) FILTER (WHERE tenant_id IS NULL) = 0 THEN '✅ All records have tenant_id'
        ELSE '❌ Found records without tenant_id'
    END
FROM role_authorization_objects
UNION ALL
SELECT 
    'roles',
    COUNT(*) FILTER (WHERE tenant_id IS NULL),
    CASE 
        WHEN COUNT(*) FILTER (WHERE tenant_id IS NULL) = 0 THEN '✅ All records have tenant_id'
        ELSE '❌ Found records without tenant_id'
    END
FROM roles;

-- Final summary
SELECT '✅ Tenant Isolation Verification Complete' as status;

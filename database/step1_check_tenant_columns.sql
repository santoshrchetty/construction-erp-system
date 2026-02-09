-- Step 1: Check if tenant_id columns exist in authorization tables
-- Run this first to understand current schema

-- Check authorization_objects table
SELECT 
    'authorization_objects' as table_name,
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'authorization_objects'
ORDER BY ordinal_position;

-- Check authorization_fields table
SELECT 
    'authorization_fields' as table_name,
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'authorization_fields'
ORDER BY ordinal_position;

-- Check role_authorization_objects table
SELECT 
    'role_authorization_objects' as table_name,
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'role_authorization_objects'
ORDER BY ordinal_position;

-- Check roles table
SELECT 
    'roles' as table_name,
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'roles'
ORDER BY ordinal_position;

-- Summary: Check which tables have tenant_id
SELECT 
    table_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = t.table_name AND column_name = 'tenant_id'
        ) THEN '✅ HAS tenant_id'
        ELSE '❌ MISSING tenant_id'
    END as tenant_id_status
FROM (
    VALUES 
        ('authorization_objects'),
        ('authorization_fields'),
        ('role_authorization_objects'),
        ('roles')
) AS t(table_name);

-- Check if there's data in these tables
SELECT 
    'authorization_objects' as table_name,
    COUNT(*) as row_count,
    COUNT(DISTINCT CASE WHEN tenant_id IS NOT NULL THEN tenant_id END) as distinct_tenants
FROM authorization_objects
UNION ALL
SELECT 
    'authorization_fields',
    COUNT(*),
    COUNT(DISTINCT CASE WHEN tenant_id IS NOT NULL THEN tenant_id END)
FROM authorization_fields
UNION ALL
SELECT 
    'role_authorization_objects',
    COUNT(*),
    COUNT(DISTINCT CASE WHEN tenant_id IS NOT NULL THEN tenant_id END)
FROM role_authorization_objects
UNION ALL
SELECT 
    'roles',
    COUNT(*),
    COUNT(DISTINCT CASE WHEN tenant_id IS NOT NULL THEN tenant_id END)
FROM roles;

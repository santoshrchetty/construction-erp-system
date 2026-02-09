-- Step 2: Add tenant_id columns to authorization tables (if missing)
-- Run this ONLY if Step 1 shows missing tenant_id columns

-- Add tenant_id to authorization_objects (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'authorization_objects' AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE authorization_objects 
        ADD COLUMN tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;
        
        RAISE NOTICE '✅ Added tenant_id to authorization_objects';
    ELSE
        RAISE NOTICE '⚠️ tenant_id already exists in authorization_objects';
    END IF;
END $$;

-- Add tenant_id to authorization_fields (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'authorization_fields' AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE authorization_fields 
        ADD COLUMN tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;
        
        RAISE NOTICE '✅ Added tenant_id to authorization_fields';
    ELSE
        RAISE NOTICE '⚠️ tenant_id already exists in authorization_fields';
    END IF;
END $$;

-- Add tenant_id to role_authorization_objects (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'role_authorization_objects' AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE role_authorization_objects 
        ADD COLUMN tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;
        
        RAISE NOTICE '✅ Added tenant_id to role_authorization_objects';
    ELSE
        RAISE NOTICE '⚠️ tenant_id already exists in role_authorization_objects';
    END IF;
END $$;

-- Add tenant_id to roles (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'roles' AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE roles 
        ADD COLUMN tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE;
        
        RAISE NOTICE '✅ Added tenant_id to roles';
    ELSE
        RAISE NOTICE '⚠️ tenant_id already exists in roles';
    END IF;
END $$;

-- Verify columns were added
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN (
    'authorization_objects',
    'authorization_fields',
    'role_authorization_objects',
    'roles'
)
AND column_name = 'tenant_id';

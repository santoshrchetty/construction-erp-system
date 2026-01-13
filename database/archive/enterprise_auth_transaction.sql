-- Enterprise Authorization Analysis & Assignment Transaction
-- ========================================================

BEGIN;

-- Step 1: Authorization Gap Analysis
-- ==================================
CREATE TEMP TABLE auth_gap_analysis AS
WITH required_authorizations AS (
    -- Get all authorization objects that tiles require
    SELECT DISTINCT 
        t.auth_object,
        t.construction_action,
        t.tile_category,
        t.title as tile_name
    FROM tiles t 
    WHERE t.auth_object IS NOT NULL
    AND t.tile_category IN ('Materials', 'Warehouse', 'Configuration')
),
current_role_mappings AS (
    -- Get current role-based authorization mappings
    SELECT 
        ram.role_name,
        ram.auth_object_name,
        ram.field_values
    FROM role_authorization_mapping ram
    WHERE ram.role_name = 'Admin'
),
current_user_auths AS (
    -- Get current user authorizations
    SELECT 
        ao.object_name,
        ua.field_values
    FROM user_authorizations ua
    JOIN authorization_objects ao ON ua.auth_object_id = ao.id
    WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
)
SELECT 
    ra.auth_object,
    ra.construction_action,
    ra.tile_category,
    ra.tile_name,
    CASE WHEN crm.auth_object_name IS NOT NULL THEN 'ROLE_MAPPED' ELSE 'MISSING_ROLE_MAPPING' END as role_status,
    CASE WHEN cua.object_name IS NOT NULL THEN 'USER_AUTHORIZED' ELSE 'MISSING_USER_AUTH' END as user_status,
    crm.field_values as role_permissions,
    cua.field_values as user_permissions
FROM required_authorizations ra
LEFT JOIN current_role_mappings crm ON ra.auth_object = crm.auth_object_name
LEFT JOIN current_user_auths cua ON ra.auth_object = cua.object_name;

-- Step 2: Display Gap Analysis Results
-- ===================================
SELECT 'AUTHORIZATION GAP ANALYSIS' as analysis_type, * FROM auth_gap_analysis
ORDER BY tile_category, auth_object;

-- Step 3: Missing Authorization Objects Analysis
-- =============================================
CREATE TEMP TABLE missing_auth_objects AS
SELECT DISTINCT aga.auth_object
FROM auth_gap_analysis aga
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_objects ao 
    WHERE ao.object_name = aga.auth_object
);

SELECT 'MISSING AUTHORIZATION OBJECTS' as analysis_type, * FROM missing_auth_objects;

-- Step 4: Create Missing Authorization Objects
-- ===========================================
INSERT INTO authorization_objects (object_name, description, module)
SELECT 
    mao.auth_object,
    CASE 
        WHEN mao.auth_object LIKE 'MM_%' THEN 'Materials Management - ' || mao.auth_object
        WHEN mao.auth_object LIKE 'WM_%' THEN 'Warehouse Management - ' || mao.auth_object
        WHEN mao.auth_object LIKE 'PS_%' THEN 'Project System - ' || mao.auth_object
        ELSE 'System Authorization - ' || mao.auth_object
    END as description,
    CASE 
        WHEN mao.auth_object LIKE 'MM_%' THEN 'materials'
        WHEN mao.auth_object LIKE 'WM_%' THEN 'warehouse'
        WHEN mao.auth_object LIKE 'PS_%' THEN 'projects'
        ELSE 'system'
    END as module
FROM missing_auth_objects mao;

-- Step 5: Create Authorization Fields for New Objects
-- ==================================================
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT 
    ao.id,
    'ACTION',
    'Construction Action',
    ARRAY['INITIATE', 'MODIFY', 'REVIEW', 'EXECUTE', 'APPROVE', 'ANALYZE']
FROM authorization_objects ao
JOIN missing_auth_objects mao ON ao.object_name = mao.auth_object;

-- Step 6: Create Role Authorization Mappings
-- ==========================================
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values)
SELECT 
    'Admin',
    aga.auth_object,
    ('{"ACTION": ["' || aga.construction_action || '"]}')::jsonb
FROM auth_gap_analysis aga
WHERE aga.role_status = 'MISSING_ROLE_MAPPING'
AND NOT EXISTS (
    SELECT 1 FROM role_authorization_mapping ram 
    WHERE ram.role_name = 'Admin' 
    AND ram.auth_object_name = aga.auth_object
);

-- Step 7: Execute Role-Based Authorization Assignment
-- =================================================
DO $$
DECLARE
    admin_user_id UUID := '70f8baa8-27b8-4061-84c4-6dd027d6b89f';
    auth_count INTEGER;
BEGIN
    -- Clear existing user authorizations for clean reassignment
    DELETE FROM user_authorizations 
    WHERE user_id = admin_user_id;
    
    -- Reassign all Admin role authorizations
    PERFORM assign_role_authorizations(admin_user_id, 'Admin');
    
    -- Verify assignment count
    SELECT COUNT(*) INTO auth_count
    FROM user_authorizations 
    WHERE user_id = admin_user_id;
    
    RAISE NOTICE 'Admin user reassigned with % authorizations', auth_count;
END $$;

-- Step 8: Final Verification & Audit Trail
-- ========================================
CREATE TEMP TABLE final_verification AS
SELECT 
    'FINAL_VERIFICATION' as verification_type,
    t.title as tile_name,
    t.tile_category,
    t.auth_object,
    t.construction_action,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as is_authorized,
    CASE 
        WHEN check_construction_authorization(
            '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
            t.auth_object,
            t.construction_action,
            '{}'::jsonb
        ) THEN 'AUTHORIZED'
        ELSE 'DENIED'
    END as authorization_status
FROM tiles t
WHERE t.tile_category IN ('Materials', 'Warehouse', 'Configuration')
AND t.auth_object IS NOT NULL;

SELECT * FROM final_verification ORDER BY tile_category, tile_name;

-- Step 9: Create Audit Log Entry (Skip if audit_log table doesn't exist)
-- =====================================================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_log') THEN
        INSERT INTO audit_log (
            user_id, 
            action, 
            table_name, 
            record_id, 
            old_values, 
            new_values, 
            timestamp
        ) VALUES (
            '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
            'AUTHORIZATION_REASSIGNMENT',
            'user_authorizations',
            '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
            '{}',
            jsonb_build_object(
                'role', 'Admin',
                'authorization_objects_assigned', (
                    SELECT COUNT(*) FROM user_authorizations 
                    WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
                ),
                'tiles_authorized', (
                    SELECT COUNT(*) FROM final_verification WHERE is_authorized = true
                )
            ),
            NOW()
        );
        RAISE NOTICE 'Audit log entry created';
    ELSE
        RAISE NOTICE 'Audit log table not found, skipping audit entry';
    END IF;
END $$;

-- Clean up temporary tables
DROP TABLE IF EXISTS auth_gap_analysis;
DROP TABLE IF EXISTS missing_auth_objects;
DROP TABLE IF EXISTS final_verification;

COMMIT;

-- Final Status Report
-- ==================
SELECT 'TRANSACTION COMPLETED' as status, 
       'Admin user authorization analysis and assignment completed successfully' as message;
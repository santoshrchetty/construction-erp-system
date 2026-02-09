-- Fix Engineer Role: 0/18 modules issue
-- Root cause: authorization_objects have NULL/empty module field

-- Step 1: Check which objects have NULL/empty modules
SELECT 
    object_name,
    module,
    description,
    is_active,
    CASE 
        WHEN module IS NULL THEN '❌ NULL'
        WHEN TRIM(module) = '' THEN '❌ EMPTY'
        ELSE '✅ HAS VALUE'
    END as module_status
FROM authorization_objects
ORDER BY module_status, object_name;

-- Step 2: Count objects by module status
SELECT 
    CASE 
        WHEN module IS NULL THEN 'NULL modules'
        WHEN TRIM(module) = '' THEN 'EMPTY modules'
        ELSE 'Valid modules'
    END as status,
    COUNT(*) as count
FROM authorization_objects
GROUP BY 
    CASE 
        WHEN module IS NULL THEN 'NULL modules'
        WHEN TRIM(module) = '' THEN 'EMPTY modules'
        ELSE 'Valid modules'
    END;

-- Step 3: Show objects grouped by module (including NULL/empty)
SELECT 
    COALESCE(NULLIF(TRIM(module), ''), 'UNKNOWN') as module,
    COUNT(*) as object_count,
    STRING_AGG(object_name, ', ' ORDER BY object_name) as objects
FROM authorization_objects
GROUP BY COALESCE(NULLIF(TRIM(module), ''), 'UNKNOWN')
ORDER BY object_count DESC;

-- Step 4: Fix NULL/empty modules based on object name patterns
-- Materials module
UPDATE authorization_objects 
SET module = 'materials'
WHERE (module IS NULL OR TRIM(module) = '')
  AND (
    object_name LIKE 'MAT_%' OR
    object_name LIKE 'F_MATERIAL%' OR
    object_name LIKE 'M_MATE%'
  );

-- Procurement module
UPDATE authorization_objects 
SET module = 'procurement'
WHERE (module IS NULL OR TRIM(module) = '')
  AND (
    object_name LIKE 'PO_%' OR
    object_name LIKE 'PR_%' OR
    object_name LIKE 'F_PURCH%' OR
    object_name LIKE 'M_EINK%'
  );

-- Projects module
UPDATE authorization_objects 
SET module = 'projects'
WHERE (module IS NULL OR TRIM(module) = '')
  AND (
    object_name LIKE 'PROJ_%' OR
    object_name LIKE 'F_PROJECT%' OR
    object_name LIKE 'WBS_%'
  );

-- Finance module
UPDATE authorization_objects 
SET module = 'finance'
WHERE (module IS NULL OR TRIM(module) = '')
  AND (
    object_name LIKE 'FI_%' OR
    object_name LIKE 'F_BKPF%' OR
    object_name LIKE 'F_LFA1%'
  );

-- HR module
UPDATE authorization_objects 
SET module = 'hr'
WHERE (module IS NULL OR TRIM(module) = '')
  AND (
    object_name LIKE 'HR_%' OR
    object_name LIKE 'F_PA%' OR
    object_name LIKE 'P_ORGIN%'
  );

-- Admin/System module (catch-all for remaining)
UPDATE authorization_objects 
SET module = 'admin'
WHERE (module IS NULL OR TRIM(module) = '');

-- Step 5: Verify all objects now have modules
SELECT 
    CASE 
        WHEN module IS NULL OR TRIM(module) = '' THEN '❌ Still NULL/Empty'
        ELSE '✅ Has Module'
    END as status,
    COUNT(*) as count
FROM authorization_objects
GROUP BY 
    CASE 
        WHEN module IS NULL OR TRIM(module) = '' THEN '❌ Still NULL/Empty'
        ELSE '✅ Has Module'
    END;

-- Step 6: Show final module distribution
SELECT 
    module,
    COUNT(*) as object_count,
    COUNT(DISTINCT id) as unique_objects
FROM authorization_objects
GROUP BY module
ORDER BY object_count DESC;

-- Step 7: Check Engineer role assignments by module
SELECT 
    ao.module,
    COUNT(DISTINCT rao.auth_object_id) as assigned_objects,
    STRING_AGG(DISTINCT ao.object_name, ', ' ORDER BY ao.object_name) as object_names
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
JOIN roles r ON rao.role_id = r.id
WHERE r.name = 'Engineer'
GROUP BY ao.module
ORDER BY assigned_objects DESC;

-- Final summary
SELECT 
    '✅ Module assignment fix complete!' as status,
    COUNT(DISTINCT module) as total_modules,
    COUNT(*) as total_objects
FROM authorization_objects
WHERE module IS NOT NULL AND TRIM(module) != '';

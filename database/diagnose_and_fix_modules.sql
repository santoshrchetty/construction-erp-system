-- Quick diagnostic and fix for module assignment issue

-- 1. Check current module status
SELECT 
    CASE 
        WHEN module IS NULL OR TRIM(module) = '' THEN 'NULL/Empty'
        ELSE 'Has Module'
    END as status,
    COUNT(*) as count
FROM authorization_objects
GROUP BY CASE WHEN module IS NULL OR TRIM(module) = '' THEN 'NULL/Empty' ELSE 'Has Module' END;

-- 2. Apply fixes based on object name patterns
UPDATE authorization_objects SET module = 'materials' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'MAT_%';
UPDATE authorization_objects SET module = 'procurement' WHERE (module IS NULL OR TRIM(module) = '') AND (object_name LIKE 'PO_%' OR object_name LIKE 'PR_%' OR object_name LIKE 'MR_%');
UPDATE authorization_objects SET module = 'projects' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'PROJ_%';
UPDATE authorization_objects SET module = 'finance' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'FI_%';
UPDATE authorization_objects SET module = 'hr' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'HR_%';
UPDATE authorization_objects SET module = 'inventory' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'INV_%';
UPDATE authorization_objects SET module = 'warehouse' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'WH_%';
UPDATE authorization_objects SET module = 'quality' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'QM_%';
UPDATE authorization_objects SET module = 'maintenance' WHERE (module IS NULL OR TRIM(module) = '') AND object_name LIKE 'PM_%';
UPDATE authorization_objects SET module = 'admin' WHERE (module IS NULL OR TRIM(module) = '');

-- 3. Verify fix
SELECT module, COUNT(*) as count FROM authorization_objects GROUP BY module ORDER BY count DESC;

-- 4. Check Engineer role
SELECT ao.module, COUNT(*) as objects
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
JOIN roles r ON rao.role_id = r.id
WHERE r.name = 'Engineer'
GROUP BY ao.module
ORDER BY objects DESC;

-- 5. Check PlanEng role
SELECT ao.module, COUNT(*) as objects
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
JOIN roles r ON rao.role_id = r.id
WHERE r.name = 'PlanEng'
GROUP BY ao.module
ORDER BY objects DESC;

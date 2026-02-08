-- ============================================================================
-- STEP 6: Final Verification and Cleanup
-- ============================================================================
-- Purpose: Verify migration success and optionally cleanup backup
-- Safe to run: YES (read-only + optional cleanup)
-- ============================================================================

-- 6.1 Verify No SAP Codes Remain in System
SELECT 
    'VERIFICATION: SAP Codes in tiles' as check_name,
    CASE 
        WHEN COUNT(*) = 0 THEN '✓ PASS - No SAP codes found'
        ELSE '✗ FAIL - ' || COUNT(*)::text || ' SAP codes found'
    END as result
FROM tiles
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');

-- 6.2 Verify All Tiles Have Friendly Module Names
SELECT 
    'VERIFICATION: Tiles with friendly names' as check_name,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM tiles) 
        THEN '✓ PASS - All ' || COUNT(*)::text || ' tiles have friendly module names'
        ELSE '✗ FAIL - Only ' || COUNT(*)::text || ' of ' || (SELECT COUNT(*) FROM tiles)::text || ' tiles have friendly names'
    END as result
FROM tiles
WHERE module_code IN (
    'admin', 'configuration', 'documents', 'safety', 'emergency',
    'finance', 'hr', 'integration', 'materials', 'procurement',
    'user_tasks', 'projects', 'quality', 'reporting', 'warehouse'
);

-- 6.3 Verify MM Split Success
SELECT 
    'VERIFICATION: MM split into materials and procurement' as check_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM tiles WHERE module_code = 'materials')
         AND EXISTS (SELECT 1 FROM tiles WHERE module_code = 'procurement')
         AND NOT EXISTS (SELECT 1 FROM tiles WHERE module_code = 'MM')
        THEN '✓ PASS - MM successfully split'
        ELSE '✗ FAIL - MM split incomplete'
    END as result;

-- 6.4 Verify RPC Function Returns Friendly Names
SELECT 
    'VERIFICATION: RPC returns friendly names' as check_name,
    CASE 
        WHEN COUNT(*) = 0 
        THEN '✓ PASS - No SAP codes in RPC output'
        ELSE '✗ FAIL - ' || COUNT(*)::text || ' SAP codes in RPC output'
    END as result
FROM get_user_modules((SELECT id FROM users WHERE email = 'admin@prom.com'))
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');

-- 6.5 Verify Module Consistency
SELECT 
    'VERIFICATION: Module consistency' as check_name,
    CASE 
        WHEN COUNT(*) = 0 
        THEN '✓ PASS - All auth object modules have corresponding tiles'
        ELSE '⚠ WARNING - ' || COUNT(*)::text || ' modules in auth_objects without tiles'
    END as result
FROM (
    SELECT DISTINCT module 
    FROM authorization_objects 
    WHERE module IS NOT NULL
) ao
WHERE ao.module NOT IN (SELECT DISTINCT module_code FROM tiles);

-- 6.6 Compare Before and After
SELECT 
    'COMPARISON: Module codes' as metric,
    'Before (SAP)' as state,
    COUNT(DISTINCT module_code) as count
FROM tiles_backup_sap_codes
UNION ALL
SELECT 
    'COMPARISON: Module codes' as metric,
    'After (Friendly)' as state,
    COUNT(DISTINCT module_code) as count
FROM tiles
UNION ALL
SELECT 
    'COMPARISON: Total tiles' as metric,
    'Before' as state,
    COUNT(*) as count
FROM tiles_backup_sap_codes
UNION ALL
SELECT 
    'COMPARISON: Total tiles' as metric,
    'After' as state,
    COUNT(*) as count
FROM tiles;

-- 6.7 Show Final Module Distribution
SELECT 
    'FINAL STATE: Module distribution' as report,
    module_code,
    COUNT(*) as tile_count,
    STRING_AGG(DISTINCT tile_category, ', ') as categories
FROM tiles
WHERE is_active = true
GROUP BY module_code
ORDER BY module_code;

-- 6.8 Backup Table Info
SELECT 
    'BACKUP TABLE: tiles_backup_sap_codes' as info,
    COUNT(*) as rows,
    pg_size_pretty(pg_total_relation_size('tiles_backup_sap_codes')) as size
FROM tiles_backup_sap_codes;

-- ============================================================================
-- OPTIONAL: Drop Backup Table (Only after confirming everything works!)
-- ============================================================================
-- Uncomment the line below ONLY after thorough testing and verification
-- DROP TABLE IF EXISTS tiles_backup_sap_codes;

-- ============================================================================
-- SUCCESS CRITERIA
-- ============================================================================
-- All checks above should show ✓ PASS
-- Module count should be higher after migration (MM split into 2)
-- Total tile count should remain the same
-- No SAP codes should exist in tiles or RPC output
-- ============================================================================

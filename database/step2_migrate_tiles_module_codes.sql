-- ============================================================================
-- STEP 2: Update tiles.module_code to Friendly Names
-- ============================================================================
-- Purpose: Replace SAP codes with friendly module names in tiles table
-- Safe to run: YES (but creates data changes - backup exists)
-- Reversible: YES (use step6_rollback_tiles.sql if needed)
-- ============================================================================

-- 2.1 Update tiles with 1:1 SAP code mappings
UPDATE tiles SET module_code = 'admin' WHERE module_code = 'AD';
UPDATE tiles SET module_code = 'configuration' WHERE module_code = 'CF';
UPDATE tiles SET module_code = 'documents' WHERE module_code = 'DM';
UPDATE tiles SET module_code = 'safety' WHERE module_code = 'EH';
UPDATE tiles SET module_code = 'emergency' WHERE module_code = 'EM';
UPDATE tiles SET module_code = 'finance' WHERE module_code = 'FI';
UPDATE tiles SET module_code = 'hr' WHERE module_code = 'HR';
UPDATE tiles SET module_code = 'integration' WHERE module_code = 'IN';
UPDATE tiles SET module_code = 'user_tasks' WHERE module_code = 'MT';
UPDATE tiles SET module_code = 'projects' WHERE module_code = 'PS';
UPDATE tiles SET module_code = 'quality' WHERE module_code = 'QM';
UPDATE tiles SET module_code = 'reporting' WHERE module_code = 'RP';
UPDATE tiles SET module_code = 'warehouse' WHERE module_code = 'WM';

-- 2.2 Split MM code into materials and procurement based on tile_category
-- CRITICAL: This fixes the HR role issue where both materials and procurement were visible
UPDATE tiles 
SET module_code = 'materials' 
WHERE module_code = 'MM' 
  AND tile_category = 'Materials';

UPDATE tiles 
SET module_code = 'procurement' 
WHERE module_code = 'MM' 
  AND tile_category = 'Procurement';

-- 2.3 Verify no SAP codes remain
SELECT 
    'Verification: SAP codes remaining' as check_name,
    COUNT(*) as count
FROM tiles 
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');
-- Expected: 0 rows

-- 2.4 Show new module_code distribution
SELECT 
    module_code as friendly_module_name,
    COUNT(*) as tile_count,
    STRING_AGG(DISTINCT tile_category, ', ' ORDER BY tile_category) as categories
FROM tiles
GROUP BY module_code
ORDER BY module_code;

-- 2.5 Verify all tiles have valid friendly module codes
SELECT 
    'Verification: Tiles with friendly names' as check_name,
    COUNT(*) as count
FROM tiles
WHERE module_code IN (
    'admin', 'configuration', 'documents', 'safety', 'emergency',
    'finance', 'hr', 'integration', 'materials', 'procurement',
    'user_tasks', 'projects', 'quality', 'reporting', 'warehouse'
);
-- Expected: Should match total tile count

-- 2.6 Compare before and after
SELECT 
    'Before (SAP codes)' as state,
    COUNT(DISTINCT module_code) as unique_codes
FROM tiles_backup_sap_codes
UNION ALL
SELECT 
    'After (Friendly names)' as state,
    COUNT(DISTINCT module_code) as unique_codes
FROM tiles;
-- Note: After should have MORE codes because MM was split into materials + procurement

-- ============================================================================
-- STEP 1: Backup Current State
-- ============================================================================
-- Purpose: Create backup of tiles table before migration
-- Safe to run: YES (read-only + backup creation)
-- Reversible: YES (backup table created)
-- ============================================================================

-- 1.1 Create backup of tiles table
CREATE TABLE IF NOT EXISTS tiles_backup_sap_codes AS 
SELECT * FROM tiles;

-- Verify backup was created
SELECT 
    'Backup created' as status,
    COUNT(*) as total_tiles_backed_up
FROM tiles_backup_sap_codes;

-- 1.2 Document current SAP code distribution
SELECT 
    module_code as current_sap_code,
    COUNT(*) as tile_count
FROM tiles_backup_sap_codes 
GROUP BY module_code 
ORDER BY module_code;

-- 1.3 Show detailed mapping (SAP code → tile category → tiles)
SELECT 
    module_code as sap_code,
    tile_category,
    COUNT(*) as tile_count,
    STRING_AGG(title, ', ' ORDER BY title) as tile_titles
FROM tiles_backup_sap_codes
WHERE is_active = true
GROUP BY module_code, tile_category
ORDER BY module_code, tile_category;

-- 1.4 Identify MM split requirement (Materials vs Procurement)
SELECT 
    'MM code tiles that need splitting' as note,
    tile_category,
    COUNT(*) as count,
    STRING_AGG(title, ', ') as tiles
FROM tiles_backup_sap_codes
WHERE module_code = 'MM'
GROUP BY tile_category;

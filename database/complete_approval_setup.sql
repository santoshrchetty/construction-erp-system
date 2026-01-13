-- COMPLETE APPROVAL TILES SETUP SCRIPT
-- Run this to fix icons and ensure all tiles are properly configured

-- 1. Fix Approval Configuration icon (avoid duplicate with SAP Config)
UPDATE tiles 
SET icon = 'fas fa-check-circle'
WHERE title = 'Approval Configuration';

-- 2. Remove any remaining duplicate tiles
DELETE FROM tiles 
WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY title ORDER BY id) as rn
        FROM tiles 
        WHERE title ILIKE '%approval%'
    ) t WHERE rn > 1
);

-- 3. Verify final approval tiles setup
SELECT 'FINAL APPROVAL TILES:' as info;
SELECT title, icon, route FROM tiles 
WHERE title ILIKE '%approval%' 
ORDER BY title;

SELECT 'Setup complete' as result;
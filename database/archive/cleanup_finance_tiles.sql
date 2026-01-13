-- Clean Up Duplicate Finance Tiles
-- =================================

-- Find and remove duplicate Finance tiles (keep the newest ones)
DELETE FROM tiles 
WHERE id IN (
    SELECT id FROM (
        SELECT id, 
               ROW_NUMBER() OVER (
                   PARTITION BY title, tile_category, auth_object 
                   ORDER BY created_at DESC
               ) as rn
        FROM tiles 
        WHERE tile_category = 'Finance'
    ) t 
    WHERE rn > 1
);

-- Verify Finance tiles count after cleanup
SELECT 'Finance Tiles After Cleanup' as check_type;
SELECT COUNT(*) as total_finance_tiles
FROM tiles 
WHERE tile_category = 'Finance';

-- List all unique Finance tiles
SELECT 'Unique Finance Tiles' as check_type;
SELECT title, auth_object, construction_action, is_active
FROM tiles 
WHERE tile_category = 'Finance'
ORDER BY 
    CASE 
        WHEN auth_object LIKE 'FI_%' THEN 1
        WHEN auth_object LIKE 'CO_%' THEN 2
        ELSE 3
    END,
    title;

-- Force cache refresh by updating timestamps
UPDATE tiles 
SET updated_at = NOW() 
WHERE tile_category = 'Finance';
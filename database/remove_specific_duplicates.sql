-- REMOVE SPECIFIC DUPLICATE TILES
-- Keep only one instance of each duplicate tile

-- Find and remove duplicates for these specific tiles
DELETE FROM tiles 
WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY title ORDER BY id) as rn
        FROM tiles 
        WHERE title IN (
            'Approval Configuration',
            'Approval Templates', 
            'Customer Approval Setup',
            'Approval Analytics'
        )
    ) t WHERE rn > 1
);

-- Verify remaining tiles
SELECT title, COUNT(*) as count
FROM tiles 
WHERE title IN (
    'Approval Configuration',
    'Approval Templates', 
    'Customer Approval Setup',
    'Approval Analytics'
)
GROUP BY title
ORDER BY title;
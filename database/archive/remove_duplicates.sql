    -- Remove duplicate tiles
    -- =====================

    -- Show current duplicates
    SELECT 'DUPLICATE TILES' as status, title, tile_category, COUNT(*) as count
    FROM tiles 
    GROUP BY title, tile_category
    HAVING COUNT(*) > 1
    ORDER BY tile_category, title;

    -- Remove duplicates, keeping the oldest one (earliest created_at)
    DELETE FROM tiles a
    USING tiles b
    WHERE a.title = b.title 
    AND a.tile_category = b.tile_category
    AND a.created_at > b.created_at;

    -- Show final tile counts by category
    SELECT 
        'FINAL TILE COUNTS' as status,
        tile_category,
        COUNT(*) as count
    FROM tiles 
    WHERE is_active = true
    GROUP BY tile_category
    ORDER BY tile_category;

    -- Show total tiles
    SELECT 'TOTAL UNIQUE TILES' as status, COUNT(*) as count
    FROM tiles WHERE is_active = true;
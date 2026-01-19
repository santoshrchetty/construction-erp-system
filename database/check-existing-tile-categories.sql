-- Check if tile_categories table exists and its structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'tile_categories'
ORDER BY ordinal_position;

-- Check existing data in tile_categories
SELECT * FROM tile_categories ORDER BY category_order;

-- Check relationship with tiles table
SELECT 
    t.tile_category,
    tc.category_order,
    tc.icon,
    COUNT(*) as tile_count
FROM tiles t
LEFT JOIN tile_categories tc ON t.tile_category = tc.category_name
WHERE t.is_active = true
GROUP BY t.tile_category, tc.category_order, tc.icon
ORDER BY tc.category_order NULLS LAST, t.tile_category;

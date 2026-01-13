-- Comprehensive Tile Audit - Check all tiles and their implementation status
SELECT 
    category,
    name,
    auth_object,
    CASE 
        WHEN category = 'finance' AND name IN ('GL Account Posting', 'Trial Balance', 'Profit & Loss Statement', 'Chart of Accounts') THEN '✅ Domain Service'
        WHEN category = 'materials' AND name IN ('Create Material Master', 'Material Stock Overview') THEN '✅ Domain Service'
        WHEN category = 'inventory' AND name IN ('Goods Receipt', 'Goods Issue') THEN '✅ Domain Service'
        WHEN category = 'project management' AND name IN ('Create Project', 'Project Cost Analysis') THEN '✅ Domain Service'
        WHEN category = 'procurement' AND name IN ('Create Purchase Order') THEN '✅ Domain Service'
        ELSE '❌ Generic Handler Only'
    END as implementation_status
FROM tiles 
WHERE is_active = true
ORDER BY category, sequence_order;

-- Count by category and implementation status
SELECT 
    category,
    COUNT(*) as total_tiles,
    COUNT(CASE WHEN category IN ('finance', 'materials', 'inventory', 'project management', 'procurement') THEN 1 END) as with_domain_services,
    COUNT(CASE WHEN category NOT IN ('finance', 'materials', 'inventory', 'project management', 'procurement') THEN 1 END) as generic_only
FROM tiles 
WHERE is_active = true
GROUP BY category
ORDER BY category;
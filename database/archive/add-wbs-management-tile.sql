-- Add WBS Management tile to the system
INSERT INTO tiles (
    id,
    title,
    subtitle,
    icon,
    route,
    tile_category,
    module_code,
    construction_action,
    is_active,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'WBS Management',
    'Manage Work Breakdown Structure elements with project selection and financial data',
    'folder-open',
    '/wbs-management',
    'Project Management',
    'PS',
    'manage',
    true,
    NOW(),
    NOW()
);

-- Verify the tile was added
SELECT 
    title,
    subtitle,
    icon,
    route,
    tile_category,
    construction_action,
    is_active
FROM tiles 
WHERE title = 'WBS Management';
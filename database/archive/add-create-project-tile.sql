-- Add Create Project tile with numbering pattern integration
INSERT INTO tiles (
    title, 
    subtitle, 
    icon, 
    module_code, 
    construction_action, 
    route, 
    tile_category,
    has_authorization,
    auth_object,
    created_at
) VALUES (
    'Create Project',
    'Create new construction projects with auto-generated numbering',
    'plus-circle',
    'PS',
    'CREATE',
    '/projects/create',
    'Project Management',
    true,
    'PS_PROJECT_CREATE',
    NOW()
) ON CONFLICT (title) DO UPDATE SET
    subtitle = EXCLUDED.subtitle,
    icon = EXCLUDED.icon,
    module_code = EXCLUDED.module_code,
    construction_action = EXCLUDED.construction_action,
    route = EXCLUDED.route,
    tile_category = EXCLUDED.tile_category,
    has_authorization = EXCLUDED.has_authorization,
    auth_object = EXCLUDED.auth_object;

-- Also add Project Master tile for managing existing projects
INSERT INTO tiles (
    title, 
    subtitle, 
    icon, 
    module_code, 
    construction_action, 
    route, 
    tile_category,
    has_authorization,
    auth_object,
    created_at
) VALUES (
    'Project Master',
    'Manage and maintain existing construction projects',
    'edit',
    'PS',
    'MAINTAIN',
    '/projects/master',
    'Project Management',
    true,
    'PS_PROJECT_MAINTAIN',
    NOW()
) ON CONFLICT (title) DO UPDATE SET
    subtitle = EXCLUDED.subtitle,
    icon = EXCLUDED.icon,
    module_code = EXCLUDED.module_code,
    construction_action = EXCLUDED.construction_action,
    route = EXCLUDED.route,
    tile_category = EXCLUDED.tile_category,
    has_authorization = EXCLUDED.has_authorization,
    auth_object = EXCLUDED.auth_object;

-- Check if tiles were added successfully
SELECT title, subtitle, tile_category, has_authorization 
FROM tiles 
WHERE title IN ('Create Project', 'Project Master')
ORDER BY title;
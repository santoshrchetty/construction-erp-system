-- Insert Resource Planning Tile
INSERT INTO tiles (
    title,
    subtitle,
    icon,
    color,
    route,
    roles,
    sequence_order,
    is_active,
    module_code,
    tile_category
) VALUES (
    'Resource Planning',
    'Assign materials, equipment, and manpower to activities',
    'ClipboardList',
    'bg-purple-500',
    '/planning',
    ARRAY['Planning Manager', 'Project Manager', 'Site Engineer'],
    15,
    true,
    'PLANNING',
    'Project Management'
);

SELECT 'Resource Planning tile created' as status;

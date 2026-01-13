-- Material Reservations Tile Implementation
-- ==========================================

-- 1. Add authorization object
INSERT INTO authorization_objects (object_name, description, module) VALUES
('MM_MAT_RESERVE', 'Material Reservation Management', 'materials');

-- 2. Add authorization fields
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values) VALUES
((SELECT id FROM authorization_objects WHERE object_name = 'MM_MAT_RESERVE'), 'ACTION', 'Reservation Action', ARRAY['CREATE', 'MODIFY', 'APPROVE', 'CANCEL']),
((SELECT id FROM authorization_objects WHERE object_name = 'MM_MAT_RESERVE'), 'PROJ_TYPE', 'Project Type', ARRAY['commercial', 'residential', 'infrastructure']);

-- 3. Add role mappings
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) VALUES
('Admin', 'MM_MAT_RESERVE', '{"ACTION": ["CREATE", "MODIFY", "APPROVE", "CANCEL"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Manager', 'MM_MAT_RESERVE', '{"ACTION": ["CREATE", "MODIFY", "APPROVE"], "PROJ_TYPE": ["commercial", "residential"]}'),
('Engineer', 'MM_MAT_RESERVE', '{"ACTION": ["CREATE", "MODIFY"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Procurement', 'MM_MAT_RESERVE', '{"ACTION": ["CREATE", "MODIFY", "APPROVE"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}');

-- 4. Add tile
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Material Reservations', 'Reserve materials for projects', 'Package', 'bg-orange-500', '/materials/reservations', 'MM', 'Materials Management', 'RESERVE', 'MM_MAT_RESERVE', 25, true);

-- 5. Verify implementation
SELECT 'MATERIAL RESERVATIONS TILE ADDED' as status,
       COUNT(*) as total_tiles
FROM tiles 
WHERE title = 'Material Reservations';
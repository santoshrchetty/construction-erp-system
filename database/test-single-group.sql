-- Test inserting a single group
INSERT INTO material_groups (group_code, group_name, category_code, description, is_active)
VALUES ('BRICK-RED', 'Red Bricks', 'BRICK', 'Clay bricks', true)
ON CONFLICT (group_code) DO NOTHING;

-- Check if it worked
SELECT * FROM material_groups WHERE category_code = 'BRICK';

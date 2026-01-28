-- Assign remaining FINISHING materials to catch-all group
INSERT INTO material_groups (group_code, group_name, category_code, description, is_active)
VALUES ('FINISH-OTHER', 'Other Finishing', 'FINISHING', 'Other finishing materials', true)
ON CONFLICT (group_code) DO NOTHING;

UPDATE materials SET material_group = 'FINISH-OTHER'
WHERE category = 'FINISHING' AND material_group IS NULL;

-- Final verification - should return no rows
SELECT category, COUNT(*) as ungrouped_count
FROM materials
WHERE category IS NOT NULL AND material_group IS NULL
GROUP BY category;

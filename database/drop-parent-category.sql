-- =====================================================
-- DROP PARENT_CATEGORY COLUMN
-- Simplify material_categories to match ERP standards
-- =====================================================

-- Drop the foreign key constraint first
ALTER TABLE material_categories 
DROP CONSTRAINT IF EXISTS fk_material_categories_parent;

-- Drop the parent_category column
ALTER TABLE material_categories 
DROP COLUMN IF EXISTS parent_category;

-- Verify the change
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'material_categories' 
ORDER BY ordinal_position;

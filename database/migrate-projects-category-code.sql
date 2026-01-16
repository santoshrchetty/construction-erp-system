-- Add category_code column to projects table and populate with 'CUSTOMER'

ALTER TABLE projects ADD COLUMN IF NOT EXISTS category_code VARCHAR(20);

UPDATE projects 
SET category_code = 'CUSTOMER'
WHERE category_code IS NULL;

ALTER TABLE projects 
ALTER COLUMN category_code SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_projects_category_code ON projects(category_code);

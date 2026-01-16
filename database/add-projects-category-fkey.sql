-- Ensure project_categories has primary key, then add foreign key to projects

-- Ensure category_code is primary key in project_categories
ALTER TABLE project_categories DROP CONSTRAINT IF EXISTS project_categories_pkey;
ALTER TABLE project_categories ADD PRIMARY KEY (category_code);

-- Add foreign key constraint to projects table
ALTER TABLE projects 
ADD CONSTRAINT projects_category_code_fkey 
FOREIGN KEY (category_code) REFERENCES project_categories(category_code);

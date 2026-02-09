-- Recreate project categories table with clean structure
-- Drop existing tables and create a single unified project_categories table

-- Step 1: Drop foreign key constraint from projects table
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_category_code_fkey;
ALTER TABLE projects DROP CONSTRAINT IF EXISTS fk_projects_category_code;

-- Step 2: Drop existing tables
DROP TABLE IF EXISTS project_categories CASCADE;
DROP TABLE IF EXISTS project_categories_simple CASCADE;

-- Step 3: Create new unified project_categories table
CREATE TABLE project_categories (
    category_code VARCHAR(20) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 4: Insert standard SAP project categories
INSERT INTO project_categories (category_code, category_name, description, sort_order) VALUES
('INFRA', 'Infrastructure Project', 'Infrastructure development and construction projects', 10),
('EPC', 'Engineering, Procurement, Construction', 'Full-cycle EPC projects including design, procurement and construction', 20),
('IT', 'IT Implementation', 'IT implementation and software development projects', 30),
('MAINT', 'Maintenance Project', 'Maintenance and repair projects', 40),
('HR', 'Internal HR Project', 'Internal HR and organizational development projects', 50);

-- Step 5: Update existing projects to use valid category codes BEFORE adding constraint
UPDATE projects SET category_code = 'INFRA' WHERE category_code IS NULL OR category_code NOT IN ('INFRA', 'EPC', 'IT', 'MAINT', 'HR');

-- Step 6: Add foreign key constraint back to projects table
ALTER TABLE projects ADD CONSTRAINT fk_projects_category_code 
    FOREIGN KEY (category_code) REFERENCES project_categories(category_code);

-- Step 7: Verify the new structure
SELECT category_code, category_name, description, sort_order
FROM project_categories 
WHERE is_active = true
ORDER BY sort_order;
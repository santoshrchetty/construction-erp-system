-- Optional: Copy existing data from DEV to TEST database
-- Run this AFTER setup-test-database.sql if you want real data in TEST

-- Copy existing project categories (if they exist in your DEV database)
-- Replace with actual table names from your DEV database
/*
INSERT INTO project_categories (category, prefix, description)
SELECT category, prefix, description 
FROM your_dev_database.project_categories
ON CONFLICT DO NOTHING;

INSERT INTO project_types (type_code, type_name, category_code, description)
SELECT type_code, type_name, category_code, description
FROM your_dev_database.project_types
ON CONFLICT DO NOTHING;

INSERT INTO company_codes (company_code, company_name)
SELECT company_code, company_name
FROM your_dev_database.company_codes
ON CONFLICT (company_code) DO NOTHING;

INSERT INTO cost_centers (cost_center_code, cost_center_name, department, company_code)
SELECT cost_center_code, cost_center_name, department, company_code
FROM your_dev_database.cost_centers
ON CONFLICT DO NOTHING;

INSERT INTO profit_centers (profit_center_code, profit_center_name, division, company_code)
SELECT profit_center_code, profit_center_name, division, company_code
FROM your_dev_database.profit_centers
ON CONFLICT DO NOTHING;

INSERT INTO plants (plant_code, plant_name, location, company_code)
SELECT plant_code, plant_name, location, company_code
FROM your_dev_database.plants
ON CONFLICT DO NOTHING;

INSERT INTO persons_responsible (name, role, email, company_code)
SELECT name, role, email, company_code
FROM your_dev_database.persons_responsible
ON CONFLICT DO NOTHING;

INSERT INTO numbering_patterns (pattern, description, entity_type, company_code)
SELECT pattern, description, entity_type, company_code
FROM your_dev_database.numbering_patterns
ON CONFLICT DO NOTHING;
*/

-- Note: Uncomment and modify table names above to match your actual DEV database schema
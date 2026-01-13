-- Step 3: Check test data exists

-- Check if CUSTOMER category exists
SELECT * FROM project_categories WHERE category_code = 'CUSTOMER';

-- Check if HW pattern exists
SELECT * FROM project_numbering_rules WHERE pattern = 'HW-{####}' AND company_code = 'C001';

-- Check company C001 exists
SELECT * FROM company_codes WHERE company_code = 'C001';

-- Check organizational data exists
SELECT 'cost_centers' as table_name, count(*) as count FROM cost_centers WHERE company_code = 'C001'
UNION ALL
SELECT 'profit_centers', count(*) FROM profit_centers WHERE company_code = 'C001'
UNION ALL
SELECT 'plants', count(*) FROM plants WHERE company_code = 'C001';
-- Check all project-related tables structure and alignment

-- 1. Check project_categories table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'project_categories'
ORDER BY ordinal_position;

-- 2. Check project_gl_determination table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'project_gl_determination'
ORDER BY ordinal_position;

-- 3. Check if project_numbering_rules table exists
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'project_numbering_rules'
ORDER BY ordinal_position;

-- 4. Check if project_workflows table exists
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'project_workflows'
ORDER BY ordinal_position;

-- 5. Verify data in project_categories
SELECT 
    id,
    category_code,
    category_name,
    posting_logic,
    real_time_posting,
    is_active,
    company_code,
    sort_order
FROM project_categories 
WHERE company_code = 'C001'
ORDER BY sort_order;

-- 6. Verify data in project_gl_determination
SELECT 
    id,
    project_category,
    event_type,
    gl_account_type,
    debit_credit,
    posting_key,
    is_active
FROM project_gl_determination 
WHERE is_active = true
ORDER BY project_category;
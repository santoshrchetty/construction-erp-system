-- Check project categories data
SELECT 
    id,
    category_code,
    category_name,
    posting_logic,
    real_time_posting,
    is_active
FROM project_categories 
WHERE company_code = 'C001'
ORDER BY sort_order;
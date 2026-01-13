-- Test if project configuration data exists
SELECT 'Project Categories' as table_name, COUNT(*) as record_count FROM project_categories WHERE company_code = 'C001'
UNION ALL
SELECT 'GL Determination Rules', COUNT(*) FROM gl_determination_rules WHERE company_code = 'C001'
UNION ALL
SELECT 'Project Templates', COUNT(*) FROM project_category_templates
UNION ALL
SELECT 'Mobile UI Config', COUNT(*) FROM mobile_ui_config WHERE company_code = 'C001';

-- Show actual project categories data
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

-- Show GL determination rules
SELECT 
    id,
    rule_code,
    rule_name,
    project_category,
    event_type,
    gl_account_type,
    debit_credit,
    posting_key
FROM gl_determination_rules 
WHERE company_code = 'C001'
ORDER BY priority;
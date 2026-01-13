-- Check current database state
SELECT 'account_determination' as table_name, COUNT(*) as count FROM account_determination
UNION ALL
SELECT 'company_codes', COUNT(*) FROM company_codes
UNION ALL  
SELECT 'valuation_classes', COUNT(*) FROM valuation_classes
UNION ALL
SELECT 'account_keys', COUNT(*) FROM account_keys
UNION ALL
SELECT 'gl_accounts', COUNT(*) FROM gl_accounts;

-- If account_determination is empty, populate it
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, is_active)
SELECT 1, 1, 1, 1, true
WHERE NOT EXISTS (SELECT 1 FROM account_determination LIMIT 1);

-- Show final count
SELECT COUNT(*) as final_count FROM account_determination;
-- Check existing GL accounts
SELECT account_code, account_name, account_type FROM chart_of_accounts WHERE company_code = 'C001' ORDER BY account_code;

-- Update journal entries to use existing account codes
UPDATE journal_entries SET account_code = '110000' WHERE account_code IN ('400100', '450100', '600100', '650100', '800100');

-- Test trial balance with existing accounts
SELECT * FROM get_trial_balance('C001', NULL, CURRENT_DATE);
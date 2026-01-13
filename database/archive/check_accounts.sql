-- Check chart_of_accounts data
SELECT * FROM chart_of_accounts WHERE account_code IN ('110000', '400100', '600100', '650100', '800100', '450100') LIMIT 10;
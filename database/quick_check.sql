-- Quick status check
SELECT 'Material Types' as component, count(*) as count FROM material_types
UNION ALL
SELECT 'Valuation Classes', count(*) FROM valuation_classes  
UNION ALL
SELECT 'Movement Types', count(*) FROM movement_types
UNION ALL
SELECT 'Account Keys', count(*) FROM account_keys
UNION ALL
SELECT 'GL Accounts', count(*) FROM gl_accounts
UNION ALL
SELECT 'Account Determination', count(*) FROM account_determination;
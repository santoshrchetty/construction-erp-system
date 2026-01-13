-- Check posting dates in financial_documents
SELECT reference_document, posting_date FROM financial_documents ORDER BY posting_date;

-- Test trial balance with date filter (January only)
SELECT * FROM get_trial_balance('C001', '2024-01-01', '2024-01-31');

-- Test trial balance with date filter (February only)  
SELECT * FROM get_trial_balance('C001', '2024-02-01', '2024-02-28');
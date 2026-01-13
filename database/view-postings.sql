-- VIEW FINANCE ENGINE POSTINGS

-- 1. All Test Postings (Journal Entry Format)
SELECT 
    posting_date,
    source_document_id,
    event_type,
    gl_account,
    posting_key,
    debit_credit,
    company_amount,
    project_code,
    cost_center,
    profit_center,
    employee_id,
    customer_code,
    material_number
FROM universal_journal 
WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
ORDER BY source_document_id, debit_credit DESC;

-- 2. Traditional Journal Entry View (Side by Side)
WITH journal_entries AS (
    SELECT 
        source_document_id,
        event_type,
        posting_date,
        CASE WHEN debit_credit = 'D' THEN gl_account END as debit_account,
        CASE WHEN debit_credit = 'D' THEN company_amount END as debit_amount,
        CASE WHEN debit_credit = 'C' THEN gl_account END as credit_account,
        CASE WHEN debit_credit = 'C' THEN company_amount END as credit_amount,
        project_code
    FROM universal_journal 
    WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
)
SELECT 
    source_document_id,
    event_type,
    posting_date,
    STRING_AGG(debit_account || ' $' || debit_amount, ', ') FILTER (WHERE debit_account IS NOT NULL) as debits,
    STRING_AGG(credit_account || ' $' || credit_amount, ', ') FILTER (WHERE credit_account IS NOT NULL) as credits,
    project_code
FROM journal_entries
GROUP BY source_document_id, event_type, posting_date, project_code
ORDER BY source_document_id;

-- 3. Trial Balance View
SELECT * FROM get_trial_balance('C001', 'ACCRUAL', CURRENT_DATE)
WHERE gl_account IN ('130000', '140000', '210000', '400000', '510000', '520000')
ORDER BY gl_account;

-- 4. All Universal Journal Entries (Last 10)
SELECT 
    created_at,
    event_type,
    source_system,
    source_document_id,
    gl_account,
    debit_credit,
    company_amount,
    project_code
FROM universal_journal 
ORDER BY created_at DESC 
LIMIT 10;

-- 5. Summary by Event Type
SELECT 
    event_type,
    COUNT(*) as entry_count,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as total_debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as total_credits
FROM universal_journal 
GROUP BY event_type
ORDER BY event_type;
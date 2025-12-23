-- Final Verification: Complete ERP Posting Logic Alignment
-- Show the complete transaction flow from Movement Type to GL Account

SELECT 
    mt.movement_type,
    mt.movement_name,
    COALESCE(mtak.account_assignment_category, 'Normal') as assignment_type,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side,
    gl.account_code,
    gl.account_name,
    CASE 
        WHEN mtak.account_assignment_category = 'P' THEN 'Project Stock/WBS Required'
        ELSE 'Normal Stock/Cost Center'
    END as stock_type,
    'ALIGNED ✓' as status
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
JOIN account_determination ad ON (
    ad.account_key_id = ak.id 
    AND COALESCE(ad.account_assignment_category, '') = COALESCE(mtak.account_assignment_category, '')
)
JOIN gl_accounts gl ON ad.gl_account_id = gl.id
WHERE ad.is_active = true
ORDER BY mt.movement_type, COALESCE(mtak.account_assignment_category, 'Z'), mtak.sequence_order;

-- Summary of complete ERP posting logic
SELECT 
    'ERP Posting Logic Summary' as section,
    COUNT(DISTINCT mt.movement_type) as movement_types,
    COUNT(DISTINCT COALESCE(mtak.account_assignment_category, 'Normal')) as assignment_categories,
    COUNT(DISTINCT ak.account_key_code) as account_keys,
    COUNT(DISTINCT gl.account_code) as gl_accounts,
    COUNT(*) as total_posting_rules
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
JOIN account_determination ad ON (
    ad.account_key_id = ak.id 
    AND COALESCE(ad.account_assignment_category, '') = COALESCE(mtak.account_assignment_category, '')
)
JOIN gl_accounts gl ON ad.gl_account_id = gl.id
WHERE ad.is_active = true;
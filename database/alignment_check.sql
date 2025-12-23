-- Comprehensive Alignment Check for ERP Posting Logic
-- This script verifies all mappings are consistent

-- 1. Check Movement Type to Account Key Mappings
SELECT 
    'Movement Type Account Key Mappings' as check_type,
    mt.movement_type,
    mt.movement_name,
    COALESCE(mtak.account_assignment_category, 'Normal') as assignment_type,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side,
    mtak.sequence_order
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
ORDER BY mt.movement_type, COALESCE(mtak.account_assignment_category, 'Z'), mtak.sequence_order;

-- 2. Check Account Determination Mappings
SELECT 
    'Account Determination Mappings' as check_type,
    cc.company_code,
    vc.class_code as valuation_class,
    ak.account_key_code as account_key,
    COALESCE(ad.account_assignment_category, 'Normal') as assignment_type,
    gl.account_code as gl_account,
    gl.account_name
FROM account_determination ad
JOIN company_codes cc ON ad.company_code_id = cc.id
JOIN valuation_classes vc ON ad.valuation_class_id = vc.id  
JOIN account_keys ak ON ad.account_key_id = ak.id
JOIN gl_accounts gl ON ad.gl_account_id = gl.id
WHERE ad.is_active = true
ORDER BY vc.class_code, ak.account_key_code, COALESCE(ad.account_assignment_category, 'Z');

-- 3. Check for Missing Mappings (Account Keys used in Movement Types but not in Account Determination)
SELECT 
    'Missing Account Determination' as check_type,
    mt.movement_type,
    ak.account_key_code,
    COALESCE(mtak.account_assignment_category, 'Normal') as assignment_type,
    'Missing in Account Determination' as issue
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
WHERE NOT EXISTS (
    SELECT 1 FROM account_determination ad
    WHERE ad.account_key_id = ak.id 
      AND COALESCE(ad.account_assignment_category, '') = COALESCE(mtak.account_assignment_category, '')
);

-- 4. Complete Transaction Flow Test
SELECT 
    'Complete Transaction Flow' as check_type,
    mt.movement_type || COALESCE(' + ' || mtak.account_assignment_category, '') as transaction_type,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side,
    gl.account_code,
    gl.account_name,
    CASE 
        WHEN mtak.account_assignment_category = 'P' THEN 'Project Stock/WBS Required'
        ELSE 'Normal Stock/Cost Center'
    END as stock_type
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

-- 5. Summary Statistics
SELECT 
    'Summary Statistics' as check_type,
    COUNT(DISTINCT mt.movement_type) as movement_types_count,
    COUNT(DISTINCT ak.account_key_code) as account_keys_count,
    COUNT(DISTINCT COALESCE(mtak.account_assignment_category, 'Normal')) as assignment_categories_count,
    COUNT(*) as total_mappings
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id;
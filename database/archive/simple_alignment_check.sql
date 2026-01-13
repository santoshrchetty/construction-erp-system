-- Simple Alignment Check for Current Schema
-- Check what we have in each table

-- 1. Movement Type to Account Key Mappings
SELECT 
    'Movement Type Mappings' as section,
    mt.movement_type,
    mt.movement_name,
    COALESCE(mtak.account_assignment_category, 'Normal') as assignment_type,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
ORDER BY mt.movement_type, COALESCE(mtak.account_assignment_category, 'Z'), mtak.sequence_order;

-- 2. Current Account Determination (without assignment category)
SELECT 
    'Account Determination' as section,
    cc.company_code,
    vc.class_code as valuation_class,
    ak.account_key_code as account_key,
    gl.account_code as gl_account,
    gl.account_name
FROM account_determination ad
JOIN company_codes cc ON ad.company_code_id = cc.id
JOIN valuation_classes vc ON ad.valuation_class_id = vc.id  
JOIN account_keys ak ON ad.account_key_id = ak.id
JOIN gl_accounts gl ON ad.gl_account_id = gl.id
WHERE ad.is_active = true
ORDER BY vc.class_code, ak.account_key_code;

-- 3. Check if account_determination has assignment category column
SELECT 
    'Schema Check' as section,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'account_determination'
ORDER BY ordinal_position;

-- 4. Missing Account Determination for Project Assignments
SELECT 
    'Missing Project Mappings' as section,
    mt.movement_type,
    ak.account_key_code,
    'Project assignment needs account determination' as issue
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
WHERE mtak.account_assignment_category = 'P'
  AND NOT EXISTS (
    SELECT 1 FROM account_determination ad
    WHERE ad.account_key_id = ak.id
  );

-- 5. Summary of what we have
SELECT 
    'Summary' as section,
    'Movement Types' as item,
    COUNT(DISTINCT mt.movement_type) as count
FROM movement_types mt
UNION ALL
SELECT 'Summary', 'Account Keys', COUNT(*) FROM account_keys
UNION ALL  
SELECT 'Summary', 'Movement Type Mappings', COUNT(*) FROM movement_type_account_keys
UNION ALL
SELECT 'Summary', 'Account Determination Entries', COUNT(*) FROM account_determination
UNION ALL
SELECT 'Summary', 'Project Assignments', COUNT(*) FROM movement_type_account_keys WHERE account_assignment_category = 'P';
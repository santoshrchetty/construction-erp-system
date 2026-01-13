-- Add account key mappings for project movement types
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id, debit_credit_indicator, sequence_order)
SELECT 
    mt.id,
    ak.id,
    CASE 
        -- Q01: GR to Project Stock
        WHEN mt.movement_type = 'Q01' AND ak.account_key_code = 'BSX' THEN 'D'  -- Debit Project Stock
        WHEN mt.movement_type = 'Q01' AND ak.account_key_code = 'GBB' THEN 'C'  -- Credit GR/IR Clearing
        
        -- Q02: Issue from Project Stock  
        WHEN mt.movement_type = 'Q02' AND ak.account_key_code = 'WRX' THEN 'D'  -- Debit WBS Element
        WHEN mt.movement_type = 'Q02' AND ak.account_key_code = 'BSX' THEN 'C'  -- Credit Project Stock
        
        -- 411: Transfer to Project Stock
        WHEN mt.movement_type = '411' AND ak.account_key_code = 'BSX' THEN 'D'  -- Debit Project Stock
        WHEN mt.movement_type = '411' AND ak.account_key_code = 'BSX' THEN 'C'  -- Credit Unrestricted Stock
        
        -- 412: Transfer from Project Stock
        WHEN mt.movement_type = '412' AND ak.account_key_code = 'BSX' THEN 'D'  -- Debit Unrestricted Stock
        WHEN mt.movement_type = '412' AND ak.account_key_code = 'BSX' THEN 'C'  -- Credit Project Stock
        
        ELSE 'D'
    END,
    CASE 
        WHEN ak.account_key_code IN ('BSX', 'WRX') THEN 1
        WHEN ak.account_key_code = 'GBB' THEN 2
        ELSE 1
    END
FROM movement_types mt
CROSS JOIN account_keys ak
WHERE (
    (mt.movement_type = 'Q01' AND ak.account_key_code IN ('BSX', 'GBB')) OR
    (mt.movement_type = 'Q02' AND ak.account_key_code IN ('BSX', 'WRX')) OR
    (mt.movement_type IN ('411', '412') AND ak.account_key_code = 'BSX')
)
AND NOT EXISTS (
    SELECT 1 FROM movement_type_account_keys 
    WHERE movement_type_id = mt.id AND account_key_id = ak.id
);

-- Show all movement types with their account assignment categories
SELECT 
    mt.movement_type,
    mt.movement_name,
    mt.account_assignment_category,
    mt.wbs_mandatory,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side,
    CASE 
        WHEN mt.account_assignment_category = 'P' THEN 'WBS Element Required'
        WHEN mt.account_assignment_category = 'K' THEN 'Cost Center Required'
        ELSE 'No Assignment'
    END as assignment_requirement
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
ORDER BY mt.movement_type, mtak.sequence_order;
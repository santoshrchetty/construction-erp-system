-- Update movement_type_account_keys to include account assignment category
ALTER TABLE movement_type_account_keys ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);

-- Remove the separate project movement types we created earlier
DELETE FROM movement_type_account_keys WHERE movement_type_id IN (
    SELECT id FROM movement_types WHERE movement_type IN ('Q01', 'Q02', '411', '412')
);
DELETE FROM movement_types WHERE movement_type IN ('Q01', 'Q02', '411', '412');

-- Add account assignment category mappings for existing movement types
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id, debit_credit_indicator, sequence_order, account_assignment_category)
SELECT 
    mt.id,
    ak.id,
    CASE 
        -- 101 with 'P' (Project): GR to Project Stock
        WHEN mt.movement_type = '101' AND ak.account_key_code = 'BSX' THEN 'D'  -- Debit Project Stock
        WHEN mt.movement_type = '101' AND ak.account_key_code = 'GBB' THEN 'C'  -- Credit GR/IR Clearing
        
        -- 261 with 'P' (Project): Issue to WBS Element  
        WHEN mt.movement_type = '261' AND ak.account_key_code = 'WRX' THEN 'D'  -- Debit WBS Element
        WHEN mt.movement_type = '261' AND ak.account_key_code = 'BSX' THEN 'C'  -- Credit Project Stock
        
        ELSE 'D'
    END,
    CASE 
        WHEN ak.account_key_code IN ('BSX', 'WRX') THEN 1
        WHEN ak.account_key_code = 'GBB' THEN 2
        ELSE 1
    END,
    'P'  -- Project Account Assignment
FROM movement_types mt
CROSS JOIN account_keys ak
WHERE (
    (mt.movement_type = '101' AND ak.account_key_code IN ('BSX', 'GBB')) OR
    (mt.movement_type = '261' AND ak.account_key_code IN ('BSX', 'WRX'))
)
AND NOT EXISTS (
    SELECT 1 FROM movement_type_account_keys 
    WHERE movement_type_id = mt.id 
      AND account_key_id = ak.id 
      AND COALESCE(account_assignment_category, '') = 'P'
);

-- Show the complete mapping with account assignment categories
SELECT 
    mt.movement_type,
    mt.movement_name,
    COALESCE(mtak.account_assignment_category, 'None') as account_assignment,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side,
    CASE 
        WHEN mtak.account_assignment_category = 'P' THEN 'Project Stock / WBS Element'
        WHEN mtak.account_assignment_category IS NULL THEN 'Normal Stock / Cost Center'
        ELSE mtak.account_assignment_category
    END as stock_type
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
ORDER BY mt.movement_type, COALESCE(mtak.account_assignment_category, 'Z'), mtak.sequence_order;
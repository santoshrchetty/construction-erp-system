-- Add complete mappings for existing movement types and account keys
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id, debit_credit_indicator, sequence_order)
SELECT 
    mt.id,
    ak.id,
    CASE 
        WHEN ak.account_key_code = 'BSX' AND mt.movement_type IN ('101') THEN 'D'  -- Goods Receipt: Debit Inventory
        WHEN ak.account_key_code = 'GBB' AND mt.movement_type IN ('101') THEN 'C'  -- Goods Receipt: Credit GR/IR
        WHEN ak.account_key_code = 'WRX' AND mt.movement_type IN ('261', '201') THEN 'D'  -- Issue: Debit Consumption
        WHEN ak.account_key_code = 'BSX' AND mt.movement_type IN ('261', '201') THEN 'C'  -- Issue: Credit Inventory
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
    (mt.movement_type = '101' AND ak.account_key_code IN ('BSX', 'GBB')) OR
    (mt.movement_type IN ('261', '201') AND ak.account_key_code IN ('BSX', 'WRX'))
)
AND NOT EXISTS (
    SELECT 1 FROM movement_type_account_keys 
    WHERE movement_type_id = mt.id AND account_key_id = ak.id AND debit_credit_indicator = 
        CASE 
            WHEN ak.account_key_code = 'BSX' AND mt.movement_type IN ('101') THEN 'D'
            WHEN ak.account_key_code = 'GBB' AND mt.movement_type IN ('101') THEN 'C'
            WHEN ak.account_key_code = 'WRX' AND mt.movement_type IN ('261', '201') THEN 'D'
            WHEN ak.account_key_code = 'BSX' AND mt.movement_type IN ('261', '201') THEN 'C'
            ELSE 'D'
        END
);

-- Show the complete mapping
SELECT 
    mt.movement_type,
    mt.movement_name,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side,
    mtak.sequence_order
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
ORDER BY mt.movement_type, mtak.sequence_order;
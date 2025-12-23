-- Add the account assignment category column
ALTER TABLE movement_type_account_keys ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);

-- Drop the old unique constraint
ALTER TABLE movement_type_account_keys DROP CONSTRAINT IF EXISTS movement_type_account_keys_movement_type_id_account_key_id__key;

-- Add new unique constraint (simpler version)
ALTER TABLE movement_type_account_keys ADD CONSTRAINT movement_type_account_keys_unique 
UNIQUE(movement_type_id, account_key_id, debit_credit_indicator, account_assignment_category);

-- Insert project variants for movement types
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id, debit_credit_indicator, sequence_order, account_assignment_category)
SELECT 
    mt.id,
    ak.id,
    CASE 
        WHEN mt.movement_type = '101' AND ak.account_key_code = 'BSX' THEN 'D'
        WHEN mt.movement_type = '101' AND ak.account_key_code = 'GBB' THEN 'C'
        WHEN mt.movement_type = '261' AND ak.account_key_code = 'WRX' THEN 'D'
        WHEN mt.movement_type = '261' AND ak.account_key_code = 'BSX' THEN 'C'
        ELSE 'D'
    END,
    CASE 
        WHEN ak.account_key_code IN ('BSX', 'WRX') THEN 1
        WHEN ak.account_key_code = 'GBB' THEN 2
        ELSE 1
    END,
    'P'
FROM movement_types mt
CROSS JOIN account_keys ak
WHERE (
    (mt.movement_type = '101' AND ak.account_key_code IN ('BSX', 'GBB')) OR
    (mt.movement_type = '261' AND ak.account_key_code IN ('BSX', 'WRX'))
)
ON CONFLICT ON CONSTRAINT movement_type_account_keys_unique DO NOTHING;

-- Show results
SELECT 
    mt.movement_type,
    mt.movement_name,
    COALESCE(mtak.account_assignment_category, 'Normal') as assignment_type,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
ORDER BY mt.movement_type, COALESCE(mtak.account_assignment_category, 'Z'), mtak.sequence_order;
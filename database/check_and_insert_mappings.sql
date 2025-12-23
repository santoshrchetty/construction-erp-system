-- Check what movement types exist
SELECT movement_type, movement_name FROM movement_types ORDER BY movement_type;

-- Check what account keys exist  
SELECT account_key_code, account_key_name FROM account_keys ORDER BY account_key_code;

-- Insert only for existing movement types
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id, debit_credit_indicator, sequence_order)
SELECT 
    mt.id,
    ak.id,
    'D',
    1
FROM movement_types mt
CROSS JOIN account_keys ak
WHERE mt.movement_type IN ('101', '261', '201')
  AND ak.account_key_code = 'BSX'
  AND NOT EXISTS (
    SELECT 1 FROM movement_type_account_keys 
    WHERE movement_type_id = mt.id AND account_key_id = ak.id
  );

-- Show what was inserted
SELECT COUNT(*) as inserted_count FROM movement_type_account_keys;
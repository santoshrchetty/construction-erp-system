-- Clean up duplicate entries (keep only the correct ones)
DELETE FROM movement_type_account_keys 
WHERE id IN (
    SELECT id FROM (
        SELECT id, 
               ROW_NUMBER() OVER (
                   PARTITION BY movement_type_id, account_key_id, debit_credit_indicator 
                   ORDER BY created_at
               ) as rn
        FROM movement_type_account_keys
    ) t WHERE rn > 1
);

-- Update sequence orders to be correct
UPDATE movement_type_account_keys SET sequence_order = 2 
WHERE account_key_id IN (SELECT id FROM account_keys WHERE account_key_code = 'BSX')
  AND movement_type_id IN (SELECT id FROM movement_types WHERE movement_type IN ('261', '201'))
  AND debit_credit_indicator = 'C';

-- Show the final clean mapping
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
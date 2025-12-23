-- Step 2: Insert the mapping data
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id, debit_credit_indicator, sequence_order) VALUES
-- Movement Type 101 (Goods Receipt)
((SELECT id FROM movement_types WHERE movement_type = '101'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'D', 1),
((SELECT id FROM movement_types WHERE movement_type = '101'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'), 'C', 2),

-- Movement Type 261 (Issue to Project)
((SELECT id FROM movement_types WHERE movement_type = '261'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'), 'D', 1),
((SELECT id FROM movement_types WHERE movement_type = '261'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'C', 2),

-- Movement Type 201 (Issue to Cost Center)
((SELECT id FROM movement_types WHERE movement_type = '201'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'), 'D', 1),
((SELECT id FROM movement_types WHERE movement_type = '201'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'C', 2)

ON CONFLICT (movement_type_id, account_key_id, debit_credit_indicator) DO NOTHING;

-- Verify the data
SELECT 
    mt.movement_type,
    mt.movement_name,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as side
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
ORDER BY mt.movement_type, mtak.sequence_order;
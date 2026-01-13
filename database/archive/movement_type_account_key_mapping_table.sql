-- Add Movement Type Account Key Mapping Table
-- This table defines which account keys are used for each movement type

CREATE TABLE IF NOT EXISTS movement_type_account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type_id UUID NOT NULL REFERENCES movement_types(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    debit_credit_indicator VARCHAR(1) NOT NULL CHECK (debit_credit_indicator IN ('D', 'C')),
    sequence_order INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(movement_type_id, account_key_id, debit_credit_indicator)
);

-- Populate the mapping for standard movement types
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id, debit_credit_indicator, sequence_order) VALUES
-- Movement Type 101 (Goods Receipt)
((SELECT id FROM movement_types WHERE movement_type = '101'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'D', 1),  -- Debit Inventory
((SELECT id FROM movement_types WHERE movement_type = '101'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'), 'C', 2),  -- Credit GR/IR Clearing

-- Movement Type 102 (Goods Receipt Reversal)
((SELECT id FROM movement_types WHERE movement_type = '102'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'C', 1),  -- Credit Inventory
((SELECT id FROM movement_types WHERE movement_type = '102'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'), 'D', 2),  -- Debit GR/IR Clearing

-- Movement Type 261 (Issue to Project)
((SELECT id FROM movement_types WHERE movement_type = '261'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'), 'D', 1),  -- Debit Project Costs
((SELECT id FROM movement_types WHERE movement_type = '261'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'C', 2),  -- Credit Inventory

-- Movement Type 262 (Issue Reversal)
((SELECT id FROM movement_types WHERE movement_type = '262'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'), 'C', 1),  -- Credit Project Costs
((SELECT id FROM movement_types WHERE movement_type = '262'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'D', 2),  -- Debit Inventory

-- Movement Type 201 (Issue to Cost Center)
((SELECT id FROM movement_types WHERE movement_type = '201'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'), 'D', 1),  -- Debit Cost Center
((SELECT id FROM movement_types WHERE movement_type = '201'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'C', 2),  -- Credit Inventory

-- Movement Type 221 (Transfer Posting)
((SELECT id FROM movement_types WHERE movement_type = '221'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'D', 1),  -- Debit Receiving Location
((SELECT id FROM movement_types WHERE movement_type = '221'), 
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'), 'C', 2)   -- Credit Issuing Location

ON CONFLICT (movement_type_id, account_key_id, debit_credit_indicator) DO NOTHING;

-- View to show the complete posting logic
CREATE OR REPLACE VIEW posting_logic_view AS
SELECT 
    mt.movement_type,
    mt.movement_name,
    ak.account_key_code,
    ak.account_key_name,
    mtak.debit_credit_indicator,
    mtak.sequence_order,
    CASE mtak.debit_credit_indicator 
        WHEN 'D' THEN 'Debit' 
        WHEN 'C' THEN 'Credit' 
    END as posting_side
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
WHERE mtak.is_active = true
ORDER BY mt.movement_type, mtak.sequence_order;

-- Show the posting logic
SELECT * FROM posting_logic_view;
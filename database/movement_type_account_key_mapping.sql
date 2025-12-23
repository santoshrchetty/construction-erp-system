-- Movement Type to Account Key Mapping
-- This shows how business transactions trigger specific account keys

-- Movement Types and their Account Key assignments
SELECT 
    mt.movement_type,
    mt.movement_name,
    mt.movement_indicator,
    CASE 
        WHEN mt.movement_type = '101' THEN 'BSX + GBB'  -- Goods Receipt
        WHEN mt.movement_type = '102' THEN 'BSX + GBB'  -- Goods Receipt Reversal
        WHEN mt.movement_type = '261' THEN 'WRX + BSX'  -- Issue to Project
        WHEN mt.movement_type = '262' THEN 'WRX + BSX'  -- Issue Reversal
        WHEN mt.movement_type = '201' THEN 'WRX + BSX'  -- Issue to Cost Center
        WHEN mt.movement_type = '221' THEN 'BSX + BSX'  -- Transfer Posting
        ELSE 'Other'
    END as account_keys_used,
    CASE 
        WHEN mt.movement_type = '101' THEN 'Dr. Inventory (BSX), Cr. GR/IR Clearing (GBB)'
        WHEN mt.movement_type = '261' THEN 'Dr. Project Costs (WRX), Cr. Inventory (BSX)'
        WHEN mt.movement_type = '201' THEN 'Dr. Cost Center (WRX), Cr. Inventory (BSX)'
        ELSE 'See movement type documentation'
    END as journal_entry_pattern
FROM movement_types mt
ORDER BY mt.movement_type;

-- Example: When you post Movement Type 101 (Goods Receipt)
-- System automatically:
-- 1. Looks up material's valuation class (e.g., 3000 for raw materials)
-- 2. Uses BSX account key → finds GL account 140000 (Inventory)
-- 3. Uses GBB account key → finds GL account 160000 (GR/IR Clearing)
-- 4. Creates journal entry:
--    Dr. 140000 Raw Materials Inventory
--        Cr. 160000 GR/IR Clearing

-- The link is in the ERP business logic:
-- Movement Type → Account Keys → Account Determination → GL Accounts
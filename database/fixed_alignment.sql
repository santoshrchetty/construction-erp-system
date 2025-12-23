-- Complete the alignment by adding project-specific account determination
-- First, add the account assignment category column if missing
ALTER TABLE account_determination ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);

-- Add project-specific GL accounts
INSERT INTO gl_accounts (account_code, account_name, account_type, description) VALUES
('141000', 'Project Stock - Raw Materials', 'ASSET', 'Project-specific raw materials inventory'),
('151000', 'Project Stock - Equipment', 'ASSET', 'Project-specific equipment inventory'),
('501000', 'Project Material Consumption', 'EXPENSE', 'Direct material costs charged to projects')
ON CONFLICT (account_code) DO NOTHING;

-- Add project-specific account determination entries (avoid duplicates with WHERE NOT EXISTS)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, account_assignment_category, is_active)
SELECT 
    cc.id,
    vc.id,
    ak.id,
    gl.id,
    'P',
    true
FROM company_codes cc
CROSS JOIN valuation_classes vc
CROSS JOIN account_keys ak
CROSS JOIN gl_accounts gl
WHERE cc.company_code = '1000'
  AND (
    (vc.class_code = '3000' AND ak.account_key_code = 'BSX' AND gl.account_code = '141000') OR
    (vc.class_code = '7920' AND ak.account_key_code = 'BSX' AND gl.account_code = '151000') OR
    (vc.class_code = '3000' AND ak.account_key_code = 'WRX' AND gl.account_code = '501000') OR
    (vc.class_code = '7920' AND ak.account_key_code = 'WRX' AND gl.account_code = '501000') OR
    (vc.class_code IN ('3000', '7920') AND ak.account_key_code = 'GBB' AND gl.account_code = '160000')
  )
  AND NOT EXISTS (
    SELECT 1 FROM account_determination ad2 
    WHERE ad2.company_code_id = cc.id 
      AND ad2.valuation_class_id = vc.id 
      AND ad2.account_key_id = ak.id 
      AND ad2.account_assignment_category = 'P'
  );

-- Show count of new entries added
SELECT COUNT(*) as project_entries_added FROM account_determination WHERE account_assignment_category = 'P';

-- Verify alignment is now complete
SELECT 
    mt.movement_type,
    COALESCE(mtak.account_assignment_category, 'Normal') as assignment_type,
    ak.account_key_code,
    CASE mtak.debit_credit_indicator WHEN 'D' THEN 'Debit' WHEN 'C' THEN 'Credit' END as posting_side,
    gl.account_code,
    gl.account_name
FROM movement_type_account_keys mtak
JOIN movement_types mt ON mtak.movement_type_id = mt.id
JOIN account_keys ak ON mtak.account_key_id = ak.id
JOIN account_determination ad ON (
    ad.account_key_id = ak.id 
    AND COALESCE(ad.account_assignment_category, '') = COALESCE(mtak.account_assignment_category, '')
)
JOIN gl_accounts gl ON ad.gl_account_id = gl.id
WHERE ad.is_active = true
ORDER BY mt.movement_type, COALESCE(mtak.account_assignment_category, 'Z'), mtak.sequence_order;
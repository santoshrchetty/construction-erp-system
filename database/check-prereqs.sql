-- Check Prerequisites

-- 1. Project exists?
SELECT id, code FROM projects WHERE code = 'HW-0001';

-- 2. Activities exist?
SELECT id, code FROM activities WHERE code IN ('HW-0001.01-A01', 'HW-0001.01-A02');

-- 3. Company code exists?
SELECT company_code FROM company_codes WHERE company_code = '1000';

-- 4. Any universal journal entries at all?
SELECT COUNT(*) as total_entries FROM universal_journal;

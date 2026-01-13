-- Debug Trial Balance - Check table structure and data

-- 1. Check chart_of_accounts structure
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts' 
ORDER BY ordinal_position;

-- 2. Check journal_entries structure  
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'journal_entries' 
ORDER BY ordinal_position;

-- 3. Check if chart_of_accounts has data
SELECT 'Chart of Accounts:' as check, count(*) as count FROM chart_of_accounts;

-- 4. Check if journal_entries has data
SELECT 'Journal Entries:' as check, count(*) as count FROM journal_entries;

-- 5. Show sample chart_of_accounts data
SELECT * FROM chart_of_accounts LIMIT 5;

-- 6. Show sample journal_entries data
SELECT * FROM journal_entries LIMIT 5;
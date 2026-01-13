-- Quick check for posting key mapping table
SELECT 'Posting Key Mapping Table Status' as check_type,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'posting_key_mapping') 
            THEN 'EXISTS' 
            ELSE 'NOT FOUND' 
       END as table_status;

-- Count mappings by event type
SELECT event_type, COUNT(*) as mapping_count
FROM posting_key_mapping 
GROUP BY event_type
ORDER BY event_type;

-- Sample mapping lookup test
SELECT event_type, gl_account_type, debit_credit, posting_key, posting_key_description
FROM posting_key_mapping 
WHERE event_type = 'PROJECT_LABOR_COST'
ORDER BY debit_credit;
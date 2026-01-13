-- Check posting key mapping table for all events

-- 1. Show all event types and their mappings
SELECT 
    event_type,
    gl_account_type,
    debit_credit,
    posting_key,
    posting_key_description
FROM posting_key_mapping 
ORDER BY event_type, gl_account_type;

-- 2. Count mappings by event type
SELECT 
    event_type,
    COUNT(*) as mapping_count
FROM posting_key_mapping 
GROUP BY event_type
ORDER BY event_type;

-- 3. Show all unique event types supported
SELECT DISTINCT event_type 
FROM posting_key_mapping 
ORDER BY event_type;
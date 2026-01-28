-- Analyze existing Material Requests

-- 1. Check current MR numbers format
SELECT 
    request_number,
    created_at,
    status,
    CASE 
        WHEN request_number ~ '^MR-[0-9]+$' THEN 'Old Format (MR-timestamp)'
        WHEN request_number ~ '^MR[0-9]{10}$' THEN 'New Format (MR + 10 digits)'
        ELSE 'Other Format'
    END as format_type
FROM material_requests
ORDER BY created_at DESC
LIMIT 20;

-- 2. Count by format
SELECT 
    CASE 
        WHEN request_number ~ '^MR-[0-9]+$' THEN 'Old Format'
        WHEN request_number ~ '^MR[0-9]{10}$' THEN 'New Format'
        ELSE 'Other'
    END as format,
    COUNT(*) as count,
    MIN(created_at) as first_created,
    MAX(created_at) as last_created
FROM material_requests
GROUP BY format
ORDER BY count DESC;

-- 3. Check current number range status
SELECT 
    document_type,
    current_number,
    from_number,
    to_number,
    (to_number - CAST(current_number AS BIGINT)) as remaining_numbers
FROM document_number_ranges
WHERE document_type = 'MR';

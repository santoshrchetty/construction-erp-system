-- Development System: Renumber existing MRs to align with number range

-- Step 1: Backup current numbers (safety)
ALTER TABLE material_requests ADD COLUMN IF NOT EXISTS old_request_number VARCHAR(50);
UPDATE material_requests SET old_request_number = request_number WHERE old_request_number IS NULL;

-- Step 2: Renumber all MRs sequentially
WITH numbered_mrs AS (
    SELECT 
        id,
        'MR' || LPAD((5300000000 + ROW_NUMBER() OVER (ORDER BY created_at))::TEXT, 10, '0') as new_number
    FROM material_requests
)
UPDATE material_requests mr
SET request_number = nm.new_number
FROM numbered_mrs nm
WHERE mr.id = nm.id;

-- Step 3: Update number range current_number to last used
UPDATE document_number_ranges
SET current_number = (
    SELECT MAX(SUBSTRING(request_number FROM 3)::BIGINT)::TEXT
    FROM material_requests
    WHERE request_number ~ '^MR[0-9]{10}$'
)
WHERE document_type = 'MR';

-- Step 4: Verify
SELECT 
    COUNT(*) as total_mrs,
    MIN(request_number) as first_number,
    MAX(request_number) as last_number,
    COUNT(DISTINCT request_number) as unique_numbers
FROM material_requests;

-- Step 5: Check number range
SELECT 
    document_type,
    current_number,
    (to_number - CAST(current_number AS BIGINT)) as remaining_capacity
FROM document_number_ranges
WHERE document_type = 'MR';

-- Step 6: Sample records
SELECT 
    request_number,
    old_request_number,
    created_at,
    status
FROM material_requests
ORDER BY created_at
LIMIT 10;

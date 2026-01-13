-- CHECK FOR DUPLICATE APPROVAL TILES AND REMOVE DUPLICATES

-- Find duplicate approval tiles
SELECT 'DUPLICATE APPROVAL TILES:' as info;
SELECT title, route, COUNT(*) as duplicate_count
FROM tiles 
WHERE title ILIKE '%approval%' 
GROUP BY title, route
HAVING COUNT(*) > 1;

-- Show all approval tiles with IDs
SELECT 'ALL APPROVAL TILES WITH IDS:' as info;
SELECT id, title, route
FROM tiles 
WHERE title ILIKE '%approval%'
ORDER BY title, id;

-- Remove redundant approval tiles (keep only 6 essential)
DELETE FROM tiles WHERE id IN (
    '221c7945-409d-4591-92e7-d6e964294434', -- Approval Analytics
    '4c238583-4d78-4c44-a16a-3846c4a9b05c', -- Approval Audit Trail
    '3c580f53-0dcc-4074-84f0-1fe256a3d2a4', -- Approval Delegation
    '123a609a-bf1b-4547-a970-3af1730f3d8c', -- Approval Notifications
    'f8c0335f-14a3-443e-913e-288a26e4d060', -- Approval Override
    '6e065f28-1510-4ae6-a64c-67367f6ab2e6', -- Approval Performance
    '68d0a94c-da6e-497c-9a72-1cbdc585f713', -- Approval Role Management
    '1c0c6121-c06d-4a75-a67c-8f8a2819fdbc', -- Approval Templates
    '08d165bc-24e8-48c0-9d8e-b8c4f55fe6aa', -- Approval Thresholds
    '4fd2ab6e-6db3-4ed4-98a2-b2a9892aedef', -- Bulk Approvals
    '6b9acd9e-c809-4e60-aa93-09b5183e1ed6', -- Customer Approval Setup
    '14ddd9aa-1b4a-4a27-b73d-b938a9e45652', -- Emergency Approvals
    '0bd7e39f-1dd1-4c9b-9143-4de4f07fac3b', -- ERP Approval Sync
    '2c6e74ef-6935-40f0-9a0d-3d0ff43d36b7', -- Mobile Approval Setup
    'eef6ad5e-570c-4381-bc24-2d1afbb1fcb7', -- Pending Approvals (duplicate)
    '11834dc1-027b-4b59-8d5b-86c81e0bddcb', -- Procurement Approvals (duplicate)
    '2aaa0d27-92b8-4a3d-851c-3a23116d552c'  -- Vendor Approvals
);

-- Verify cleanup
SELECT 'REMAINING APPROVAL TILES:' as info;
SELECT id, title, route
FROM tiles 
WHERE title ILIKE '%approval%'
ORDER BY title;
-- Remove all document governance tiles except Document, Master Data, and Contracts for OMEGA-DEV tenant
DELETE FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND route LIKE '%document-governance%'
AND title NOT IN ('Find Document', 'Create Document', 'Change Document', 'Master Data Documents', 'Contract Management');

-- Verify remaining tiles
SELECT title, route 
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND route LIKE '%document-governance%'
ORDER BY title;

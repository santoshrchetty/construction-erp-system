-- Keep the older tile and delete the newer duplicate
DELETE FROM tiles 
WHERE id = 'e67500e9-5259-40cd-b50b-e2395e9ae24f';

-- Verify only the older Find Document tile remains
SELECT title, subtitle, route, created_at 
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND title = 'Find Document';
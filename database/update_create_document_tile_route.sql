UPDATE tiles 
SET route = '/document-governance/records/new' 
WHERE title = 'Create Document' 
AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

SELECT title, route FROM tiles WHERE title = 'Create Document';

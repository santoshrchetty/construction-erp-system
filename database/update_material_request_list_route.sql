-- Update Material Request List tile route
UPDATE tiles 
SET route = '/materials'
WHERE auth_object = 'MM_REQ_LIST';

-- Verify
SELECT title, route, auth_object 
FROM tiles 
WHERE auth_object = 'MM_REQ_LIST';

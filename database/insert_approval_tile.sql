-- INSERT APPROVAL CONFIGURATION TILE
-- Add the missing approval tile with minimal required fields

INSERT INTO tiles (title, route) 
VALUES ('Approval Configuration', '/approval-config')
ON CONFLICT (title) DO NOTHING;

SELECT 'Approval tile inserted' as result;
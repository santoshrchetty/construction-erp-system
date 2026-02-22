-- Delete the duplicate tile (keeping the one with module_code 'WF')
DELETE FROM tiles 
WHERE id = '0c1eaed5-b2ca-431f-ad9f-64fbdd388537';

-- Verify only one tile remains
SELECT id, title, subtitle, module_code, construction_action, route, tile_category, auth_object
FROM tiles 
WHERE title = 'My Pending Approvals';

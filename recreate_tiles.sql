-- Check if our tiles exist at all

-- 1. Check all DG tiles in the tenant
SELECT 'ALL DG TILES' as check_type, id, title, module_code, is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND (module_code LIKE 'DG%' OR tile_category = 'Document Governance')
ORDER BY title;

-- 2. Search for tiles with similar names
SELECT 'SIMILAR TILES' as check_type, id, title, module_code
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND (title ILIKE '%document%' OR title ILIKE '%find%' OR title ILIKE '%create%' OR title ILIKE '%change%')
ORDER BY title;

-- 3. Recreate the tiles (they must have been deleted somehow)
INSERT INTO tiles (tenant_id, title, subtitle, icon, color, route, module_code, tile_category, sequence_order, is_active)
VALUES
  -- Find Document
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 
   'Find Document', 
   'Search and view records', 
   'search', 
   'blue', 
   '/document-governance/records/list', 
   'DG-RECORDS', 
   'Document Governance', 
   1, 
   true),
  
  -- Create Document
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 
   'Create Document', 
   'Create new record', 
   'plus-circle', 
   'green', 
   '/document-governance/records/new', 
   'DG-RECORDS', 
   'Document Governance', 
   2, 
   true),
  
  -- Change Document
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 
   'Change Document', 
   'Modify existing record', 
   'edit', 
   'orange', 
   '/document-governance/records/change', 
   'DG-RECORDS', 
   'Document Governance', 
   3, 
   true);

-- 4. Verify they were created
SELECT 'RECREATED TILES' as check_type, id, title, module_code, is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY sequence_order;
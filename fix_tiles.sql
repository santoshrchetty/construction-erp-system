-- Quick fix: Ensure tiles are created
-- Run this to force create the tiles

-- Delete existing DG tiles first
DELETE FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG';

-- Insert tiles with simpler approach
INSERT INTO tiles (tenant_id, title, subtitle, icon, color, route, module_code, tile_category, sequence_order, is_active)
VALUES
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Find Document', 'Search records', 'search', 'blue', '/document-governance/records/list', 'DG', 'Document Governance', 1, true),
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Create Document', 'Create record', 'plus-circle', 'green', '/document-governance/records/new', 'DG', 'Document Governance', 2, true),
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Change Document', 'Modify record', 'edit', 'orange', '/document-governance/records/change', 'DG', 'Document Governance', 3, true);

-- Verify
SELECT title, route, is_active FROM tiles WHERE module_code = 'DG' AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
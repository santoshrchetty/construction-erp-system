-- Create Document Governance tiles for OMEGA-DEV
INSERT INTO tiles (tenant_id, title, subtitle, icon, color, route, auth_object, module_code, tile_category, sequence_order, is_active)
VALUES
  -- Contracts
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Contract Management', 'Manage construction contracts', 'FileText', 'blue', '/document-governance/contracts', 'Z_DG_CONTRACTS_DISPLAY', 'DG', 'Document Governance', 1, true),
  
  -- RFIs
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'RFI Management', 'Request for Information tracking', 'HelpCircle', 'orange', '/document-governance/rfis', 'Z_DG_RFIS_DISPLAY', 'DG', 'Document Governance', 2, true),
  
  -- Specifications
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Specifications', 'Technical specifications management', 'BookOpen', 'purple', '/document-governance/specifications', 'Z_DG_SPECS_DISPLAY', 'DG', 'Document Governance', 3, true),
  
  -- Submittals
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Submittals', 'Submittal tracking and approval', 'Upload', 'green', '/document-governance/submittals', 'Z_DG_SUBMITTALS_DISPLAY', 'DG', 'Document Governance', 4, true),
  
  -- Change Orders
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Change Orders', 'Change order management', 'Edit', 'red', '/document-governance/change-orders', 'Z_DG_CHANGE_ORDERS_DISPLAY', 'DG', 'Document Governance', 5, true),
  
  -- Master Documents
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'Master Documents', 'Master data document repository', 'Archive', 'indigo', '/document-governance/master-documents', 'Z_DG_ADMIN', 'DG', 'Document Governance', 6, true);

-- Verify
SELECT title, route, auth_object, is_active
FROM tiles
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
ORDER BY sequence_order;

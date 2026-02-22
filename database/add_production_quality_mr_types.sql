-- Add Production Order and Quality Order MR types
INSERT INTO mr_type_account_assignment_mapping (mr_type, account_assignment_code, is_default, is_allowed, display_order, tenant_id) VALUES
('PRODUCTION', 'OP', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
('PRODUCTION', 'CC', FALSE, TRUE, 2, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
('QUALITY', 'OQ', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
('QUALITY', 'CC', FALSE, TRUE, 2, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
ON CONFLICT (mr_type, account_assignment_code, tenant_id) DO UPDATE SET
  is_default = EXCLUDED.is_default,
  is_allowed = EXCLUDED.is_allowed,
  display_order = EXCLUDED.display_order;

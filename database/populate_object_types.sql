-- Populate approval_object_types master data
INSERT INTO approval_object_types (
    customer_id, object_type, object_category, object_name, description,
    default_strategy, required_fields, validation_rules, form_config
) VALUES
-- Financial Objects
('550e8400-e29b-41d4-a716-446655440001', 'PO', 'FINANCIAL', 'Purchase Order', 'Purchase orders for goods and services', 'AMOUNT_BASED',
 '["vendor_id", "amount", "currency", "plant_code"]', '{"min_amount": 0, "max_amount": 10000000}',
 '{"fields": [{"name": "vendor_id", "type": "select", "required": true}, {"name": "amount", "type": "number", "required": true}]}'),

('550e8400-e29b-41d4-a716-446655440001', 'MR', 'FINANCIAL', 'Material Request', 'Internal material requisitions', 'ROLE_BASED',
 '["material_code", "quantity", "plant_code", "cost_center"]', '{"max_quantity": 10000}',
 '{"fields": [{"name": "material_code", "type": "text", "required": true}, {"name": "quantity", "type": "number", "required": true}]}'),

('550e8400-e29b-41d4-a716-446655440001', 'INVOICE', 'FINANCIAL', 'Invoice Approval', 'Vendor invoice approvals', 'AMOUNT_BASED',
 '["vendor_id", "amount", "currency", "invoice_number"]', '{"min_amount": 0, "max_amount": 5000000}',
 '{"fields": [{"name": "invoice_number", "type": "text", "required": true}, {"name": "amount", "type": "number", "required": true}]}'),

-- Document Objects  
('550e8400-e29b-41d4-a716-446655440001', 'DRAWING', 'DOCUMENT', 'Technical Drawing', 'Engineering drawings and revisions', 'ROLE_BASED',
 '["document_number", "revision", "discipline", "project_code"]', '{"max_revision_level": 99}',
 '{"fields": [{"name": "document_number", "type": "text", "required": true}, {"name": "discipline", "type": "select", "options": ["STRUCTURAL", "MECHANICAL", "ELECTRICAL"]}]}'),

('550e8400-e29b-41d4-a716-446655440001', 'SPECIFICATION', 'DOCUMENT', 'Technical Specification', 'Technical specifications and standards', 'ROLE_BASED',
 '["spec_number", "version", "discipline"]', '{"version_format": "semantic"}',
 '{"fields": [{"name": "spec_number", "type": "text", "required": true}, {"name": "discipline", "type": "select"}]}'),

-- Storage Objects
('550e8400-e29b-41d4-a716-446655440001', 'STORAGE', 'STORAGE', 'Storage Assignment', 'Material storage location assignments', 'ROLE_BASED',
 '["material_code", "storage_location", "storage_type"]', '{"valid_storage_types": ["STANDARD", "HAZMAT", "SECURE", "CLIMATE_CONTROLLED"]}',
 '{"fields": [{"name": "storage_location", "type": "select", "required": true}, {"name": "storage_type", "type": "select", "required": true}]}'),

-- Travel Objects
('550e8400-e29b-41d4-a716-446655440001', 'TRAVEL', 'TRAVEL', 'Travel Request', 'Business travel requests and expenses', 'AMOUNT_BASED',
 '["destination", "start_date", "end_date", "estimated_cost"]', '{"max_trip_duration": 30, "advance_booking_days": 7}',
 '{"fields": [{"name": "destination", "type": "text", "required": true}, {"name": "estimated_cost", "type": "number", "required": true}]}'),

-- HR Objects
('550e8400-e29b-41d4-a716-446655440001', 'LEAVE', 'HR', 'Leave Request', 'Employee leave and time-off requests', 'ROLE_BASED',
 '["leave_type", "start_date", "end_date", "days_requested"]', '{"max_consecutive_days": 30, "min_notice_days": 2}',
 '{"fields": [{"name": "leave_type", "type": "select", "options": ["ANNUAL", "SICK", "PERSONAL"]}, {"name": "days_requested", "type": "number", "required": true}]}');

-- Update existing policies with object categories
UPDATE approval_policies 
SET object_category = 'FINANCIAL',
    object_subtype = CASE 
        WHEN approval_object_type = 'PO' THEN 'PROCUREMENT'
        WHEN approval_object_type = 'MR' THEN 'MATERIAL_REQUEST'
        WHEN approval_object_type = 'CLAIM' THEN 'CLAIMS'
        ELSE 'STANDARD'
    END
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND object_category IS NULL;

-- Verify object types and updated policies
SELECT 
    aot.object_category,
    aot.object_type,
    aot.object_name,
    COUNT(ap.id) as policy_count
FROM approval_object_types aot
LEFT JOIN approval_policies ap ON aot.object_type = ap.approval_object_type
WHERE aot.customer_id = '550e8400-e29b-41d4-a716-446655440001'
GROUP BY aot.object_category, aot.object_type, aot.object_name
ORDER BY aot.object_category, aot.object_type;
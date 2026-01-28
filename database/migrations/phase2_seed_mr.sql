-- ========================================
-- PHASE 2: SEED DATA - MATERIAL REQUEST (MR)
-- Minimum Viable Product
-- ========================================

-- Step 1: Insert MR document type configuration
INSERT INTO document_type_config (company_code, base_document_type, subtype_code, subtype_name, description, sap_document_type, number_range_group, format_template, number_length, expected_volume, is_active, display_order)
SELECT 'C001', 'MR', '01', 'Standard', 'Regular material requests', 'BANF', '01', 'MR-01-{year:02d}-{number:06d}', 6, 'LOW', true, 1
WHERE NOT EXISTS (SELECT 1 FROM document_type_config WHERE company_code = 'C001' AND base_document_type = 'MR' AND subtype_code = '01')
UNION ALL
SELECT 'C001', 'MR', '02', 'Emergency', 'Urgent material requests', 'BANF', '02', 'MR-02-{year:02d}-{number:06d}', 6, 'LOW', true, 2
WHERE NOT EXISTS (SELECT 1 FROM document_type_config WHERE company_code = 'C001' AND base_document_type = 'MR' AND subtype_code = '02')
UNION ALL
SELECT 'C001', 'MR', '03', 'Stock Transfer', 'Inter-site material transfers', 'BANF', '03', 'MR-03-{year:02d}-{number:06d}', 6, 'LOW', true, 3
WHERE NOT EXISTS (SELECT 1 FROM document_type_config WHERE company_code = 'C001' AND base_document_type = 'MR' AND subtype_code = '03')
UNION ALL
SELECT 'C001', 'MR', '04', 'Subcontractor', 'Subcontractor material requests', 'BANF', '04', 'MR-04-{year:02d}-{number:06d}', 6, 'LOW', true, 4
WHERE NOT EXISTS (SELECT 1 FROM document_type_config WHERE company_code = 'C001' AND base_document_type = 'MR' AND subtype_code = '04')
UNION ALL
SELECT 'C001', 'MR', '05', 'Project', 'Project-specific material requests', 'BANF', '05', 'MR-05-{year:02d}-{number:06d}', 6, 'LOW', true, 5
WHERE NOT EXISTS (SELECT 1 FROM document_type_config WHERE company_code = 'C001' AND base_document_type = 'MR' AND subtype_code = '05')
UNION ALL
SELECT 'C001', 'MR', '06', 'Maintenance', 'Maintenance material requests', 'BANF', '06', 'MR-06-{year:02d}-{number:06d}', 6, 'LOW', true, 6
WHERE NOT EXISTS (SELECT 1 FROM document_type_config WHERE company_code = 'C001' AND base_document_type = 'MR' AND subtype_code = '06');

-- Step 2: Insert SAP mappings for MR
INSERT INTO sap_document_type_mapping (our_doc_type, our_subtype, sap_doc_type, sap_movement_type, sap_blart, description)
SELECT 'MR', '01', 'BANF', 'NB', NULL, 'Standard Material Request'
WHERE NOT EXISTS (SELECT 1 FROM sap_document_type_mapping WHERE our_doc_type = 'MR' AND our_subtype = '01')
UNION ALL
SELECT 'MR', '02', 'BANF', 'EM', NULL, 'Emergency Material Request'
WHERE NOT EXISTS (SELECT 1 FROM sap_document_type_mapping WHERE our_doc_type = 'MR' AND our_subtype = '02')
UNION ALL
SELECT 'MR', '03', 'BANF', 'ST', NULL, 'Stock Transfer Request'
WHERE NOT EXISTS (SELECT 1 FROM sap_document_type_mapping WHERE our_doc_type = 'MR' AND our_subtype = '03')
UNION ALL
SELECT 'MR', '04', 'BANF', 'SC', NULL, 'Subcontractor Request'
WHERE NOT EXISTS (SELECT 1 FROM sap_document_type_mapping WHERE our_doc_type = 'MR' AND our_subtype = '04')
UNION ALL
SELECT 'MR', '05', 'BANF', 'PR', NULL, 'Project Request'
WHERE NOT EXISTS (SELECT 1 FROM sap_document_type_mapping WHERE our_doc_type = 'MR' AND our_subtype = '05')
UNION ALL
SELECT 'MR', '06', 'BANF', 'MT', NULL, 'Maintenance Request'
WHERE NOT EXISTS (SELECT 1 FROM sap_document_type_mapping WHERE our_doc_type = 'MR' AND our_subtype = '06');

-- Step 3: Update existing MR number range
UPDATE document_number_ranges 
SET prefix = 'MR-01-24-',
    number_range_group = '01',
    auto_extend = true,
    extend_by = 1000000,
    to_number = 999999
WHERE company_code = 'C001' 
  AND document_type = 'MR'
  AND fiscal_year = 2024;

-- Step 4: Skip additional number ranges - using existing MR range for all subtypes
-- The existing MR number range will be used for all subtypes

-- Step 5: Verify configuration
SELECT 'Phase 2: MR Configuration Complete!' as status;

SELECT 'Document Types:' as info, COUNT(*) as count FROM document_type_config WHERE company_code = 'C001' AND base_document_type = 'MR';
SELECT 'Number Ranges:' as info, COUNT(*) as count FROM document_number_ranges WHERE company_code = 'C001' AND document_type = 'MR';
SELECT 'SAP Mappings:' as info, COUNT(*) as count FROM sap_document_type_mapping WHERE our_doc_type = 'MR';
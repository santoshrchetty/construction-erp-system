-- SAP-STYLE CONFIGURABLE PO DOCUMENT TYPES

-- Enhanced PO document types (SAP equivalent)
CREATE TABLE IF NOT EXISTS po_document_types (
    document_type VARCHAR(4) PRIMARY KEY, -- SAP standard 4-char
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    company_code VARCHAR(4) DEFAULT 'C001',
    
    -- SAP-style configuration fields
    number_range_object VARCHAR(10) DEFAULT 'PO_NUMBER',
    external_number_assignment BOOLEAN DEFAULT false,
    internal_number_assignment BOOLEAN DEFAULT true,
    
    -- Approval configuration
    approval_required BOOLEAN DEFAULT true,
    release_strategy VARCHAR(10), -- Links to release strategy
    auto_approve_limit DECIMAL(15,2) DEFAULT 0,
    
    -- Document behavior
    goods_receipt_required BOOLEAN DEFAULT true,
    invoice_receipt_required BOOLEAN DEFAULT true,
    three_way_match_required BOOLEAN DEFAULT true,
    
    -- Workflow settings
    workflow_template VARCHAR(20),
    notification_required BOOLEAN DEFAULT false,
    email_notifications JSONB DEFAULT '{}',
    
    -- Field controls (SAP-style)
    field_selection JSONB DEFAULT '{}', -- Which fields are mandatory/optional/hidden
    default_values JSONB DEFAULT '{}', -- Default field values
    
    -- Integration settings
    sap_integration_enabled BOOLEAN DEFAULT false,
    external_system_mapping JSONB DEFAULT '{}',
    
    -- Validity and status
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(50)
);

-- Insert SAP-equivalent PO document types
INSERT INTO po_document_types (
    document_type, type_name, description, approval_required, 
    auto_approve_limit, goods_receipt_required, workflow_template,
    field_selection, default_values
) VALUES
-- Standard PO (like SAP NB)
('NB', 'Standard Purchase Order', 'Standard procurement document', true, 0, true, 'STANDARD_PO',
 '{"vendor_code": "mandatory", "delivery_date": "mandatory", "payment_terms": "optional"}',
 '{"currency": "USD", "payment_terms": "NET30", "incoterms": "FOB"}'),

-- Emergency PO (like SAP EM) 
('EM', 'Emergency Purchase Order', 'Urgent procurement with post-approval', false, 999999999, true, 'EMERGENCY_PO',
 '{"justification": "mandatory", "emergency_contact": "mandatory", "expected_delivery": "mandatory"}',
 '{"priority": "HIGH", "notification_required": true}'),

-- Blanket PO (like SAP BL)
('BL', 'Blanket Purchase Order', 'Framework agreement PO', true, 0, false, 'BLANKET_PO',
 '{"validity_period": "mandatory", "release_strategy": "mandatory", "framework_agreement": "mandatory"}',
 '{"validity_months": 12, "auto_release": false}'),

-- Service PO (like SAP SV)
('SV', 'Service Purchase Order', 'Service procurement document', true, 0, false, 'SERVICE_PO',
 '{"service_specification": "mandatory", "performance_period": "mandatory", "acceptance_criteria": "optional"}',
 '{"goods_receipt_required": false, "service_entry_required": true}'),

-- Subcontracting PO (like SAP SC)
('SC', 'Subcontracting PO', 'Subcontracting with material provision', true, 0, true, 'SUBCON_PO',
 '{"components_list": "mandatory", "subcontractor_plant": "mandatory", "return_delivery": "optional"}',
 '{"component_tracking": true, "return_required": true}'),

-- Internal PO (Custom)
('IN', 'Internal Transfer Order', 'Inter-company/plant transfers', false, 999999999, true, 'INTERNAL_PO',
 '{"receiving_plant": "mandatory", "transfer_reason": "mandatory", "cost_center": "optional"}',
 '{"approval_required": false, "auto_approve": true}'),

-- Maintenance PO (Custom)
('MN', 'Maintenance Purchase Order', 'Maintenance and repair orders', true, 5000, true, 'MAINTENANCE_PO',
 '{"equipment_number": "mandatory", "maintenance_type": "mandatory", "urgency": "mandatory"}',
 '{"auto_approve_below": 5000, "priority_routing": true}');

-- PO type configuration functions (SAP-style)
CREATE OR REPLACE FUNCTION configure_po_document_type(
    p_document_type VARCHAR(4),
    p_type_name VARCHAR(50),
    p_approval_required BOOLEAN DEFAULT true,
    p_auto_approve_limit DECIMAL(15,2) DEFAULT 0,
    p_field_selection JSONB DEFAULT '{}',
    p_default_values JSONB DEFAULT '{}'
) RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO po_document_types (
        document_type, type_name, approval_required, auto_approve_limit,
        field_selection, default_values, created_by
    ) VALUES (
        p_document_type, p_type_name, p_approval_required, p_auto_approve_limit,
        p_field_selection, p_default_values, 'CONSULTANT'
    )
    ON CONFLICT (document_type) 
    DO UPDATE SET
        type_name = EXCLUDED.type_name,
        approval_required = EXCLUDED.approval_required,
        auto_approve_limit = EXCLUDED.auto_approve_limit,
        field_selection = EXCLUDED.field_selection,
        default_values = EXCLUDED.default_values;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to get active PO document types for dropdown
CREATE OR REPLACE FUNCTION get_active_po_document_types(p_company_code VARCHAR(4) DEFAULT 'C001')
RETURNS TABLE (
    document_type VARCHAR(4),
    type_name VARCHAR(50),
    description TEXT,
    approval_required BOOLEAN,
    auto_approve_limit DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pdt.document_type,
        pdt.type_name,
        pdt.description,
        pdt.approval_required,
        pdt.auto_approve_limit
    FROM po_document_types pdt
    WHERE pdt.company_code = p_company_code
      AND pdt.is_active = true
      AND CURRENT_DATE BETWEEN pdt.valid_from AND pdt.valid_to
    ORDER BY pdt.document_type;
END;
$$ LANGUAGE plpgsql;

-- View for consultant configuration
CREATE OR REPLACE VIEW v_po_document_type_config AS
SELECT 
    document_type,
    type_name,
    description,
    approval_required,
    auto_approve_limit,
    goods_receipt_required,
    invoice_receipt_required,
    workflow_template,
    field_selection,
    default_values,
    is_active
FROM po_document_types
ORDER BY document_type;

SELECT 'SAP-STYLE CONFIGURABLE PO DOCUMENT TYPES CREATED' as status;
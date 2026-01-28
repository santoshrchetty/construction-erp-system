-- ========================================
-- STEP 1: CORE INFRASTRUCTURE
-- Document Numbering System Implementation
-- ========================================

-- Create document_type_config table
CREATE TABLE IF NOT EXISTS document_type_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(31) NOT NULL,
    base_document_type VARCHAR(10) NOT NULL,
    subtype_code VARCHAR(2) NOT NULL,
    subtype_name VARCHAR(100) NOT NULL,
    description TEXT,
    sap_document_type VARCHAR(10),
    number_range_group VARCHAR(10) NOT NULL,
    format_template VARCHAR(100) NOT NULL,
    number_length INTEGER DEFAULT 6,
    expected_volume VARCHAR(10) DEFAULT 'LOW',
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(company_code, base_document_type, subtype_code)
);

-- Create SAP mapping table
CREATE TABLE IF NOT EXISTS sap_document_type_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    our_doc_type VARCHAR(10) NOT NULL,
    our_subtype VARCHAR(2) NOT NULL,
    sap_doc_type VARCHAR(10),
    sap_movement_type VARCHAR(3),
    sap_blart VARCHAR(10),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(our_doc_type, our_subtype)
);

-- Update document_number_ranges table
ALTER TABLE document_number_ranges 
ADD COLUMN IF NOT EXISTS auto_extend BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS extend_by BIGINT DEFAULT 1000000,
ADD COLUMN IF NOT EXISTS last_used_date TIMESTAMP;

-- Create audit log table
CREATE TABLE IF NOT EXISTS number_range_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(31) NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    number_range_group VARCHAR(10),
    action VARCHAR(50) NOT NULL,
    old_value BIGINT,
    new_value BIGINT,
    old_to_number BIGINT,
    new_to_number BIGINT,
    extended_by BIGINT,
    user_id UUID,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_doc_type_config_lookup 
ON document_type_config(company_code, base_document_type, subtype_code) 
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_num_range_lookup 
ON document_number_ranges(company_code, document_type, number_range_group, fiscal_year) 
WHERE status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS idx_audit_log_company_type 
ON number_range_audit_log(company_code, document_type, timestamp DESC);

SELECT 'Step 1: Core Infrastructure Created!' as status;

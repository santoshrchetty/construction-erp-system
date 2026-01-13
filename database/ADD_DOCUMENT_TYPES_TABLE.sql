-- Add Document Types Table for Dynamic Document Type Loading
-- This supports the fix for hardcoded document type mapping

-- Create document types table
CREATE TABLE IF NOT EXISTS approval_document_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    object_type VARCHAR(20) NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    document_label VARCHAR(100) NOT NULL,
    document_description VARCHAR(500),
    display_order INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(customer_id, object_type, document_type)
);

-- Insert sample document types for the customer
INSERT INTO approval_document_types (customer_id, object_type, document_type, document_label, document_description, display_order) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'MR', 'NB', 'Normal Business', 'Standard material requests', 1),
('550e8400-e29b-41d4-a716-446655440001', 'MR', 'EM', 'Emergency', 'Urgent material needs', 2),
('550e8400-e29b-41d4-a716-446655440001', 'MR', 'SP', 'Special Project', 'Project-specific materials', 3),
('550e8400-e29b-41d4-a716-446655440001', 'PR', 'NB', 'Normal Business', 'Standard purchase requisitions', 1),
('550e8400-e29b-41d4-a716-446655440001', 'PR', 'EM', 'Emergency', 'Urgent procurement needs', 2),
('550e8400-e29b-41d4-a716-446655440001', 'PR', 'CR', 'Critical', 'Critical infrastructure items', 3),
('550e8400-e29b-41d4-a716-446655440001', 'PO', 'NB', 'Normal Business', 'Standard purchase orders', 1),
('550e8400-e29b-41d4-a716-446655440001', 'PO', 'EM', 'Emergency', 'Emergency procurement', 2),
('550e8400-e29b-41d4-a716-446655440001', 'PO', 'CR', 'Critical', 'Critical vendor orders', 3),
('550e8400-e29b-41d4-a716-446655440001', 'PO', 'SP', 'Special', 'Special terms/conditions', 4),
('550e8400-e29b-41d4-a716-446655440001', 'CLAIM', 'EM', 'Emergency', 'Emergency claims processing', 1),
('550e8400-e29b-41d4-a716-446655440001', 'CLAIM', 'CR', 'Critical', 'Critical safety/quality claims', 2),
('550e8400-e29b-41d4-a716-446655440001', 'CLAIM', 'SP', 'Special', 'Insurance/warranty claims', 3)
ON CONFLICT (customer_id, object_type, document_type) DO NOTHING;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_document_types_customer_object 
ON approval_document_types (customer_id, object_type, is_active) WHERE is_active = true;

SELECT 'Document types table created and populated' as status;
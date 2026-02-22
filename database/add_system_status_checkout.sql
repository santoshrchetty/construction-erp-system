-- Add system status and check-in/check-out fields to documents table

ALTER TABLE documents ADD COLUMN IF NOT EXISTS system_status VARCHAR(50) DEFAULT 'CHKI';
ALTER TABLE documents ADD COLUMN IF NOT EXISTS checked_out_by UUID;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS checked_out_at TIMESTAMP;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS checked_in_at TIMESTAMP;

-- Create index for check-out queries
CREATE INDEX IF NOT EXISTS idx_documents_checked_out ON documents(checked_out_by) WHERE checked_out_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_documents_system_status ON documents(system_status);

COMMENT ON COLUMN documents.system_status IS 'System-controlled status: CHKI (Checked In), CHKO (Checked Out), RLSD (Released), LKSD (Locked), OBSLT (Obsolete)';
COMMENT ON COLUMN documents.checked_out_by IS 'User who has checked out the document for editing';
COMMENT ON COLUMN documents.checked_out_at IS 'When the document was checked out';
COMMENT ON COLUMN documents.checked_in_at IS 'When the document was last checked in';

-- System Status values:
-- CHKI = Checked In (available for checkout)
-- CHKO = Checked Out (locked for editing by user)
-- RLSD = Released (approved and active)
-- LKSD = Locked (cannot be edited)
-- OBSLT = Obsolete (superseded)

-- Migration: Add SAP-aligned fields to number ranges
-- Date: 2024
-- Purpose: Align number range schema with SAP S/4HANA TNRO/NRIV tables

-- Add missing columns to document_number_ranges
ALTER TABLE document_number_ranges 
ADD COLUMN IF NOT EXISTS description VARCHAR(500),
ADD COLUMN IF NOT EXISTS fiscal_year VARCHAR(4),
ADD COLUMN IF NOT EXISTS range_number VARCHAR(2) DEFAULT '01',
ADD COLUMN IF NOT EXISTS is_external BOOLEAN DEFAULT false;

-- Add index for fiscal year queries
CREATE INDEX IF NOT EXISTS idx_document_number_ranges_fiscal_year 
ON document_number_ranges(company_code, document_type, fiscal_year);

-- Add index for range number
CREATE INDEX IF NOT EXISTS idx_document_number_ranges_range 
ON document_number_ranges(company_code, document_type, range_number);

-- Update existing records with default description
UPDATE document_number_ranges 
SET description = document_type || ' Number Range for ' || company_code
WHERE description IS NULL;

-- Add comment to table
COMMENT ON TABLE document_number_ranges IS 'Number range configuration - Maps to SAP TNRO (objects) and NRIV (intervals)';
COMMENT ON COLUMN document_number_ranges.description IS 'Number range description (from TNRO-TXT)';
COMMENT ON COLUMN document_number_ranges.fiscal_year IS 'Fiscal year subobject (from NRIV-SUBOBJECT)';
COMMENT ON COLUMN document_number_ranges.range_number IS 'Range identifier 01-99 (from NRIV-NRRANGENR)';
COMMENT ON COLUMN document_number_ranges.is_external IS 'External numbering flag (from NRIV-EXTERNIND)';
COMMENT ON COLUMN document_number_ranges.document_type IS 'Number range object (from TNRO-OBJECT)';
COMMENT ON COLUMN document_number_ranges.from_number IS 'Range start (from NRIV-FROMNUMBER)';
COMMENT ON COLUMN document_number_ranges.to_number IS 'Range end (from NRIV-TONUMBER)';
COMMENT ON COLUMN document_number_ranges.current_number IS 'Last used number (from NRIV-NRLEVEL)';

-- Verify migration
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'document_number_ranges'
ORDER BY ordinal_position;

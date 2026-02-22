-- Add updated_by and updated_at columns to material_requests table
ALTER TABLE material_requests
ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

-- Create or replace trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_material_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop and recreate trigger
DROP TRIGGER IF EXISTS trigger_update_material_requests_updated_at ON material_requests;
CREATE TRIGGER trigger_update_material_requests_updated_at
    BEFORE UPDATE ON material_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_material_requests_updated_at();

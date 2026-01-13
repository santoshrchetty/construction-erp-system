-- Check if table exists and its structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'movement_type_account_keys';

-- Drop and recreate the table
DROP TABLE IF EXISTS movement_type_account_keys CASCADE;

-- Create the table with correct structure
CREATE TABLE movement_type_account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type_id UUID NOT NULL REFERENCES movement_types(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    debit_credit_indicator VARCHAR(1) NOT NULL CHECK (debit_credit_indicator IN ('D', 'C')),
    sequence_order INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(movement_type_id, account_key_id, debit_credit_indicator)
);

-- Verify table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'movement_type_account_keys'
ORDER BY ordinal_position;
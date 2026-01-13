-- Step 1: Create the table first
CREATE TABLE IF NOT EXISTS movement_type_account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type_id UUID NOT NULL REFERENCES movement_types(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    debit_credit_indicator VARCHAR(1) NOT NULL CHECK (debit_credit_indicator IN ('D', 'C')),
    sequence_order INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(movement_type_id, account_key_id, debit_credit_indicator)
);
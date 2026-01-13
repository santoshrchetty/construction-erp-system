-- Modify stock_balances table to use storage_location_id instead of store_id
-- Drop dependent views first
DROP VIEW IF EXISTS stock_balances_fifo CASCADE;

-- Add storage_location_id column
ALTER TABLE stock_balances ADD COLUMN IF NOT EXISTS storage_location_id UUID REFERENCES storage_locations(id);

-- Add new unique constraint if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'stock_balances_storage_location_stock_item_key') THEN
        ALTER TABLE stock_balances ADD CONSTRAINT stock_balances_storage_location_stock_item_key 
        UNIQUE (storage_location_id, stock_item_id);
    END IF;
END $$;
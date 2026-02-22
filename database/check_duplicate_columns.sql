-- Check if duplicate columns exist and drop them if needed
-- This script is safe to run multiple times

-- Drop duplicate purpose column if it exists from add_line_item_fields.sql
-- Keep the original one from the base table
DO $$ 
BEGIN
    -- Check if there are duplicate purpose columns
    IF (SELECT COUNT(*) FROM information_schema.columns 
        WHERE table_name = 'material_request_items' AND column_name = 'purpose') > 1 THEN
        -- This shouldn't happen, but if it does, we need manual intervention
        RAISE NOTICE 'Multiple purpose columns detected - manual cleanup required';
    END IF;
    
    -- Check if there are duplicate justification columns
    IF (SELECT COUNT(*) FROM information_schema.columns 
        WHERE table_name = 'material_request_items' AND column_name = 'justification') > 1 THEN
        RAISE NOTICE 'Multiple justification columns detected - manual cleanup required';
    END IF;
END $$;

-- Show all columns in material_request_items to verify
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'material_request_items' 
  AND column_name IN ('purpose', 'justification', 'notes')
ORDER BY column_name;

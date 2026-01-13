-- Update plants table to support 6-character plant codes
-- Run this script in Supabase SQL Editor

-- Step 1: Drop the dependent view
DROP VIEW IF EXISTS material_master_complete;

-- Step 2: Alter the column type
ALTER TABLE plants 
ALTER COLUMN plant_code TYPE VARCHAR(6);

-- Verify the change
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'plants' AND column_name = 'plant_code';
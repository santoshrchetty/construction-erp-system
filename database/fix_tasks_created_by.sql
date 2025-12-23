-- Fix tasks created_by constraint
-- Run this in Supabase SQL Editor

-- Make created_by nullable since we don't have user auth context
ALTER TABLE tasks ALTER COLUMN created_by DROP NOT NULL;

-- Verify the change
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tasks' AND column_name = 'created_by';
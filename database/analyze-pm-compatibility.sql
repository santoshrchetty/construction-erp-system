-- Analyze Activities and Tasks Schema for PM Tool Compatibility
-- Run each query separately in Supabase SQL Editor

-- Query 1: Activities Table Structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'activities'
ORDER BY ordinal_position;

/*
-- Query 2: Tasks Table Structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'tasks'
ORDER BY ordinal_position;

-- Query 3: Sample Activities Data (check what fields have values)
SELECT 
    code,
    name,
    activity_type,
    status,
    priority,
    duration_days,
    planned_start_date,
    progress_percentage,
    budget_amount
FROM activities
LIMIT 3;

-- Query 4: Check for date columns in activities
SELECT 
    column_name
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'activities'
  AND (column_name LIKE '%date%' OR column_name LIKE '%time%')
ORDER BY column_name;
*/

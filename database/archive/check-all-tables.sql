-- First, let's check what tables actually exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('cost_centers', 'profit_centers', 'plants', 'users', 'persons_responsible')
ORDER BY table_name;

-- Check cost_centers columns
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'cost_centers' ORDER BY ordinal_position;

-- Check profit_centers columns  
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'profit_centers' ORDER BY ordinal_position;

-- Check plants columns
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'plants' ORDER BY ordinal_position;

-- Check users columns
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'users' ORDER BY ordinal_position;

-- Sample data from existing tables
SELECT * FROM cost_centers LIMIT 1;
SELECT * FROM profit_centers LIMIT 1;  
SELECT * FROM plants LIMIT 1;
SELECT * FROM users LIMIT 1;
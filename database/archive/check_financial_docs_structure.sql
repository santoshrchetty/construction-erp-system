-- Check financial_documents table structure
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'financial_documents' 
ORDER BY ordinal_position;

-- Check actual financial_documents data
SELECT * FROM financial_documents LIMIT 3;
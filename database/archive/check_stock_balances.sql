-- Check the structure of stock_balances table specifically
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'stock_balances' 
ORDER BY ordinal_position;
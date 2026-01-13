-- Fix boolean values in account_determination table
UPDATE public.account_determination 
SET is_active = true 
WHERE is_active::text = 'true';

UPDATE public.account_determination 
SET is_active = false 
WHERE is_active::text = 'false';

-- Verify the fix
SELECT id, is_active, pg_typeof(is_active) as data_type 
FROM public.account_determination 
LIMIT 5;
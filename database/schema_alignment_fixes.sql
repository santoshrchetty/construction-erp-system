-- Schema Alignment Fixes for Supabase Database
-- Run these commands to add missing foreign key constraints only

-- Step 1: Clean up invalid references in account_determination
DELETE FROM public.account_determination 
WHERE gl_account_id NOT IN (SELECT id FROM public.chart_of_accounts);

DELETE FROM public.account_determination 
WHERE valuation_class_id NOT IN (SELECT id FROM public.valuation_classes);

-- Step 2: Add missing foreign key constraints for account_determination
ALTER TABLE public.account_determination 
ADD CONSTRAINT account_determination_valuation_class_id_fkey 
FOREIGN KEY (valuation_class_id) REFERENCES public.valuation_classes(id);

ALTER TABLE public.account_determination 
ADD CONSTRAINT account_determination_gl_account_id_fkey 
FOREIGN KEY (gl_account_id) REFERENCES public.chart_of_accounts(id);

-- Step 3: Add missing unique constraint for account_determination
ALTER TABLE public.account_determination 
ADD CONSTRAINT account_determination_unique_key 
UNIQUE (company_code_id, valuation_class_id, account_key_id);

-- Step 4: Add missing check constraint for account_keys
ALTER TABLE public.account_keys 
ADD CONSTRAINT account_keys_debit_credit_check 
CHECK (debit_credit_indicator IN ('D', 'C'));
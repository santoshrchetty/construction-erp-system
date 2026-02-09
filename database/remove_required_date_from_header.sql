-- Remove required_date column from material_requests header table
-- Since required_date is now managed at item level only

ALTER TABLE public.material_requests DROP COLUMN IF EXISTS required_date;
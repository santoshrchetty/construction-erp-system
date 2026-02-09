-- Add missing columns to material_request_items table
-- These columns were moved from header level to item level

ALTER TABLE public.material_request_items 
ADD COLUMN IF NOT EXISTS priority character varying(10) DEFAULT 'MEDIUM',
ADD COLUMN IF NOT EXISTS required_date date;
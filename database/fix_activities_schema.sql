-- Quick fix for activities creation issue
-- Run this in Supabase SQL Editor

-- Add missing columns that ActivityManager expects
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS activity_type VARCHAR(20) DEFAULT 'INTERNAL',
ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'medium',
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'not_started',
ADD COLUMN IF NOT EXISTS progress_percentage DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_labor_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_material_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_equipment_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_subcontract_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS vendor_id UUID REFERENCES vendors(id);

-- Check if it worked
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'activities' 
ORDER BY ordinal_position;
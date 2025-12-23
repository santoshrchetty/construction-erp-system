-- SCRIPT 2: Add SAP Fields to Existing Tables
-- Copy and paste this entire script into Supabase SQL Editor

-- Add SAP organizational fields to projects table
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS company_code_id UUID REFERENCES company_codes(id),
ADD COLUMN IF NOT EXISTS purchasing_org_id UUID REFERENCES purchasing_organizations(id),
ADD COLUMN IF NOT EXISTS plant_id UUID REFERENCES plants(id);

-- Add company code to vendors
ALTER TABLE vendors
ADD COLUMN IF NOT EXISTS company_code_id UUID REFERENCES company_codes(id),
ADD COLUMN IF NOT EXISTS is_inter_company BOOLEAN DEFAULT false;

-- Add storage location to stores
ALTER TABLE stores
ADD COLUMN IF NOT EXISTS storage_location_id UUID REFERENCES storage_locations(id);

-- Add purchasing org to purchase orders
ALTER TABLE purchase_orders
ADD COLUMN IF NOT EXISTS purchasing_org_id UUID REFERENCES purchasing_organizations(id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_projects_company_code ON projects(company_code_id);
CREATE INDEX IF NOT EXISTS idx_plants_company_code ON plants(company_code_id);
CREATE INDEX IF NOT EXISTS idx_storage_locations_plant ON storage_locations(plant_id);
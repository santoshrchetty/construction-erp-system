-- Add project-specific stock support
-- Run this in Supabase SQL Editor

-- Add project_id to stock_items for project-specific materials
ALTER TABLE stock_items 
ADD COLUMN IF NOT EXISTS project_id UUID REFERENCES projects(id) ON DELETE CASCADE;

-- Add index for project-specific queries
CREATE INDEX IF NOT EXISTS idx_stock_items_project_id ON stock_items(project_id);

-- Update stock_balances to support both global and project stores
-- (stores table already has project_id, so stock_balances inherits this through store_id)

-- Add view for global materials (no project_id)
CREATE OR REPLACE VIEW global_materials AS
SELECT * FROM stock_items WHERE project_id IS NULL;

-- Add view for project-specific materials
CREATE OR REPLACE VIEW project_materials AS
SELECT * FROM stock_items WHERE project_id IS NOT NULL;
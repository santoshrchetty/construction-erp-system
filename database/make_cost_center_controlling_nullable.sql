-- Make controlling_area_code nullable in cost_centers table
-- This allows cost centers to be created without controlling area assignment
-- Assignments will be handled separately in the Assignments tab

ALTER TABLE cost_centers 
ALTER COLUMN controlling_area_code DROP NOT NULL;

-- Verify the change
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'cost_centers' AND column_name = 'controlling_area_code';
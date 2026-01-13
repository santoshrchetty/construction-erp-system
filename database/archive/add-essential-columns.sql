-- Add essential missing columns one by one
ALTER TABLE projects ADD COLUMN IF NOT EXISTS cost_center_id UUID;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS profit_center_id UUID;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS plant_id UUID;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS person_responsible_id UUID;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS code VARCHAR(50);
ALTER TABLE projects ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS planned_end_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS budget DECIMAL(15,2);
ALTER TABLE projects ADD COLUMN IF NOT EXISTS location VARCHAR(255);
ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_by UUID;

-- Refresh schema cache (restart your app after running this)
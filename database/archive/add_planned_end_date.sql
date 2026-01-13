-- Add planned_end_date field to activities table for scheduling

ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS planned_end_date DATE;

-- Update existing activities to calculate end date from start date and duration
UPDATE activities 
SET planned_end_date = (planned_start_date::date + duration_days - 1)
WHERE planned_start_date IS NOT NULL AND planned_end_date IS NULL;

-- Add comment for documentation
COMMENT ON COLUMN activities.planned_end_date IS 'Calculated end date based on start date, duration, and dependencies';
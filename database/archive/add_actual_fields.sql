-- Add actual date and duration fields to activities table for tracking planned vs actual

-- Temporarily disable the dependency validation trigger
DROP TRIGGER IF EXISTS validate_dependencies_trigger ON activities;

ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS actual_start_date DATE,
ADD COLUMN IF NOT EXISTS actual_end_date DATE,
ADD COLUMN IF NOT EXISTS actual_duration_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS baseline_start_date DATE,
ADD COLUMN IF NOT EXISTS baseline_end_date DATE,
ADD COLUMN IF NOT EXISTS baseline_duration_days INTEGER;

-- Copy current planned dates to baseline (original plan)
UPDATE activities 
SET 
    baseline_start_date = planned_start_date,
    baseline_end_date = planned_end_date,
    baseline_duration_days = duration_days
WHERE baseline_start_date IS NULL;

-- Add comments for documentation
COMMENT ON COLUMN activities.actual_start_date IS 'When activity actually started';
COMMENT ON COLUMN activities.actual_end_date IS 'When activity actually finished';
COMMENT ON COLUMN activities.actual_duration_days IS 'Actual working days taken';
COMMENT ON COLUMN activities.baseline_start_date IS 'Original planned start date (baseline)';
COMMENT ON COLUMN activities.baseline_end_date IS 'Original planned end date (baseline)';
COMMENT ON COLUMN activities.baseline_duration_days IS 'Original planned duration (baseline)';

-- Add variance calculation view
CREATE OR REPLACE VIEW activity_variance AS
SELECT 
    id,
    code,
    name,
    -- Date variances
    CASE 
        WHEN actual_start_date IS NOT NULL AND planned_start_date IS NOT NULL 
        THEN actual_start_date - planned_start_date 
        ELSE NULL 
    END as start_date_variance_days,
    
    CASE 
        WHEN actual_end_date IS NOT NULL AND planned_end_date IS NOT NULL 
        THEN actual_end_date - planned_end_date 
        ELSE NULL 
    END as end_date_variance_days,
    
    -- Duration variance
    CASE 
        WHEN actual_duration_days > 0 
        THEN actual_duration_days - duration_days 
        ELSE NULL 
    END as duration_variance_days,
    
    -- Schedule performance
    CASE 
        WHEN actual_start_date IS NOT NULL AND planned_start_date IS NOT NULL 
        THEN 
            CASE 
                WHEN actual_start_date <= planned_start_date THEN 'On Time'
                WHEN actual_start_date - planned_start_date <= 3 THEN 'Minor Delay'
                ELSE 'Major Delay'
            END
        ELSE 'Not Started'
    END as schedule_status
    
FROM activities;

-- Fix dependency validation function to handle null arrays
CREATE OR REPLACE FUNCTION validate_activity_dependencies()
RETURNS TRIGGER AS $$
BEGIN
    -- Check each predecessor for circular dependencies
    IF NEW.predecessor_activities IS NOT NULL AND array_length(NEW.predecessor_activities, 1) IS NOT NULL THEN
        FOR i IN 1..array_length(NEW.predecessor_activities, 1) LOOP
            IF check_circular_dependency(NEW.id, NEW.predecessor_activities[i]) THEN
                RAISE EXCEPTION 'Circular dependency detected between activities % and %', 
                    NEW.id, NEW.predecessor_activities[i];
            END IF;
        END LOOP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger with the fixed function
CREATE TRIGGER validate_dependencies_trigger
    BEFORE INSERT OR UPDATE ON activities
    FOR EACH ROW
    EXECUTE FUNCTION validate_activity_dependencies();
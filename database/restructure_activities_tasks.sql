-- Restructure Activities and Tasks according to construction management best practices
-- Activities drive the schedule, Tasks are daily actionable items

-- Update Activities table to be the main scheduling entity
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS duration_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS progress_percentage DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'not_started',
ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'medium',
ADD COLUMN IF NOT EXISTS assigned_resources TEXT[],
ADD COLUMN IF NOT EXISTS predecessor_activities UUID[],
ADD COLUMN IF NOT EXISTS dependency_type VARCHAR(20) DEFAULT 'finish_to_start',
ADD COLUMN IF NOT EXISTS lag_days INTEGER DEFAULT 0;

-- Update Tasks table to be daily actionable items (no scheduling impact)
ALTER TABLE tasks 
DROP COLUMN IF EXISTS planned_start_date,
DROP COLUMN IF EXISTS planned_end_date,
DROP COLUMN IF EXISTS planned_hours,
DROP COLUMN IF EXISTS actual_hours,
ADD COLUMN IF NOT EXISTS checklist_item BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS completion_date DATE,
ADD COLUMN IF NOT EXISTS photos TEXT[],
ADD COLUMN IF NOT EXISTS daily_logs TEXT,
ADD COLUMN IF NOT EXISTS material_usage JSONB,
ADD COLUMN IF NOT EXISTS qa_notes TEXT,
ADD COLUMN IF NOT EXISTS safety_notes TEXT;

-- Create Activity Dependencies table
CREATE TABLE IF NOT EXISTS activity_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    predecessor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    successor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    dependency_type VARCHAR(20) NOT NULL DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(predecessor_activity_id, successor_activity_id)
);

-- Add comments for clarity
COMMENT ON TABLE activities IS 'Schedule-driving work packages with dates, duration, dependencies, and resources';
COMMENT ON TABLE tasks IS 'Daily actionable items under activities - no scheduling impact';
COMMENT ON TABLE activity_dependencies IS 'Dependencies between activities for scheduling';

COMMENT ON COLUMN activities.duration_days IS 'Duration in working days';
COMMENT ON COLUMN activities.progress_percentage IS 'Overall activity progress (0-100)';
COMMENT ON COLUMN activities.assigned_resources IS 'Array of resource IDs assigned to this activity';
COMMENT ON COLUMN activities.predecessor_activities IS 'Array of predecessor activity IDs';

COMMENT ON COLUMN tasks.checklist_item IS 'Whether this task is a simple checklist item';
COMMENT ON COLUMN tasks.photos IS 'Array of photo URLs for this task';
COMMENT ON COLUMN tasks.daily_logs IS 'Daily progress logs and notes';
COMMENT ON COLUMN tasks.material_usage IS 'JSON object storing material usage data';

SELECT 'Activities and Tasks restructured successfully!' as status;
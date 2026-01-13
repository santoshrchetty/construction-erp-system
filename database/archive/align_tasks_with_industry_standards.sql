-- Align Tasks with Industry Standards (Primavera Model)
-- Run this in Supabase SQL Editor

-- 1. Remove scheduling fields from tasks (tasks should not have scheduling)
ALTER TABLE tasks 
DROP COLUMN IF EXISTS planned_start_date,
DROP COLUMN IF EXISTS planned_end_date,
DROP COLUMN IF EXISTS actual_start_date,
DROP COLUMN IF EXISTS actual_end_date,
DROP COLUMN IF EXISTS planned_hours,
DROP COLUMN IF EXISTS actual_hours;

-- 2. Add missing fields that tasks should have for progress tracking
ALTER TABLE tasks 
ADD COLUMN IF NOT EXISTS checklist_item BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS daily_logs TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS qa_notes TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS safety_notes TEXT DEFAULT '';

-- 3. Drop task dependencies table (tasks should not have dependencies)
DROP TABLE IF EXISTS task_dependencies;

-- 4. Add activity dependencies table (activities should have dependencies)
CREATE TABLE IF NOT EXISTS activity_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    predecessor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    successor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    dependency_type dependency_type NOT NULL DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(predecessor_activity_id, successor_activity_id)
);

-- 5. Add missing activity fields for proper scheduling
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS duration_days INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS predecessor_activities UUID[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS dependency_type dependency_type DEFAULT 'finish_to_start',
ADD COLUMN IF NOT EXISTS lag_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS requires_po BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS rate DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS quantity DECIMAL(15,4) DEFAULT 0,
ADD COLUMN IF NOT EXISTS actual_duration_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_expense_cost DECIMAL(15,2) DEFAULT 0;

-- 6. Create index for activity dependencies
CREATE INDEX IF NOT EXISTS idx_activity_dependencies_predecessor ON activity_dependencies(predecessor_activity_id);
CREATE INDEX IF NOT EXISTS idx_activity_dependencies_successor ON activity_dependencies(successor_activity_id);

-- 7. Verify the changes
SELECT 'Tasks table structure:' as info;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tasks' 
ORDER BY ordinal_position;

SELECT 'Activities table structure:' as info;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'activities' 
ORDER BY ordinal_position;

SELECT 'Activity dependencies table exists:' as info;
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'activity_dependencies'
) as table_exists;
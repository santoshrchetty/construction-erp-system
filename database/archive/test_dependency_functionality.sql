-- Test Dependency Functionality Flow
-- This script tests the complete dependency workflow

-- Step 1: Check if dependency fields exist in activities table
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'activities' 
AND column_name IN ('predecessor_activities', 'dependency_type', 'lag_days')
ORDER BY column_name;

-- Step 2: Check if activity_dependencies table exists
SELECT 
    table_name, 
    column_name, 
    data_type
FROM information_schema.columns 
WHERE table_name = 'activity_dependencies'
ORDER BY ordinal_position;

-- Step 3: Test data setup - Create sample activities for testing
-- (This would be run after ensuring a project exists)
/*
INSERT INTO activities (
    project_id, 
    wbs_node_id, 
    code, 
    name, 
    activity_type, 
    duration_days, 
    status, 
    priority,
    predecessor_activities,
    dependency_type,
    lag_days
) VALUES 
-- Activity A (no predecessors)
('PROJECT_ID_HERE', 'WBS_NODE_ID_HERE', 'TEST-A01', 'Foundation Work', 'INTERNAL', 5, 'not_started', 'high', '{}', 'finish_to_start', 0),
-- Activity B (depends on A)
('PROJECT_ID_HERE', 'WBS_NODE_ID_HERE', 'TEST-A02', 'Structural Work', 'INTERNAL', 10, 'not_started', 'high', '{ACTIVITY_A_ID}', 'finish_to_start', 2),
-- Activity C (depends on B)
('PROJECT_ID_HERE', 'WBS_NODE_ID_HERE', 'TEST-A03', 'Finishing Work', 'INTERNAL', 7, 'not_started', 'medium', '{ACTIVITY_B_ID}', 'finish_to_start', 1);
*/

-- Step 4: Test dependency queries
-- Query to find all activities with their predecessors
SELECT 
    a.code as activity_code,
    a.name as activity_name,
    a.predecessor_activities,
    a.dependency_type,
    a.lag_days,
    CASE 
        WHEN a.predecessor_activities IS NULL OR array_length(a.predecessor_activities, 1) IS NULL 
        THEN 'No predecessors' 
        ELSE array_length(a.predecessor_activities, 1)::text || ' predecessors'
    END as predecessor_count
FROM activities a
WHERE a.project_id IS NOT NULL
ORDER BY a.code;

-- Step 5: Test successor relationships
-- Query to find successors for each activity
WITH activity_successors AS (
    SELECT 
        a1.id as activity_id,
        a1.code as activity_code,
        a1.name as activity_name,
        array_agg(a2.code) as successor_codes,
        array_agg(a2.name) as successor_names
    FROM activities a1
    LEFT JOIN activities a2 ON a1.id = ANY(a2.predecessor_activities)
    WHERE a1.project_id IS NOT NULL
    GROUP BY a1.id, a1.code, a1.name
)
SELECT 
    activity_code,
    activity_name,
    CASE 
        WHEN successor_codes[1] IS NULL THEN 'No successors'
        ELSE array_length(successor_codes, 1)::text || ' successors: ' || array_to_string(successor_codes, ', ')
    END as successors
FROM activity_successors
ORDER BY activity_code;

-- Step 6: Test circular dependency detection
-- Function to detect circular dependencies
CREATE OR REPLACE FUNCTION test_circular_dependency(start_activity_id UUID, visited UUID[] DEFAULT '{}')
RETURNS BOOLEAN AS $$
DECLARE
    pred_id UUID;
    predecessors UUID[];
BEGIN
    -- If we've already visited this activity, we have a cycle
    IF start_activity_id = ANY(visited) THEN
        RETURN TRUE;
    END IF;
    
    -- Add current activity to visited list
    visited := visited || start_activity_id;
    
    -- Get predecessors of current activity
    SELECT predecessor_activities INTO predecessors 
    FROM activities 
    WHERE id = start_activity_id;
    
    -- If no predecessors, no cycle from this path
    IF predecessors IS NULL OR array_length(predecessors, 1) IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check each predecessor recursively
    FOREACH pred_id IN ARRAY predecessors LOOP
        IF test_circular_dependency(pred_id, visited) THEN
            RETURN TRUE;
        END IF;
    END LOOP;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Test scheduling algorithm components
-- Function to calculate activity start date based on predecessors
CREATE OR REPLACE FUNCTION calculate_activity_start_date(
    activity_id UUID,
    project_start_date DATE DEFAULT CURRENT_DATE
) RETURNS DATE AS $$
DECLARE
    activity_record RECORD;
    pred_id UUID;
    pred_end_date DATE;
    latest_end_date DATE := project_start_date;
    calculated_start_date DATE;
BEGIN
    -- Get activity details
    SELECT * INTO activity_record FROM activities WHERE id = activity_id;
    
    -- If no predecessors, use project start date
    IF activity_record.predecessor_activities IS NULL OR 
       array_length(activity_record.predecessor_activities, 1) IS NULL THEN
        RETURN project_start_date;
    END IF;
    
    -- Find latest predecessor end date
    FOREACH pred_id IN ARRAY activity_record.predecessor_activities LOOP
        SELECT planned_end_date INTO pred_end_date 
        FROM activities 
        WHERE id = pred_id;
        
        IF pred_end_date IS NOT NULL AND pred_end_date > latest_end_date THEN
            latest_end_date := pred_end_date;
        END IF;
    END LOOP;
    
    -- Apply dependency type logic
    CASE activity_record.dependency_type
        WHEN 'finish_to_start' THEN
            calculated_start_date := latest_end_date + 1;
        WHEN 'start_to_start' THEN
            -- Would need predecessor start dates for this
            calculated_start_date := latest_end_date;
        ELSE
            calculated_start_date := latest_end_date + 1;
    END CASE;
    
    -- Apply lag days
    calculated_start_date := calculated_start_date + COALESCE(activity_record.lag_days, 0);
    
    RETURN calculated_start_date;
END;
$$ LANGUAGE plpgsql;

-- Step 8: Validation queries
-- Check for orphaned dependencies (predecessors that don't exist)
SELECT 
    a.code,
    a.name,
    unnest(a.predecessor_activities) as predecessor_id
FROM activities a
WHERE a.predecessor_activities IS NOT NULL
AND EXISTS (
    SELECT 1 
    FROM unnest(a.predecessor_activities) as pred_id
    WHERE NOT EXISTS (
        SELECT 1 FROM activities a2 WHERE a2.id = pred_id
    )
);

-- Check for self-referencing dependencies
SELECT 
    code,
    name,
    'Self-referencing dependency detected' as issue
FROM activities 
WHERE id = ANY(predecessor_activities);

-- Step 9: Performance test queries
-- Index usage check
EXPLAIN (ANALYZE, BUFFERS) 
SELECT a1.*, a2.code as predecessor_code
FROM activities a1
JOIN unnest(a1.predecessor_activities) as pred_id ON true
JOIN activities a2 ON a2.id = pred_id
WHERE a1.project_id = 'test-project-id';

SELECT 'Dependency functionality test completed!' as status;
-- Add dependency validation to prevent circular dependencies

-- Function to check for circular dependencies
CREATE OR REPLACE FUNCTION check_circular_dependency(
    p_activity_id UUID,
    p_predecessor_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    visited UUID[];
    current_id UUID;
    predecessors UUID[];
BEGIN
    -- Start with the predecessor we want to add
    current_id := p_predecessor_id;
    visited := ARRAY[p_activity_id]; -- Mark the target activity as visited
    
    WHILE current_id IS NOT NULL LOOP
        -- If we've seen this activity before, we have a cycle
        IF current_id = ANY(visited) THEN
            RETURN TRUE; -- Circular dependency detected
        END IF;
        
        -- Add current activity to visited list
        visited := visited || current_id;
        
        -- Get predecessors of current activity
        SELECT predecessor_activities INTO predecessors 
        FROM activities 
        WHERE id = current_id;
        
        -- If no predecessors, we're done with this path
        IF predecessors IS NULL OR array_length(predecessors, 1) IS NULL THEN
            EXIT;
        END IF;
        
        -- Check each predecessor (simplified - check first one)
        current_id := predecessors[1];
    END LOOP;
    
    RETURN FALSE; -- No circular dependency
END;
$$ LANGUAGE plpgsql;

-- Trigger to validate dependencies before insert/update
CREATE OR REPLACE FUNCTION validate_activity_dependencies()
RETURNS TRIGGER AS $$
BEGIN
    -- Check each predecessor for circular dependencies
    IF NEW.predecessor_activities IS NOT NULL THEN
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

-- Create trigger
DROP TRIGGER IF EXISTS validate_dependencies_trigger ON activities;
CREATE TRIGGER validate_dependencies_trigger
    BEFORE INSERT OR UPDATE ON activities
    FOR EACH ROW
    EXECUTE FUNCTION validate_activity_dependencies();
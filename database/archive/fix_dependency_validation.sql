-- Fix the dependency validation function to handle null arrays

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
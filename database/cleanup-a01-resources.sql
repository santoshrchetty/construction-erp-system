-- Clean up existing resource planning data for Activity A01
DO $$
DECLARE
    v_activity_id UUID := '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';
BEGIN
    -- Delete existing resource planning data
    DELETE FROM activity_materials WHERE activity_id = v_activity_id;
    DELETE FROM activity_equipment WHERE activity_id = v_activity_id;
    DELETE FROM activity_manpower WHERE activity_id = v_activity_id;
    DELETE FROM activity_subcontractors WHERE activity_id = v_activity_id;
    DELETE FROM activity_services WHERE activity_id = v_activity_id;
    
    RAISE NOTICE 'Cleaned up resource planning data for Activity A01';
END $$;

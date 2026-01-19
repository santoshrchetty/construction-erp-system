-- Ultra-Minimal: Just Materials for Activity A01
DO $$
DECLARE
    v_project_id UUID := '906a5998-5812-48df-98ea-221f79855d1e';
    v_activity_id UUID := '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';
    v_material_id UUID;
BEGIN
    -- Get any material ID
    SELECT id INTO v_material_id FROM materials LIMIT 1;
    
    IF v_material_id IS NULL THEN
        RAISE NOTICE 'No materials found in database';
        RETURN;
    END IF;
    
    -- Insert materials to match universal_journal costs
    -- Cement: 125000 + 85000 = 210000
    INSERT INTO activity_materials (activity_id, project_id, material_id, required_quantity, unit_of_measure, unit_cost)
    VALUES 
        (v_activity_id, v_project_id, v_material_id, 1000, 'BAG', 210.00);
    
    -- Insert manpower to match universal_journal: 45000
    INSERT INTO activity_manpower (activity_id, project_id, role, crew_size, required_hours, hourly_rate)
    VALUES 
        (v_activity_id, v_project_id, 'Labor', 10, 40, 112.50);
    
    -- Insert subcontractor to match universal_journal: 150000
    INSERT INTO activity_subcontractors (activity_id, project_id, trade, scope_of_work, crew_size, contract_value)
    VALUES 
        (v_activity_id, v_project_id, 'civil', 'Site work', 8, 150000.00);
    
    RAISE NOTICE 'Minimal resource data inserted';
END $$;

-- Verify and show planned costs
SELECT 
    'Materials' as type, 
    COUNT(*) as count, 
    COALESCE(SUM(required_quantity * unit_cost), 0) as planned_cost
FROM activity_materials 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Manpower', 
    COUNT(*), 
    COALESCE(SUM(crew_size * required_hours * hourly_rate), 0)
FROM activity_manpower 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Subcontractors', 
    COUNT(*), 
    COALESCE(SUM(contract_value), 0)
FROM activity_subcontractors 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'TOTAL', 
    0,
    COALESCE((SELECT SUM(required_quantity * unit_cost) FROM activity_materials WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'), 0) +
    COALESCE((SELECT SUM(crew_size * required_hours * hourly_rate) FROM activity_manpower WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'), 0) +
    COALESCE((SELECT SUM(contract_value) FROM activity_subcontractors WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'), 0);

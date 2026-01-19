-- Complete Resource Planning Data for Activity HW-0001.01-A01
-- Matches universal_journal actual costs

DO $$
DECLARE
    v_project_id UUID := '906a5998-5812-48df-98ea-221f79855d1e';
    v_activity_id UUID := '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';
    v_material_id UUID;
    v_equipment_id UUID;
BEGIN
    -- Get material ID
    SELECT id INTO v_material_id FROM materials LIMIT 1;
    
    -- Get equipment ID
    SELECT id INTO v_equipment_id FROM equipment WHERE equipment_code = 'EQ-SURVEY-001';
    
    -- Materials (to match UJ actual: 210,000)
    INSERT INTO activity_materials (activity_id, project_id, material_id, required_quantity, unit_of_measure, unit_cost)
    VALUES 
        (v_activity_id, v_project_id, v_material_id, 1000, 'BAG', 210.00);
    
    -- Equipment (to match UJ actual: 64,000)
    INSERT INTO activity_equipment (activity_id, project_id, equipment_id, required_hours, hourly_rate)
    VALUES 
        (v_activity_id, v_project_id, v_equipment_id, 200, 160.00);
    
    -- Manpower (to match UJ actual: 90,000)
    -- No crew_size, just use required_hours and hourly_rate
    INSERT INTO activity_manpower (activity_id, project_id, role, required_hours, hourly_rate)
    VALUES 
        (v_activity_id, v_project_id, 'Survey Engineer', 80, 35.00),
        (v_activity_id, v_project_id, 'Skilled Labor', 400, 112.50);
    
    -- Subcontractors (to match UJ actual: 300,000)
    INSERT INTO activity_subcontractors (activity_id, project_id, trade, scope_of_work, crew_size, contract_value)
    VALUES 
        (v_activity_id, v_project_id, 'civil', 'Site preparation', 8, 150000.00),
        (v_activity_id, v_project_id, 'survey', 'Surveying services', 4, 150000.00);
    
    RAISE NOTICE 'Complete resource data inserted for Activity A01';
END $$;

-- Verify Planned Costs
SELECT 
    'Materials' as type, 
    COUNT(*) as count, 
    COALESCE(SUM(required_quantity * unit_cost), 0) as planned_cost
FROM activity_materials 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Equipment', 
    COUNT(*), 
    COALESCE(SUM(required_hours * hourly_rate), 0)
FROM activity_equipment 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Manpower', 
    COUNT(*), 
    COALESCE(SUM(required_hours * hourly_rate), 0)
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
    '=== TOTAL PLANNED ===' as type,
    0,
    COALESCE((SELECT SUM(required_quantity * unit_cost) FROM activity_materials WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'), 0) +
    COALESCE((SELECT SUM(required_hours * hourly_rate) FROM activity_equipment WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'), 0) +
    COALESCE((SELECT SUM(required_hours * hourly_rate) FROM activity_manpower WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'), 0) +
    COALESCE((SELECT SUM(contract_value) FROM activity_subcontractors WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'), 0);

-- Complete Resource Planning for Activity A01 with Employee References
DO $$
DECLARE
    v_project_id UUID := '906a5998-5812-48df-98ea-221f79855d1e';
    v_activity_id UUID := '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';
    v_material_id UUID;
    v_equipment_id UUID;
    v_emp_engineer UUID;
    v_emp_surveyor UUID;
BEGIN
    -- Get IDs
    SELECT id INTO v_material_id FROM materials LIMIT 1;
    SELECT id INTO v_equipment_id FROM equipment WHERE equipment_code = 'EQ-SURVEY-001';
    SELECT id INTO v_emp_engineer FROM employees WHERE employee_code = 'EMP-001';
    SELECT id INTO v_emp_surveyor FROM employees WHERE employee_code = 'EMP-007';
    
    -- Materials (planned: 210,000)
    INSERT INTO activity_materials (activity_id, project_id, material_id, required_quantity, unit_of_measure, unit_cost)
    VALUES (v_activity_id, v_project_id, v_material_id, 1000, 'BAG', 210.00);
    
    -- Equipment (planned: 32,000)
    INSERT INTO activity_equipment (activity_id, project_id, equipment_id, required_hours, hourly_rate)
    VALUES (v_activity_id, v_project_id, v_equipment_id, 200, 160.00);
    
    -- Manpower with employee references (planned: 47,800)
    INSERT INTO activity_manpower (activity_id, project_id, employee_id, role, required_hours, hourly_rate)
    VALUES 
        (v_activity_id, v_project_id, v_emp_engineer, 'Civil Engineer', 80, 35.00),
        (v_activity_id, v_project_id, v_emp_surveyor, 'Surveyor', 400, 112.50);
    
    -- Subcontractors (planned: 300,000)
    INSERT INTO activity_subcontractors (activity_id, project_id, trade, scope_of_work, crew_size, contract_value)
    VALUES 
        (v_activity_id, v_project_id, 'civil', 'Site preparation', 8, 150000.00),
        (v_activity_id, v_project_id, 'survey', 'Surveying services', 4, 150000.00);
    
    RAISE NOTICE 'Resource planning complete for Activity A01';
END $$;

-- Verify Planned vs Actual
SELECT 
    'Materials' as resource,
    COALESCE(SUM(required_quantity * unit_cost), 0) as planned,
    (SELECT SUM(company_amount) FROM universal_journal WHERE activity_code = 'HW-0001.01-A01' AND cost_element IN ('501000','502000')) as actual
FROM activity_materials WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Equipment',
    COALESCE(SUM(required_hours * hourly_rate), 0),
    (SELECT SUM(company_amount) FROM universal_journal WHERE activity_code = 'HW-0001.01-A01' AND cost_element = '531000')
FROM activity_equipment WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Manpower',
    COALESCE(SUM(required_hours * hourly_rate), 0),
    (SELECT SUM(company_amount) FROM universal_journal WHERE activity_code = 'HW-0001.01-A01' AND cost_element = '511000')
FROM activity_manpower WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Subcontractors',
    COALESCE(SUM(contract_value), 0),
    (SELECT SUM(company_amount) FROM universal_journal WHERE activity_code = 'HW-0001.01-A01' AND cost_element = '521000')
FROM activity_subcontractors WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';

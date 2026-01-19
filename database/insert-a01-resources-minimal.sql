-- Minimal Resource Planning Data for Activity HW-0001.01-A01
-- Matches the universal_journal entries we created

DO $$
DECLARE
    v_project_id UUID := '906a5998-5812-48df-98ea-221f79855d1e';
    v_activity_id UUID := '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';
BEGIN
    -- Materials (matching universal_journal: Cement 501000, Steel 502000)
    INSERT INTO activity_materials (activity_id, project_id, material_id, required_quantity, unit_of_measure, unit_cost, notes)
    SELECT 
        v_activity_id,
        v_project_id,
        id,
        CASE 
            WHEN material_code = 'CEMENT-OPC-53' THEN 1000
            WHEN material_code = 'STEEL-TMT-12MM' THEN 500
            ELSE 100
        END,
        base_uom,
        standard_price,
        'Planned for site survey'
    FROM materials 
    WHERE material_code IN ('CEMENT-OPC-53', 'STEEL-TMT-12MM')
    LIMIT 2;
    
    -- Equipment (matching universal_journal: Equipment 531000)
    INSERT INTO activity_equipment (activity_id, project_id, equipment_code, equipment_name, required_hours, hourly_rate, notes)
    VALUES 
        (v_activity_id, v_project_id, 'EQ-SURVEY-01', 'Total Station', 40, 15.00, 'Precision surveying'),
        (v_activity_id, v_project_id, 'EQ-RENTAL-01', 'Equipment Rental', 200, 160.00, 'Heavy equipment');
    
    -- Manpower (matching universal_journal: Labor 511000)
    INSERT INTO activity_manpower (activity_id, project_id, role, crew_size, required_hours, hourly_rate, notes)
    VALUES 
        (v_activity_id, v_project_id, 'Survey Engineer', 2, 40, 35.00, 'Lead surveying'),
        (v_activity_id, v_project_id, 'Skilled Labor', 4, 40, 18.00, 'Survey support'),
        (v_activity_id, v_project_id, 'General Labor', 6, 40, 12.00, 'Marking work');
    
    -- Subcontractors (matching universal_journal: Subcontractor 521000)
    INSERT INTO activity_subcontractors (activity_id, project_id, trade, scope_of_work, crew_size, contract_value, notes)
    VALUES 
        (v_activity_id, v_project_id, 'civil', 'Site preparation and surveying', 8, 150000.00, 'Civil subcontractor');
    
    RAISE NOTICE 'Resource planning data inserted for Activity A01';
END $$;

-- Verify
SELECT 
    'Materials' as type, COUNT(*) as count, SUM(required_quantity * unit_cost) as planned_cost
FROM activity_materials 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Equipment', COUNT(*), SUM(required_hours * hourly_rate)
FROM activity_equipment 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Manpower', COUNT(*), SUM(crew_size * required_hours * hourly_rate)
FROM activity_manpower 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
UNION ALL
SELECT 
    'Subcontractors', COUNT(*), SUM(contract_value)
FROM activity_subcontractors 
WHERE activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';

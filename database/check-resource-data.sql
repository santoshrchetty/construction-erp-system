-- Check which activities have resource assignments
SELECT 
    a.code,
    a.name,
    COUNT(DISTINCT am.id) as materials,
    COUNT(DISTINCT ae.id) as equipment,
    COUNT(DISTINCT amp.id) as manpower,
    COUNT(DISTINCT asv.id) as services,
    COUNT(DISTINCT asub.id) as subcontractors
FROM activities a
LEFT JOIN activity_materials am ON a.id = am.activity_id
LEFT JOIN activity_equipment ae ON a.id = ae.activity_id
LEFT JOIN activity_manpower amp ON a.id = amp.activity_id
LEFT JOIN activity_services asv ON a.id = asv.activity_id
LEFT JOIN activity_subcontractors asub ON a.id = asub.activity_id
WHERE a.code LIKE 'HW-0001%'
GROUP BY a.code, a.name
ORDER BY a.code
LIMIT 5;

-- Check if HW-0001.01-A01 has any resources
SELECT 'Materials' as type, COUNT(*) as count FROM activity_materials WHERE activity_id = (SELECT id FROM activities WHERE code = 'HW-0001.01-A01')
UNION ALL
SELECT 'Equipment', COUNT(*) FROM activity_equipment WHERE activity_id = (SELECT id FROM activities WHERE code = 'HW-0001.01-A01')
UNION ALL
SELECT 'Manpower', COUNT(*) FROM activity_manpower WHERE activity_id = (SELECT id FROM activities WHERE code = 'HW-0001.01-A01')
UNION ALL
SELECT 'Services', COUNT(*) FROM activity_services WHERE activity_id = (SELECT id FROM activities WHERE code = 'HW-0001.01-A01')
UNION ALL
SELECT 'Subcontractors', COUNT(*) FROM activity_subcontractors WHERE activity_id = (SELECT id FROM activities WHERE code = 'HW-0001.01-A01');

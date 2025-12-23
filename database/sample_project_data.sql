-- Sample Project Data
-- =====================================================

-- 1. Create a sample project
INSERT INTO projects (id, name, code, description, project_type, status, start_date, planned_end_date, budget, created_at)
VALUES (
    uuid_generate_v4(),
    'Office Complex Construction',
    'OFC-2024-001',
    'Modern 5-story office building with parking facility',
    'commercial',
    'active',
    '2024-01-15',
    '2024-12-31',
    2500000.00,
    NOW()
);

-- Get the project ID for reference
DO $$
DECLARE
    project_uuid UUID;
BEGIN
    SELECT id INTO project_uuid FROM projects WHERE code = 'OFC-2024-001';
    
    -- 2. Create WBS structure
    INSERT INTO wbs_nodes (id, project_id, code, name, description, node_type, level, sequence_order) VALUES
    (uuid_generate_v4(), project_uuid, 'WBS-01', 'Foundation Work', 'Foundation and basement construction', 'phase', 1, 1),
    (uuid_generate_v4(), project_uuid, 'WBS-02', 'Structure Work', 'Main building structure', 'phase', 1, 2),
    (uuid_generate_v4(), project_uuid, 'WBS-03', 'MEP Work', 'Mechanical, Electrical, Plumbing', 'phase', 1, 3),
    (uuid_generate_v4(), project_uuid, 'WBS-04', 'Finishing Work', 'Interior and exterior finishing', 'phase', 1, 4);
    
    -- 3. Create activities for Foundation Work
    INSERT INTO activities (project_id, wbs_node_id, code, name, planned_start_date, planned_end_date, budget_amount) 
    SELECT 
        project_uuid,
        w.id,
        'ACT-01-01',
        'Site Preparation',
        '2024-01-15',
        '2024-02-15',
        150000.00
    FROM wbs_nodes w WHERE w.code = 'WBS-01' AND w.project_id = project_uuid;
    
    INSERT INTO activities (project_id, wbs_node_id, code, name, planned_start_date, planned_end_date, budget_amount)
    SELECT 
        project_uuid,
        w.id,
        'ACT-01-02',
        'Foundation Concrete',
        '2024-02-16',
        '2024-04-15',
        400000.00
    FROM wbs_nodes w WHERE w.code = 'WBS-01' AND w.project_id = project_uuid;
    
    -- 4. Create sample tasks
    INSERT INTO tasks (project_id, activity_id, name, status, planned_start_date, planned_end_date, progress_percentage, assigned_to)
    SELECT 
        project_uuid,
        a.id,
        'Excavation Work',
        'in_progress',
        '2024-01-15',
        '2024-01-30',
        75.00,
        (SELECT id FROM users WHERE email = 'engineer@demo.com')
    FROM activities a WHERE a.code = 'ACT-01-01' AND a.project_id = project_uuid;
    
    INSERT INTO tasks (project_id, activity_id, name, status, planned_start_date, planned_end_date, progress_percentage)
    SELECT 
        project_uuid,
        a.id,
        'Concrete Pouring',
        'not_started',
        '2024-02-16',
        '2024-03-15',
        0.00
    FROM activities a WHERE a.code = 'ACT-01-02' AND a.project_id = project_uuid;
    
END $$;

SELECT 'Sample project created successfully!' as status;
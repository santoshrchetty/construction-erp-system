-- Test Data for Highway Project WBS, Activities, and Tasks
-- Run this after creating HW-0001 project

DO $$
DECLARE
    v_project_id UUID;
    v_wbs_site_prep UUID;
    v_wbs_foundation UUID;
    v_wbs_pavement UUID;
    v_wbs_drainage UUID;
    v_wbs_finishing UUID;
    v_activity_id UUID;
BEGIN
    -- Get project ID
    SELECT id INTO v_project_id FROM projects WHERE code = 'HW-0001' LIMIT 1;
    
    IF v_project_id IS NULL THEN
        RAISE EXCEPTION 'Project HW-0001 not found. Create project first.';
    END IF;

    -- Insert WBS Nodes
    INSERT INTO wbs_nodes (project_id, code, name, node_type, level, sequence_order)
    VALUES (v_project_id, 'HW-0001.01', 'Site Preparation', 'phase', 1, 1)
    RETURNING id INTO v_wbs_site_prep;

    INSERT INTO wbs_nodes (project_id, code, name, node_type, level, sequence_order)
    VALUES (v_project_id, 'HW-0001.02', 'Foundation & Earthwork', 'phase', 1, 2)
    RETURNING id INTO v_wbs_foundation;

    INSERT INTO wbs_nodes (project_id, code, name, node_type, level, sequence_order)
    VALUES (v_project_id, 'HW-0001.03', 'Pavement Construction', 'phase', 1, 3)
    RETURNING id INTO v_wbs_pavement;

    INSERT INTO wbs_nodes (project_id, code, name, node_type, level, sequence_order)
    VALUES (v_project_id, 'HW-0001.04', 'Drainage & Utilities', 'phase', 1, 4)
    RETURNING id INTO v_wbs_drainage;

    INSERT INTO wbs_nodes (project_id, code, name, node_type, level, sequence_order)
    VALUES (v_project_id, 'HW-0001.05', 'Finishing & Safety', 'phase', 1, 5)
    RETURNING id INTO v_wbs_finishing;

    -- Phase 1: Site Preparation Activities
    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_site_prep, 'HW-0001.01-A01', 'Site Survey & Marking', 'INTERNAL', 'completed', 'high', 5, 15000, CURRENT_DATE - 60, 100)
    RETURNING id INTO v_activity_id;
    
    INSERT INTO tasks (project_id, activity_id, name, status, priority, checklist_item)
    VALUES 
        (v_project_id, v_activity_id, 'Establish control points', 'completed', 'high', true),
        (v_project_id, v_activity_id, 'Mark boundaries', 'completed', 'high', true),
        (v_project_id, v_activity_id, 'Document existing conditions', 'completed', 'medium', true);

    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_site_prep, 'HW-0001.01-A02', 'Clear Vegetation', 'EXTERNAL', 'completed', 'medium', 10, 45000, CURRENT_DATE - 55, 100)
    RETURNING id INTO v_activity_id;
    
    INSERT INTO tasks (project_id, activity_id, name, status, priority, checklist_item)
    VALUES 
        (v_project_id, v_activity_id, 'Remove trees and shrubs', 'completed', 'medium', true),
        (v_project_id, v_activity_id, 'Grub roots', 'completed', 'medium', true),
        (v_project_id, v_activity_id, 'Dispose of vegetation', 'completed', 'low', true);

    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_site_prep, 'HW-0001.01-A03', 'Demolition of Existing Structures', 'EXTERNAL', 'in_progress', 'high', 8, 75000, CURRENT_DATE - 45, 60);

    -- Phase 2: Foundation & Earthwork Activities
    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_foundation, 'HW-0001.02-A01', 'Excavation & Grading', 'EXTERNAL', 'in_progress', 'critical', 20, 250000, CURRENT_DATE - 30, 45)
    RETURNING id INTO v_activity_id;
    
    INSERT INTO tasks (project_id, activity_id, name, status, priority, checklist_item)
    VALUES 
        (v_project_id, v_activity_id, 'Strip topsoil', 'completed', 'high', true),
        (v_project_id, v_activity_id, 'Excavate to subgrade', 'in_progress', 'critical', true),
        (v_project_id, v_activity_id, 'Grade to design elevation', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Haul excess material', 'not_started', 'medium', false);

    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES 
        (v_project_id, v_wbs_foundation, 'HW-0001.02-A02', 'Soil Stabilization', 'EXTERNAL', 'not_started', 'high', 15, 180000, CURRENT_DATE + 5, 0),
        (v_project_id, v_wbs_foundation, 'HW-0001.02-A03', 'Compaction Testing', 'INTERNAL', 'not_started', 'high', 10, 35000, CURRENT_DATE + 20, 0);

    -- Phase 3: Pavement Construction Activities
    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_pavement, 'HW-0001.03-A01', 'Base Course Installation', 'EXTERNAL', 'not_started', 'critical', 25, 450000, CURRENT_DATE + 35, 0)
    RETURNING id INTO v_activity_id;
    
    INSERT INTO tasks (project_id, activity_id, name, status, priority, checklist_item)
    VALUES 
        (v_project_id, v_activity_id, 'Deliver aggregate base material', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Spread and compact base', 'not_started', 'critical', true),
        (v_project_id, v_activity_id, 'Test compaction density', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Grade to final elevation', 'not_started', 'high', true);

    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES 
        (v_project_id, v_wbs_pavement, 'HW-0001.03-A02', 'Asphalt Paving - Base Layer', 'EXTERNAL', 'not_started', 'critical', 15, 650000, CURRENT_DATE + 60, 0),
        (v_project_id, v_wbs_pavement, 'HW-0001.03-A03', 'Asphalt Paving - Surface Layer', 'EXTERNAL', 'not_started', 'critical', 12, 550000, CURRENT_DATE + 75, 0);

    -- Phase 4: Drainage & Utilities Activities
    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_drainage, 'HW-0001.04-A01', 'Install Storm Drains', 'EXTERNAL', 'not_started', 'high', 18, 280000, CURRENT_DATE + 40, 0)
    RETURNING id INTO v_activity_id;
    
    INSERT INTO tasks (project_id, activity_id, name, status, priority, checklist_item)
    VALUES 
        (v_project_id, v_activity_id, 'Excavate drainage trenches', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Install drainage pipes', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Install catch basins', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Backfill and compact', 'not_started', 'medium', true);

    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES 
        (v_project_id, v_wbs_drainage, 'HW-0001.04-A02', 'Install Culverts', 'EXTERNAL', 'not_started', 'high', 12, 195000, CURRENT_DATE + 58, 0),
        (v_project_id, v_wbs_drainage, 'HW-0001.04-A03', 'Utility Relocation', 'SERVICE', 'not_started', 'critical', 20, 320000, CURRENT_DATE + 45, 0);

    -- Phase 5: Finishing & Safety Activities
    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_finishing, 'HW-0001.05-A01', 'Road Marking & Striping', 'EXTERNAL', 'not_started', 'high', 8, 85000, CURRENT_DATE + 90, 0)
    RETURNING id INTO v_activity_id;
    
    INSERT INTO tasks (project_id, activity_id, name, status, priority, checklist_item)
    VALUES 
        (v_project_id, v_activity_id, 'Apply centerline striping', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Apply edge line striping', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Paint crosswalks', 'not_started', 'medium', true),
        (v_project_id, v_activity_id, 'Install reflective markers', 'not_started', 'medium', true);

    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES 
        (v_project_id, v_wbs_finishing, 'HW-0001.05-A02', 'Install Guardrails', 'EXTERNAL', 'not_started', 'critical', 10, 145000, CURRENT_DATE + 88, 0),
        (v_project_id, v_wbs_finishing, 'HW-0001.05-A03', 'Install Signage', 'EXTERNAL', 'not_started', 'high', 6, 65000, CURRENT_DATE + 98, 0);

    INSERT INTO activities (project_id, wbs_node_id, code, name, activity_type, status, priority, duration_days, budget_amount, planned_start_date, progress_percentage)
    VALUES (v_project_id, v_wbs_finishing, 'HW-0001.05-A04', 'Final Inspection & Cleanup', 'INTERNAL', 'not_started', 'high', 5, 25000, CURRENT_DATE + 104, 0)
    RETURNING id INTO v_activity_id;
    
    INSERT INTO tasks (project_id, activity_id, name, status, priority, checklist_item)
    VALUES 
        (v_project_id, v_activity_id, 'Conduct safety inspection', 'not_started', 'critical', true),
        (v_project_id, v_activity_id, 'Verify all work complete', 'not_started', 'high', true),
        (v_project_id, v_activity_id, 'Remove construction equipment', 'not_started', 'medium', true),
        (v_project_id, v_activity_id, 'Site cleanup', 'not_started', 'medium', true),
        (v_project_id, v_activity_id, 'Prepare punch list', 'not_started', 'high', false);

    RAISE NOTICE 'Test data created: 5 WBS Phases, 17 Activities, 30+ Tasks for HW-0001';
END $$;

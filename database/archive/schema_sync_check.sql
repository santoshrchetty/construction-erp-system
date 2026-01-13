-- Schema Sync Check
-- Compare what scripts applied vs what schema.sql defines

-- Check Tasks table fields
SELECT 'TASKS TABLE COMPARISON' as check_type;
SELECT 'Schema.sql defines these task fields:' as info;
-- From schema.sql: id, project_id, wbs_node_id, activity_id, name, description, status, priority, progress_percentage, checklist_item, daily_logs, qa_notes, safety_notes, assigned_to, created_by, created_at, updated_at

SELECT 'Scripts removed these task fields:' as info;
-- From align script: planned_start_date, planned_end_date, actual_start_date, actual_end_date, planned_hours, actual_hours

SELECT 'Scripts added these task fields:' as info;
-- From align script: checklist_item, daily_logs, qa_notes, safety_notes

-- Check Activities table fields
SELECT 'ACTIVITIES TABLE COMPARISON' as check_type;
SELECT 'Schema.sql defines these activity fields:' as info;
-- From schema.sql: id, project_id, wbs_node_id, code, name, description, activity_type, priority, status, planned_start_date, planned_end_date, actual_start_date, actual_end_date, duration_days, actual_duration_days, planned_hours, budget_amount, progress_percentage, predecessor_activities, dependency_type, lag_days, requires_po, rate, quantity, direct_labor_cost, direct_material_cost, direct_equipment_cost, direct_subcontract_cost, direct_expense_cost, vendor_id, responsible_user_id, is_active, created_at, updated_at

SELECT 'Align script added these activity fields:' as info;
-- From align script: duration_days, predecessor_activities, dependency_type, lag_days, requires_po, rate, quantity, actual_duration_days, direct_expense_cost

SELECT 'Fix script added these activity fields:' as info;
-- From fix script: activity_type, priority, status, progress_percentage, direct_labor_cost, direct_material_cost, direct_equipment_cost, direct_subcontract_cost, vendor_id

-- Check Dependencies
SELECT 'DEPENDENCIES TABLE COMPARISON' as check_type;
SELECT 'Schema.sql defines: activity_dependencies table' as info;
SELECT 'Align script: drops task_dependencies, creates activity_dependencies' as info;
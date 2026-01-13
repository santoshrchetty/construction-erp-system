-- Migration script to update existing projects with new schema
-- This preserves all existing data while adding new functionality

-- Step 1: Run the complete schema update
-- Run: complete_activities_schema.sql (this includes all missing fields)
-- Then run: add_working_calendar_columns.sql (for projects table updates)

-- Step 2: Update existing projects with default values
UPDATE projects 
SET 
    working_days = COALESCE(working_days, '{1,2,3,4,5}'),
    holidays = COALESCE(holidays, '{}'),
    project_indirect_cost_plan = COALESCE(project_indirect_cost_plan, 0),
    project_indirect_cost_actual = COALESCE(project_indirect_cost_actual, 0),
    indirect_cost_allocation_method = COALESCE(indirect_cost_allocation_method, 'percentage_of_direct')
WHERE working_days IS NULL OR holidays IS NULL OR project_indirect_cost_plan IS NULL;

-- Step 3: Update existing activities with default values
UPDATE activities 
SET 
    activity_type = COALESCE(activity_type, 'INTERNAL'),
    duration_days = COALESCE(duration_days, 
        CASE 
            WHEN planned_start_date IS NOT NULL AND planned_end_date IS NOT NULL 
            THEN GREATEST(1, (planned_end_date::date - planned_start_date::date) + 1)
            ELSE 1 
        END
    ),
    progress_percentage = COALESCE(progress_percentage, 0),
    status = COALESCE(status, 'not_started'),
    priority = COALESCE(priority, 'medium'),
    planned_hours = COALESCE(planned_hours, 0),
    cost_rate = COALESCE(cost_rate, 0),
    direct_labor_cost = COALESCE(direct_labor_cost, 0),
    direct_material_cost = COALESCE(direct_material_cost, 0),
    direct_equipment_cost = COALESCE(direct_equipment_cost, 0),
    direct_subcontract_cost = COALESCE(direct_subcontract_cost, 0),
    direct_expense_cost = COALESCE(direct_expense_cost, 0),
    requires_po = COALESCE(requires_po, false)
WHERE activity_type IS NULL OR duration_days IS NULL OR progress_percentage IS NULL;

-- Step 4: Update existing WBS nodes with default cost values
UPDATE wbs_nodes 
SET 
    wbs_direct_cost_total = COALESCE(wbs_direct_cost_total, 0),
    wbs_indirect_cost_allocated = COALESCE(wbs_indirect_cost_allocated, 0)
WHERE wbs_direct_cost_total IS NULL OR wbs_indirect_cost_allocated IS NULL;

-- Step 5: Update existing tasks to remove scheduling fields (if they exist)
-- Note: This preserves task data while removing scheduling impact
UPDATE tasks 
SET 
    checklist_item = COALESCE(checklist_item, false),
    daily_logs = COALESCE(daily_logs, ''),
    qa_notes = COALESCE(qa_notes, ''),
    safety_notes = COALESCE(safety_notes, '')
WHERE checklist_item IS NULL;

-- Step 6: Calculate WBS direct cost totals from existing activities
DO $$
DECLARE
    project_record RECORD;
BEGIN
    FOR project_record IN SELECT id FROM projects LOOP
        PERFORM update_wbs_direct_costs(project_record.id);
    END LOOP;
END $$;

-- Step 7: Add some default indirect costs for existing projects
INSERT INTO project_indirect_costs (project_id, cost_category, description, planned_amount, allocation_method)
SELECT 
    p.id,
    'Site Office',
    'Site office rent and utilities',
    p.budget * 0.05, -- 5% of project budget as default
    'percentage_of_direct'
FROM projects p
WHERE NOT EXISTS (
    SELECT 1 FROM project_indirect_costs pic WHERE pic.project_id = p.id
);

-- Step 8: Verify migration
SELECT 
    'Migration completed successfully!' as status,
    COUNT(*) as total_projects,
    COUNT(CASE WHEN working_days IS NOT NULL THEN 1 END) as projects_with_calendar,
    COUNT(CASE WHEN project_indirect_cost_plan IS NOT NULL THEN 1 END) as projects_with_cost_setup
FROM projects;

SELECT 
    'Activities updated:' as status,
    COUNT(*) as total_activities,
    COUNT(CASE WHEN activity_type IS NOT NULL THEN 1 END) as activities_with_type,
    COUNT(CASE WHEN duration_days > 0 THEN 1 END) as activities_with_duration
FROM activities;

SELECT 
    'Indirect costs added:' as status,
    COUNT(*) as total_indirect_costs
FROM project_indirect_costs;
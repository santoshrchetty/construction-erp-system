-- Add Direct and Indirect Cost Structure
-- Direct Costs: Traceable to specific activities (labor, materials, equipment, subcontract)
-- Indirect Costs: Project overheads allocated across WBS/Activities

-- Create indirect cost allocation method enum
CREATE TYPE indirect_allocation_method AS ENUM ('percentage_of_direct', 'duration_based', 'area_based', 'headcount_based', 'fixed_amount');

-- Add direct cost fields to Activities table
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS direct_labor_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_material_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_equipment_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_subcontract_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_expense_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_cost_total DECIMAL(15,2) GENERATED ALWAYS AS (
    direct_labor_cost + direct_material_cost + direct_equipment_cost + 
    direct_subcontract_cost + direct_expense_cost
) STORED;

-- Add cost fields to WBS table
ALTER TABLE wbs_nodes 
ADD COLUMN IF NOT EXISTS wbs_direct_cost_total DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS wbs_indirect_cost_allocated DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS wbs_total_cost DECIMAL(15,2) GENERATED ALWAYS AS (
    wbs_direct_cost_total + wbs_indirect_cost_allocated
) STORED;

-- Add indirect cost fields to Projects table
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS project_indirect_cost_plan DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS project_indirect_cost_actual DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS indirect_cost_allocation_method indirect_allocation_method DEFAULT 'percentage_of_direct';

-- Create Project Indirect Costs table for detailed tracking
CREATE TABLE IF NOT EXISTS project_indirect_costs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    cost_category VARCHAR(50) NOT NULL, -- 'Admin', 'PM', 'Security', 'Site Office', etc.
    description TEXT NOT NULL,
    planned_amount DECIMAL(15,2) DEFAULT 0,
    actual_amount DECIMAL(15,2) DEFAULT 0,
    expense_date DATE,
    allocation_method indirect_allocation_method DEFAULT 'percentage_of_direct',
    allocation_percentage DECIMAL(5,2) DEFAULT 0, -- For percentage-based allocation
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_project_indirect_costs_project ON project_indirect_costs(project_id);
CREATE INDEX IF NOT EXISTS idx_project_indirect_costs_category ON project_indirect_costs(cost_category);

-- Add comments for clarity
COMMENT ON COLUMN activities.direct_labor_cost IS 'Direct labor cost from timesheets';
COMMENT ON COLUMN activities.direct_material_cost IS 'Direct material cost from GRN/inventory';
COMMENT ON COLUMN activities.direct_equipment_cost IS 'Direct equipment cost from equipment logs';
COMMENT ON COLUMN activities.direct_subcontract_cost IS 'Direct subcontractor cost from PO/SES';
COMMENT ON COLUMN activities.direct_expense_cost IS 'Direct expenses (travel, lodging, etc.)';
COMMENT ON COLUMN activities.direct_cost_total IS 'Total direct cost (computed from all direct cost components)';

COMMENT ON COLUMN wbs_nodes.wbs_direct_cost_total IS 'Roll-up of all child activity direct costs';
COMMENT ON COLUMN wbs_nodes.wbs_indirect_cost_allocated IS 'Allocated indirect costs for this WBS node';
COMMENT ON COLUMN wbs_nodes.wbs_total_cost IS 'Total cost (direct + indirect)';

COMMENT ON COLUMN projects.project_indirect_cost_plan IS 'Planned indirect/overhead costs for project';
COMMENT ON COLUMN projects.project_indirect_cost_actual IS 'Actual indirect/overhead costs incurred';
COMMENT ON COLUMN projects.indirect_cost_allocation_method IS 'Method for allocating indirect costs to WBS/Activities';

COMMENT ON TABLE project_indirect_costs IS 'Detailed tracking of project indirect costs/overheads';
COMMENT ON COLUMN project_indirect_costs.cost_category IS 'Category: Admin, PM, Security, Site Office, Utilities, etc.';
COMMENT ON COLUMN project_indirect_costs.allocation_method IS 'How this indirect cost is allocated to activities';
COMMENT ON COLUMN project_indirect_costs.allocation_percentage IS 'Percentage for allocation (if percentage-based method)';

-- Function to calculate and update WBS direct cost totals
CREATE OR REPLACE FUNCTION update_wbs_direct_costs(p_project_id UUID)
RETURNS VOID AS $$
BEGIN
    -- Update WBS nodes with sum of their child activities' direct costs
    UPDATE wbs_nodes 
    SET wbs_direct_cost_total = COALESCE((
        SELECT SUM(direct_cost_total) 
        FROM activities 
        WHERE wbs_node_id = wbs_nodes.id
    ), 0)
    WHERE project_id = p_project_id;
END;
$$ LANGUAGE plpgsql;

-- Function to allocate indirect costs to WBS nodes
CREATE OR REPLACE FUNCTION allocate_indirect_costs(p_project_id UUID)
RETURNS VOID AS $$
DECLARE
    total_direct_cost DECIMAL(15,2);
    total_indirect_cost DECIMAL(15,2);
    allocation_method indirect_allocation_method;
BEGIN
    -- Get project totals and allocation method
    SELECT 
        COALESCE(SUM(wbs_direct_cost_total), 0),
        project_indirect_cost_actual,
        indirect_cost_allocation_method
    INTO total_direct_cost, total_indirect_cost, allocation_method
    FROM projects p
    LEFT JOIN wbs_nodes w ON w.project_id = p.id
    WHERE p.id = p_project_id
    GROUP BY p.id, p.project_indirect_cost_actual, p.indirect_cost_allocation_method;
    
    -- Allocate based on method
    IF allocation_method = 'percentage_of_direct' AND total_direct_cost > 0 THEN
        UPDATE wbs_nodes 
        SET wbs_indirect_cost_allocated = (wbs_direct_cost_total / total_direct_cost) * total_indirect_cost
        WHERE project_id = p_project_id;
    END IF;
    
    -- Add other allocation methods as needed
END;
$$ LANGUAGE plpgsql;

SELECT 'Direct and Indirect cost structure added successfully!' as status;
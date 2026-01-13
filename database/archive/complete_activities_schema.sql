-- Complete Activities Schema Update
-- This adds all missing fields from various schema updates to make activities table complete

-- First, create the enums if they don't exist
DO $$ BEGIN
    CREATE TYPE activity_type AS ENUM ('INTERNAL', 'EXTERNAL', 'SERVICE');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE indirect_allocation_method AS ENUM ('percentage_of_direct', 'duration_based', 'area_based', 'headcount_based', 'fixed_amount');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Add all missing fields to activities table
ALTER TABLE activities 
-- From restructure_activities_tasks.sql
ADD COLUMN IF NOT EXISTS duration_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS progress_percentage DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'not_started',
ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'medium',
ADD COLUMN IF NOT EXISTS assigned_resources TEXT[],
ADD COLUMN IF NOT EXISTS predecessor_activities UUID[],
ADD COLUMN IF NOT EXISTS dependency_type VARCHAR(20) DEFAULT 'finish_to_start',
ADD COLUMN IF NOT EXISTS lag_days INTEGER DEFAULT 0,

-- From add_activity_types.sql
ADD COLUMN IF NOT EXISTS activity_type activity_type DEFAULT 'INTERNAL',
ADD COLUMN IF NOT EXISTS cost_rate DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS assigned_internal_team TEXT[],
ADD COLUMN IF NOT EXISTS vendor_id UUID REFERENCES vendors(id),
ADD COLUMN IF NOT EXISTS rate DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS quantity DECIMAL(15,4) DEFAULT 0,
ADD COLUMN IF NOT EXISTS requires_po BOOLEAN DEFAULT false,

-- From add_direct_indirect_costs.sql
ADD COLUMN IF NOT EXISTS direct_labor_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_material_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_equipment_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_subcontract_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_expense_cost DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS direct_cost_total DECIMAL(15,2) GENERATED ALWAYS AS (
    direct_labor_cost + direct_material_cost + direct_equipment_cost + 
    direct_subcontract_cost + direct_expense_cost
) STORED;

-- Create service_lines table if it doesn't exist
CREATE TABLE IF NOT EXISTS service_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    line_description TEXT NOT NULL,
    quantity DECIMAL(15,4) NOT NULL,
    uom VARCHAR(20) NOT NULL,
    rate DECIMAL(15,2) NOT NULL,
    amount DECIMAL(15,2) GENERATED ALWAYS AS (quantity * rate) STORED,
    actual_quantity DECIMAL(15,4) DEFAULT 0,
    actual_amount DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create activity_dependencies table if it doesn't exist
CREATE TABLE IF NOT EXISTS activity_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    predecessor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    successor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    dependency_type VARCHAR(20) NOT NULL DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(predecessor_activity_id, successor_activity_id)
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_activities_type ON activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_activities_vendor ON activities(vendor_id);
CREATE INDEX IF NOT EXISTS idx_activities_status ON activities(status);
CREATE INDEX IF NOT EXISTS idx_service_lines_activity ON service_lines(activity_id);
CREATE INDEX IF NOT EXISTS idx_activity_dependencies_predecessor ON activity_dependencies(predecessor_activity_id);
CREATE INDEX IF NOT EXISTS idx_activity_dependencies_successor ON activity_dependencies(successor_activity_id);

-- Add comments for clarity
COMMENT ON COLUMN activities.duration_days IS 'Duration in working days';
COMMENT ON COLUMN activities.progress_percentage IS 'Overall activity progress (0-100)';
COMMENT ON COLUMN activities.status IS 'Activity status: not_started, in_progress, on_hold, completed, cancelled';
COMMENT ON COLUMN activities.priority IS 'Activity priority: low, medium, high, critical';
COMMENT ON COLUMN activities.assigned_resources IS 'Array of resource IDs assigned to this activity';
COMMENT ON COLUMN activities.predecessor_activities IS 'Array of predecessor activity IDs';
COMMENT ON COLUMN activities.dependency_type IS 'Default dependency type for this activity';
COMMENT ON COLUMN activities.lag_days IS 'Default lag days for dependencies';

COMMENT ON COLUMN activities.activity_type IS 'Type of activity: INTERNAL (team work), EXTERNAL (vendor), SERVICE (with line items)';
COMMENT ON COLUMN activities.cost_rate IS 'Cost rate per hour for INTERNAL activities';
COMMENT ON COLUMN activities.assigned_internal_team IS 'Array of internal team member IDs for INTERNAL activities';
COMMENT ON COLUMN activities.vendor_id IS 'Vendor ID for EXTERNAL and SERVICE activities';
COMMENT ON COLUMN activities.rate IS 'Rate for EXTERNAL activities';
COMMENT ON COLUMN activities.quantity IS 'Quantity for EXTERNAL activities';
COMMENT ON COLUMN activities.requires_po IS 'Whether activity requires Purchase Order';

COMMENT ON COLUMN activities.direct_labor_cost IS 'Direct labor cost from timesheets';
COMMENT ON COLUMN activities.direct_material_cost IS 'Direct material cost from GRN/inventory';
COMMENT ON COLUMN activities.direct_equipment_cost IS 'Direct equipment cost from equipment logs';
COMMENT ON COLUMN activities.direct_subcontract_cost IS 'Direct subcontractor cost from PO/SES';
COMMENT ON COLUMN activities.direct_expense_cost IS 'Direct expenses (travel, lodging, etc.)';
COMMENT ON COLUMN activities.direct_cost_total IS 'Total direct cost (computed from all direct cost components)';

COMMENT ON TABLE service_lines IS 'Line items for SERVICE type activities (subcontractor BOQ)';
COMMENT ON TABLE activity_dependencies IS 'Dependencies between activities for scheduling';

SELECT 'Complete activities schema updated successfully!' as status;
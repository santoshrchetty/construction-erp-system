-- Add Activity Types and related schema
-- INTERNAL: Internal team work with timesheets
-- EXTERNAL: Vendor/subcontractor work with PO flow
-- SERVICE: Service with multiple line items (subcontractor BOQ)

-- Create activity type enum
CREATE TYPE activity_type AS ENUM ('INTERNAL', 'EXTERNAL', 'SERVICE');

-- Add activity type and related fields to activities table
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS activity_type activity_type DEFAULT 'INTERNAL',
ADD COLUMN IF NOT EXISTS planned_hours DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost_rate DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS assigned_internal_team TEXT[],
ADD COLUMN IF NOT EXISTS vendor_id UUID REFERENCES vendors(id),
ADD COLUMN IF NOT EXISTS rate DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS quantity DECIMAL(15,4) DEFAULT 0,
ADD COLUMN IF NOT EXISTS requires_po BOOLEAN DEFAULT false;

-- Create service_lines table for SERVICE type activities
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

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_activities_type ON activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_activities_vendor ON activities(vendor_id);
CREATE INDEX IF NOT EXISTS idx_service_lines_activity ON service_lines(activity_id);

-- Add comments for clarity
COMMENT ON COLUMN activities.activity_type IS 'Type of activity: INTERNAL (team work), EXTERNAL (vendor), SERVICE (with line items)';
COMMENT ON COLUMN activities.planned_hours IS 'Planned hours for INTERNAL activities';
COMMENT ON COLUMN activities.cost_rate IS 'Cost rate per hour for INTERNAL activities';
COMMENT ON COLUMN activities.assigned_internal_team IS 'Array of internal team member IDs for INTERNAL activities';
COMMENT ON COLUMN activities.vendor_id IS 'Vendor ID for EXTERNAL and SERVICE activities';
COMMENT ON COLUMN activities.rate IS 'Rate for EXTERNAL activities';
COMMENT ON COLUMN activities.quantity IS 'Quantity for EXTERNAL activities';
COMMENT ON COLUMN activities.requires_po IS 'Whether activity requires Purchase Order';

COMMENT ON TABLE service_lines IS 'Line items for SERVICE type activities (subcontractor BOQ)';
COMMENT ON COLUMN service_lines.line_description IS 'Description of the service line item';
COMMENT ON COLUMN service_lines.uom IS 'Unit of measurement (sqm, lm, nos, etc.)';
COMMENT ON COLUMN service_lines.amount IS 'Calculated amount (quantity * rate)';
COMMENT ON COLUMN service_lines.actual_quantity IS 'Actual quantity received/completed';
COMMENT ON COLUMN service_lines.actual_amount IS 'Actual cost posted for this line';

SELECT 'Activity types and service lines added successfully!' as status;
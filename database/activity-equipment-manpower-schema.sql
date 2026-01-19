-- =====================================================
-- ACTIVITY EQUIPMENT & MANPOWER SCHEMA
-- Aligned with activity_materials structure
-- =====================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS activity_manpower CASCADE;
DROP TABLE IF EXISTS activity_equipment CASCADE;

-- Activity Equipment Table
CREATE TABLE activity_equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    equipment_id UUID NOT NULL, -- Reference to equipment master
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    -- Usage details
    required_hours NUMERIC NOT NULL CHECK (required_hours > 0),
    unit_of_measure VARCHAR DEFAULT 'HOUR',
    
    -- Date fields (inherited from activity)
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    -- Tracking
    reserved_hours NUMERIC DEFAULT 0,
    consumed_hours NUMERIC DEFAULT 0,
    
    -- Cost tracking
    hourly_rate NUMERIC DEFAULT 0,
    total_cost NUMERIC GENERATED ALWAYS AS (required_hours * hourly_rate) STORED,
    
    -- Status workflow
    status VARCHAR DEFAULT 'planned' CHECK (status IN ('planned', 'reserved', 'assigned', 'in_use', 'completed')),
    
    -- Priority
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Manpower Table
CREATE TABLE activity_manpower (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employees(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    -- Assignment details
    role VARCHAR NOT NULL, -- e.g., 'Engineer', 'Supervisor', 'Worker'
    required_hours NUMERIC NOT NULL CHECK (required_hours > 0),
    
    -- Date fields (inherited from activity)
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    -- Tracking
    allocated_hours NUMERIC DEFAULT 0,
    actual_hours NUMERIC DEFAULT 0,
    
    -- Cost tracking
    hourly_rate NUMERIC DEFAULT 0,
    total_cost NUMERIC GENERATED ALWAYS AS (required_hours * hourly_rate) STORED,
    
    -- Status workflow
    status VARCHAR DEFAULT 'planned' CHECK (status IN ('planned', 'assigned', 'active', 'completed')),
    
    -- Priority
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for activity_equipment
CREATE INDEX idx_activity_equipment_activity ON activity_equipment(activity_id);
CREATE INDEX idx_activity_equipment_equipment ON activity_equipment(equipment_id);
CREATE INDEX idx_activity_equipment_project ON activity_equipment(project_id);
CREATE INDEX idx_activity_equipment_status ON activity_equipment(status);
CREATE INDEX idx_activity_equipment_dates ON activity_equipment(planned_start_date, planned_end_date);

-- Indexes for activity_manpower
CREATE INDEX idx_activity_manpower_activity ON activity_manpower(activity_id);
CREATE INDEX idx_activity_manpower_employee ON activity_manpower(employee_id);
CREATE INDEX idx_activity_manpower_project ON activity_manpower(project_id);
CREATE INDEX idx_activity_manpower_status ON activity_manpower(status);
CREATE INDEX idx_activity_manpower_dates ON activity_manpower(planned_start_date, planned_end_date);

-- Trigger: Auto-inherit from activity (Equipment)
CREATE OR REPLACE FUNCTION sync_activity_equipment_data()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.planned_start_date IS NULL THEN
        SELECT planned_start_date, planned_end_date, project_id, wbs_node_id
        INTO NEW.planned_start_date, NEW.planned_end_date, NEW.project_id, NEW.wbs_node_id
        FROM activities WHERE id = NEW.activity_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_activity_equipment_data
BEFORE INSERT ON activity_equipment
FOR EACH ROW EXECUTE FUNCTION sync_activity_equipment_data();

-- Trigger: Auto-inherit from activity (Manpower)
CREATE OR REPLACE FUNCTION sync_activity_manpower_data()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.planned_start_date IS NULL THEN
        SELECT planned_start_date, planned_end_date, project_id, wbs_node_id
        INTO NEW.planned_start_date, NEW.planned_end_date, NEW.project_id, NEW.wbs_node_id
        FROM activities WHERE id = NEW.activity_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_activity_manpower_data
BEFORE INSERT ON activity_manpower
FOR EACH ROW EXECUTE FUNCTION sync_activity_manpower_data();

-- Trigger: Update timestamp (Equipment)
CREATE OR REPLACE FUNCTION update_activity_equipment_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_activity_equipment_timestamp
BEFORE UPDATE ON activity_equipment
FOR EACH ROW EXECUTE FUNCTION update_activity_equipment_timestamp();

-- Trigger: Update timestamp (Manpower)
CREATE OR REPLACE FUNCTION update_activity_manpower_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_activity_manpower_timestamp
BEFORE UPDATE ON activity_manpower
FOR EACH ROW EXECUTE FUNCTION update_activity_manpower_timestamp();

SELECT 'Activity Equipment and Manpower tables created' as status;

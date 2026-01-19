-- =====================================================
-- RESOURCE PLANNING - COMPLETE MIGRATION
-- Run this file to set up all 5 resource types
-- =====================================================

-- =====================================================
-- STEP 1: ACTIVITY MATERIALS
-- =====================================================

DROP TABLE IF EXISTS activity_materials CASCADE;

CREATE TABLE activity_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    material_id UUID NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    required_quantity NUMERIC NOT NULL CHECK (required_quantity > 0),
    unit_of_measure VARCHAR NOT NULL,
    planned_consumption_date DATE,
    
    reserved_quantity NUMERIC DEFAULT 0,
    consumed_quantity NUMERIC DEFAULT 0,
    
    unit_cost NUMERIC DEFAULT 0,
    total_cost NUMERIC GENERATED ALWAYS AS (required_quantity * unit_cost) STORED,
    
    status VARCHAR DEFAULT 'planned' CHECK (status IN ('planned', 'reserved', 'issued', 'consumed')),
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    reservation_id UUID,
    demand_line_id UUID,
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_activity_materials_activity ON activity_materials(activity_id);
CREATE INDEX idx_activity_materials_material ON activity_materials(material_id);
CREATE INDEX idx_activity_materials_project ON activity_materials(project_id);
CREATE INDEX idx_activity_materials_status ON activity_materials(status);

CREATE OR REPLACE FUNCTION sync_activity_materials_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.planned_consumption_date IS NULL THEN
        SELECT planned_start_date INTO NEW.planned_consumption_date
        FROM activities WHERE id = NEW.activity_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_activity_materials_date
BEFORE INSERT ON activity_materials
FOR EACH ROW EXECUTE FUNCTION sync_activity_materials_date();

-- =====================================================
-- STEP 2: ACTIVITY EQUIPMENT & MANPOWER
-- =====================================================

DROP TABLE IF EXISTS activity_manpower CASCADE;
DROP TABLE IF EXISTS activity_equipment CASCADE;

CREATE TABLE activity_equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    equipment_id UUID NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    required_hours NUMERIC NOT NULL CHECK (required_hours > 0),
    unit_of_measure VARCHAR DEFAULT 'HOUR',
    
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    reserved_hours NUMERIC DEFAULT 0,
    consumed_hours NUMERIC DEFAULT 0,
    
    hourly_rate NUMERIC DEFAULT 0,
    total_cost NUMERIC GENERATED ALWAYS AS (required_hours * hourly_rate) STORED,
    
    status VARCHAR DEFAULT 'planned' CHECK (status IN ('planned', 'reserved', 'assigned', 'in_use', 'completed')),
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE activity_manpower (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employees(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    role VARCHAR NOT NULL,
    required_hours NUMERIC NOT NULL CHECK (required_hours > 0),
    
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    allocated_hours NUMERIC DEFAULT 0,
    actual_hours NUMERIC DEFAULT 0,
    
    hourly_rate NUMERIC DEFAULT 0,
    total_cost NUMERIC GENERATED ALWAYS AS (required_hours * hourly_rate) STORED,
    
    status VARCHAR DEFAULT 'planned' CHECK (status IN ('planned', 'assigned', 'active', 'completed')),
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_activity_equipment_activity ON activity_equipment(activity_id);
CREATE INDEX idx_activity_equipment_equipment ON activity_equipment(equipment_id);
CREATE INDEX idx_activity_equipment_project ON activity_equipment(project_id);
CREATE INDEX idx_activity_equipment_status ON activity_equipment(status);

CREATE INDEX idx_activity_manpower_activity ON activity_manpower(activity_id);
CREATE INDEX idx_activity_manpower_employee ON activity_manpower(employee_id);
CREATE INDEX idx_activity_manpower_project ON activity_manpower(project_id);
CREATE INDEX idx_activity_manpower_status ON activity_manpower(status);

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

-- =====================================================
-- STEP 3: ACTIVITY SERVICES & SUBCONTRACTORS
-- =====================================================

DROP TABLE IF EXISTS activity_subcontractors CASCADE;
DROP TABLE IF EXISTS activity_services CASCADE;

CREATE TABLE activity_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    service_provider_id UUID REFERENCES vendors(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    service_type VARCHAR NOT NULL CHECK (service_type IN ('testing', 'inspection', 'certification', 'survey', 'commissioning', 'other')),
    service_description TEXT NOT NULL,
    
    scheduled_date DATE,
    duration_hours NUMERIC DEFAULT 1 CHECK (duration_hours > 0),
    actual_date DATE,
    
    planned_start_date DATE,
    planned_end_date DATE,
    
    unit_cost NUMERIC DEFAULT 0,
    total_cost NUMERIC DEFAULT 0,
    
    status VARCHAR DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'failed', 'cancelled')),
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    result VARCHAR CHECK (result IN ('passed', 'failed', 'conditional', NULL)),
    result_document_url TEXT,
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE activity_subcontractors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    subcontractor_id UUID NOT NULL REFERENCES vendors(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    trade VARCHAR NOT NULL,
    scope_of_work TEXT NOT NULL,
    
    contract_id UUID,
    contract_number VARCHAR,
    
    crew_size INTEGER DEFAULT 1,
    
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    mobilization_date DATE,
    
    contract_value NUMERIC DEFAULT 0,
    paid_to_date NUMERIC DEFAULT 0,
    retention_amount NUMERIC DEFAULT 0,
    
    progress_percentage NUMERIC DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    
    status VARCHAR DEFAULT 'awarded' CHECK (status IN ('awarded', 'mobilized', 'in_progress', 'suspended', 'completed', 'terminated')),
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    performance_rating INTEGER CHECK (performance_rating BETWEEN 1 AND 5),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_activity_services_activity ON activity_services(activity_id);
CREATE INDEX idx_activity_services_provider ON activity_services(service_provider_id);
CREATE INDEX idx_activity_services_project ON activity_services(project_id);
CREATE INDEX idx_activity_services_type ON activity_services(service_type);
CREATE INDEX idx_activity_services_status ON activity_services(status);

CREATE INDEX idx_activity_subcontractors_activity ON activity_subcontractors(activity_id);
CREATE INDEX idx_activity_subcontractors_vendor ON activity_subcontractors(subcontractor_id);
CREATE INDEX idx_activity_subcontractors_project ON activity_subcontractors(project_id);
CREATE INDEX idx_activity_subcontractors_trade ON activity_subcontractors(trade);
CREATE INDEX idx_activity_subcontractors_status ON activity_subcontractors(status);

CREATE OR REPLACE FUNCTION sync_activity_services_data()
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

CREATE TRIGGER trg_sync_activity_services_data
BEFORE INSERT ON activity_services
FOR EACH ROW EXECUTE FUNCTION sync_activity_services_data();

CREATE OR REPLACE FUNCTION sync_activity_subcontractors_data()
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

CREATE TRIGGER trg_sync_activity_subcontractors_data
BEFORE INSERT ON activity_subcontractors
FOR EACH ROW EXECUTE FUNCTION sync_activity_subcontractors_data();

-- =====================================================
-- STEP 4: PERFORMANCE OPTIMIZATION
-- =====================================================

DROP MATERIALIZED VIEW IF EXISTS mv_activities_resource_status CASCADE;
DROP INDEX IF EXISTS idx_activities_date_range;
DROP INDEX IF EXISTS idx_activities_status_priority;
DROP INDEX IF EXISTS idx_activities_project_wbs;
DROP INDEX IF EXISTS idx_activity_materials_status_date;

CREATE INDEX idx_activities_date_range ON activities(planned_start_date, planned_end_date) 
WHERE is_active = true;

CREATE INDEX idx_activities_status_priority ON activities(status, priority) 
WHERE is_active = true;

CREATE INDEX idx_activities_project_wbs ON activities(project_id, wbs_node_id);

CREATE INDEX idx_activity_materials_status_date ON activity_materials(status, planned_consumption_date);

CREATE MATERIALIZED VIEW mv_activities_resource_status AS
SELECT 
    a.id AS activity_id,
    a.project_id,
    a.wbs_node_id,
    a.code,
    a.name,
    a.planned_start_date,
    a.planned_end_date,
    a.status,
    a.priority,
    
    COALESCE((SELECT COUNT(*) FROM activity_materials am WHERE am.activity_id = a.id), 0) AS material_count,
    COALESCE((SELECT COUNT(*) FROM activity_equipment ae WHERE ae.activity_id = a.id), 0) AS equipment_count,
    COALESCE((SELECT COUNT(*) FROM activity_manpower amp WHERE amp.activity_id = a.id), 0) AS manpower_count,
    COALESCE((SELECT COUNT(*) FROM activity_services asv WHERE asv.activity_id = a.id), 0) AS services_count,
    COALESCE((SELECT COUNT(*) FROM activity_subcontractors asub WHERE asub.activity_id = a.id), 0) AS subcontractor_count,
    
    EXISTS(SELECT 1 FROM activity_materials am WHERE am.activity_id = a.id) AS has_materials,
    EXISTS(SELECT 1 FROM activity_equipment ae WHERE ae.activity_id = a.id) AS has_equipment,
    EXISTS(SELECT 1 FROM activity_manpower amp WHERE amp.activity_id = a.id) AS has_manpower,
    EXISTS(SELECT 1 FROM activity_services asv WHERE asv.activity_id = a.id) AS has_services,
    EXISTS(SELECT 1 FROM activity_subcontractors asub WHERE asub.activity_id = a.id) AS has_subcontractors,
    
    CASE 
        WHEN NOT EXISTS(SELECT 1 FROM activity_materials am WHERE am.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_equipment ae WHERE ae.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_manpower amp WHERE amp.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_services asv WHERE asv.activity_id = a.id)
         AND NOT EXISTS(SELECT 1 FROM activity_subcontractors asub WHERE asub.activity_id = a.id)
        THEN 'missing'
        WHEN EXISTS(SELECT 1 FROM activity_materials am WHERE am.activity_id = a.id AND am.status = 'planned')
          OR EXISTS(SELECT 1 FROM activity_equipment ae WHERE ae.activity_id = a.id AND ae.status = 'planned')
          OR EXISTS(SELECT 1 FROM activity_manpower amp WHERE amp.activity_id = a.id AND amp.status = 'planned')
          OR EXISTS(SELECT 1 FROM activity_services asv WHERE asv.activity_id = a.id AND asv.status = 'scheduled')
          OR EXISTS(SELECT 1 FROM activity_subcontractors asub WHERE asub.activity_id = a.id AND asub.status = 'awarded')
        THEN 'partial'
        ELSE 'complete'
    END AS resource_status,
    
    CASE 
        WHEN a.planned_start_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'urgent'
        WHEN a.planned_start_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'soon'
        ELSE 'future'
    END AS time_priority
    
FROM activities a
WHERE a.is_active = true
  AND a.status NOT IN ('completed', 'cancelled');

CREATE INDEX idx_mv_resource_status ON mv_activities_resource_status(resource_status, time_priority);
CREATE INDEX idx_mv_date_range ON mv_activities_resource_status(planned_start_date);
CREATE INDEX idx_mv_project ON mv_activities_resource_status(project_id);

REFRESH MATERIALIZED VIEW mv_activities_resource_status;

SELECT 'Resource Planning - All 5 resource types created successfully!' as status;

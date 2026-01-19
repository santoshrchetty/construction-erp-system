-- =====================================================
-- ACTIVITY SERVICES & SUBCONTRACTORS SCHEMA
-- Completes the 5-tab Resource Planning system
-- =====================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS activity_subcontractors CASCADE;
DROP TABLE IF EXISTS activity_services CASCADE;

-- Activity Services Table (Testing, Inspections, Certifications)
CREATE TABLE activity_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    service_provider_id UUID REFERENCES vendors(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    -- Service details
    service_type VARCHAR NOT NULL CHECK (service_type IN ('testing', 'inspection', 'certification', 'survey', 'commissioning', 'other')),
    service_description TEXT NOT NULL,
    
    -- Scheduling
    scheduled_date DATE,
    duration_hours NUMERIC DEFAULT 1 CHECK (duration_hours > 0),
    actual_date DATE,
    
    -- Date fields (inherited from activity)
    planned_start_date DATE,
    planned_end_date DATE,
    
    -- Cost tracking
    unit_cost NUMERIC DEFAULT 0,
    total_cost NUMERIC DEFAULT 0,
    
    -- Status workflow
    status VARCHAR DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'failed', 'cancelled')),
    
    -- Priority
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    -- Results
    result VARCHAR CHECK (result IN ('passed', 'failed', 'conditional', NULL)),
    result_document_url TEXT,
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Subcontractors Table (Trade Work)
CREATE TABLE activity_subcontractors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    subcontractor_id UUID NOT NULL REFERENCES vendors(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    -- Subcontractor details
    trade VARCHAR NOT NULL, -- electrical, plumbing, HVAC, concrete, steel, finishes, etc.
    scope_of_work TEXT NOT NULL,
    
    -- Contract reference
    contract_id UUID, -- Link to purchase_orders or contracts table
    contract_number VARCHAR,
    
    -- Resource allocation
    crew_size INTEGER DEFAULT 1,
    
    -- Date fields (inherited from activity)
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    mobilization_date DATE,
    
    -- Cost tracking
    contract_value NUMERIC DEFAULT 0,
    paid_to_date NUMERIC DEFAULT 0,
    retention_amount NUMERIC DEFAULT 0,
    
    -- Progress tracking
    progress_percentage NUMERIC DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    
    -- Status workflow
    status VARCHAR DEFAULT 'awarded' CHECK (status IN ('awarded', 'mobilized', 'in_progress', 'suspended', 'completed', 'terminated')),
    
    -- Priority
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    -- Performance tracking
    performance_rating INTEGER CHECK (performance_rating BETWEEN 1 AND 5),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for activity_services
CREATE INDEX idx_activity_services_activity ON activity_services(activity_id);
CREATE INDEX idx_activity_services_provider ON activity_services(service_provider_id);
CREATE INDEX idx_activity_services_project ON activity_services(project_id);
CREATE INDEX idx_activity_services_type ON activity_services(service_type);
CREATE INDEX idx_activity_services_status ON activity_services(status);
CREATE INDEX idx_activity_services_date ON activity_services(scheduled_date);

-- Indexes for activity_subcontractors
CREATE INDEX idx_activity_subcontractors_activity ON activity_subcontractors(activity_id);
CREATE INDEX idx_activity_subcontractors_vendor ON activity_subcontractors(subcontractor_id);
CREATE INDEX idx_activity_subcontractors_project ON activity_subcontractors(project_id);
CREATE INDEX idx_activity_subcontractors_trade ON activity_subcontractors(trade);
CREATE INDEX idx_activity_subcontractors_status ON activity_subcontractors(status);
CREATE INDEX idx_activity_subcontractors_dates ON activity_subcontractors(planned_start_date, planned_end_date);

-- Trigger: Auto-inherit from activity (Services)
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

-- Trigger: Auto-inherit from activity (Subcontractors)
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

-- Trigger: Update timestamp (Services)
CREATE OR REPLACE FUNCTION update_activity_services_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_activity_services_timestamp
BEFORE UPDATE ON activity_services
FOR EACH ROW EXECUTE FUNCTION update_activity_services_timestamp();

-- Trigger: Update timestamp (Subcontractors)
CREATE OR REPLACE FUNCTION update_activity_subcontractors_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_activity_subcontractors_timestamp
BEFORE UPDATE ON activity_subcontractors
FOR EACH ROW EXECUTE FUNCTION update_activity_subcontractors_timestamp();

SELECT 'Activity Services and Subcontractors tables created' as status;

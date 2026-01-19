-- =====================================================
-- ACTIVITY MATERIALS - Link materials to activities with date inheritance
-- ALIGNED WITH: material_reservations, demand_lines, stock_balances
-- =====================================================

-- Create activity_materials table
CREATE TABLE activity_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    
    -- Quantity fields (aligned with demand_lines)
    required_quantity NUMERIC NOT NULL CHECK (required_quantity > 0),
    unit_of_measure VARCHAR NOT NULL,
    
    -- Date fields (inherited from activity)
    planned_consumption_date DATE,
    actual_consumption_date DATE,
    
    -- Reservation tracking (aligned with stock_balances.reserved_quantity)
    reserved_quantity NUMERIC DEFAULT 0,
    consumed_quantity NUMERIC DEFAULT 0,
    
    -- Cost tracking
    unit_cost NUMERIC DEFAULT 0,
    total_cost NUMERIC GENERATED ALWAYS AS (required_quantity * unit_cost) STORED,
    
    -- Status workflow
    status VARCHAR DEFAULT 'planned' CHECK (status IN ('planned', 'reserved', 'issued', 'consumed')),
    
    -- Priority (aligned with demand_lines.priority_level)
    priority_level VARCHAR DEFAULT 'normal' CHECK (priority_level IN ('critical', 'high', 'normal', 'low')),
    
    -- Links to other tables
    reservation_id UUID, -- Link to material_reservations if created
    demand_line_id UUID, -- Link to demand_lines if MRP run
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_activity_materials_activity ON activity_materials(activity_id);
CREATE INDEX idx_activity_materials_material ON activity_materials(material_id);
CREATE INDEX idx_activity_materials_project ON activity_materials(project_id);
CREATE INDEX idx_activity_materials_status ON activity_materials(status);

-- Trigger: Auto-inherit from activity
CREATE OR REPLACE FUNCTION sync_activity_material_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Inherit date from activity if not set
    IF NEW.planned_consumption_date IS NULL THEN
        SELECT planned_start_date, project_id, wbs_node_id
        INTO NEW.planned_consumption_date, NEW.project_id, NEW.wbs_node_id
        FROM activities WHERE id = NEW.activity_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_activity_material_data
BEFORE INSERT ON activity_materials
FOR EACH ROW EXECUTE FUNCTION sync_activity_material_data();

-- Trigger: Update stock_balances.reserved_quantity when status changes to 'reserved'
CREATE OR REPLACE FUNCTION update_stock_reservation()
RETURNS TRIGGER AS $$
BEGIN
    -- When status changes to 'reserved', update stock_balances
    IF NEW.status = 'reserved' AND OLD.status != 'reserved' THEN
        UPDATE stock_balances sb
        SET reserved_quantity = reserved_quantity + NEW.required_quantity
        FROM stock_items si
        WHERE si.id = sb.stock_item_id
          AND si.item_code = (SELECT material_code FROM materials WHERE id = NEW.material_id);
        
        NEW.reserved_quantity = NEW.required_quantity;
    END IF;
    
    -- When status changes from 'reserved' to something else, release reservation
    IF OLD.status = 'reserved' AND NEW.status != 'reserved' THEN
        UPDATE stock_balances sb
        SET reserved_quantity = reserved_quantity - OLD.reserved_quantity
        FROM stock_items si
        WHERE si.id = sb.stock_item_id
          AND si.item_code = (SELECT material_code FROM materials WHERE id = OLD.material_id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock_reservation
BEFORE UPDATE ON activity_materials
FOR EACH ROW EXECUTE FUNCTION update_stock_reservation();

-- Trigger: Update timestamp
CREATE OR REPLACE FUNCTION update_activity_materials_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_activity_materials_timestamp
BEFORE UPDATE ON activity_materials
FOR EACH ROW EXECUTE FUNCTION update_activity_materials_timestamp();

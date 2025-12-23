-- Add triggers for automatic cost roll-up calculations

-- Function to update WBS cost totals when activities change
CREATE OR REPLACE FUNCTION update_wbs_costs_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Update WBS node direct cost total
    UPDATE wbs_nodes 
    SET wbs_direct_cost_total = (
        SELECT COALESCE(SUM(direct_cost_total), 0)
        FROM activities 
        WHERE wbs_node_id = COALESCE(NEW.wbs_node_id, OLD.wbs_node_id)
    )
    WHERE id = COALESCE(NEW.wbs_node_id, OLD.wbs_node_id);
    
    -- If activity moved between WBS nodes, update both
    IF TG_OP = 'UPDATE' AND OLD.wbs_node_id != NEW.wbs_node_id THEN
        UPDATE wbs_nodes 
        SET wbs_direct_cost_total = (
            SELECT COALESCE(SUM(direct_cost_total), 0)
            FROM activities 
            WHERE wbs_node_id = OLD.wbs_node_id
        )
        WHERE id = OLD.wbs_node_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Function to update project cost totals when WBS changes
CREATE OR REPLACE FUNCTION update_project_costs_trigger()
RETURNS TRIGGER AS $$
DECLARE
    project_id_val UUID;
BEGIN
    -- Get project ID from WBS node
    SELECT project_id INTO project_id_val
    FROM wbs_nodes 
    WHERE id = COALESCE(NEW.id, OLD.id);
    
    -- Update project direct cost total
    UPDATE projects 
    SET project_direct_cost_total = (
        SELECT COALESCE(SUM(wbs_direct_cost_total), 0)
        FROM wbs_nodes 
        WHERE project_id = project_id_val
    )
    WHERE id = project_id_val;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS activity_cost_rollup_trigger ON activities;
CREATE TRIGGER activity_cost_rollup_trigger
    AFTER INSERT OR UPDATE OR DELETE ON activities
    FOR EACH ROW
    EXECUTE FUNCTION update_wbs_costs_trigger();

DROP TRIGGER IF EXISTS wbs_cost_rollup_trigger ON wbs_nodes;
CREATE TRIGGER wbs_cost_rollup_trigger
    AFTER UPDATE ON wbs_nodes
    FOR EACH ROW
    WHEN (OLD.wbs_direct_cost_total IS DISTINCT FROM NEW.wbs_direct_cost_total)
    EXECUTE FUNCTION update_project_costs_trigger();

-- Add project_direct_cost_total column if it doesn't exist
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS project_direct_cost_total DECIMAL(15,2) DEFAULT 0;
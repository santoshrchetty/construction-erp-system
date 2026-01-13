-- Dynamic Stores Enhancement for Construction Management SaaS
-- =====================================================

-- Add site support to projects
ALTER TABLE projects ADD COLUMN site_code VARCHAR(10);
ALTER TABLE projects ADD COLUMN site_name VARCHAR(255);

-- Enhanced stores table with auto-creation support
ALTER TABLE stores ADD COLUMN is_auto_created BOOLEAN DEFAULT false;
ALTER TABLE stores ADD COLUMN site_code VARCHAR(10);
ALTER TABLE stores ADD COLUMN auto_delete_when_empty BOOLEAN DEFAULT true;

-- FIFO inventory tracking table
CREATE TABLE stock_fifo_layers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    stock_item_id UUID NOT NULL REFERENCES stock_items(id) ON DELETE CASCADE,
    batch_reference VARCHAR(100) NOT NULL,
    receipt_date TIMESTAMP WITH TIME ZONE NOT NULL,
    original_quantity DECIMAL(15,4) NOT NULL,
    remaining_quantity DECIMAL(15,4) NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    grn_line_id UUID REFERENCES grn_lines(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_remaining_quantity CHECK (remaining_quantity >= 0)
);

-- Index for FIFO processing
CREATE INDEX idx_stock_fifo_layers_fifo ON stock_fifo_layers(store_id, stock_item_id, receipt_date);

-- Function to auto-create store for material receipt
CREATE OR REPLACE FUNCTION auto_create_store_for_receipt()
RETURNS TRIGGER AS $$
DECLARE
    project_rec RECORD;
    store_rec RECORD;
    store_code VARCHAR(50);
    store_name VARCHAR(255);
BEGIN
    -- Get project details
    SELECT p.*, po.project_id 
    INTO project_rec 
    FROM projects p
    JOIN purchase_orders po ON po.project_id = p.id
    WHERE po.id = NEW.po_id;
    
    -- Generate store code and name
    store_code := COALESCE(project_rec.site_code, 'MAIN') || '-STORE-' || EXTRACT(YEAR FROM NOW());
    store_name := project_rec.name || ' - ' || COALESCE(project_rec.site_name, 'Main Site') || ' Store';
    
    -- Check if store already exists for this project/site
    SELECT * INTO store_rec 
    FROM stores 
    WHERE project_id = project_rec.id 
    AND site_code = COALESCE(project_rec.site_code, 'MAIN')
    AND is_active = true;
    
    -- Create store if it doesn't exist
    IF store_rec IS NULL THEN
        INSERT INTO stores (
            project_id, 
            name, 
            code, 
            location, 
            site_code,
            is_auto_created,
            auto_delete_when_empty,
            is_active
        ) VALUES (
            project_rec.id,
            store_name,
            store_code,
            project_rec.location,
            COALESCE(project_rec.site_code, 'MAIN'),
            true,
            true,
            true
        );
        
        -- Update the GRN with the new store
        UPDATE goods_receipts 
        SET store_id = (
            SELECT id FROM stores 
            WHERE project_id = project_rec.id 
            AND site_code = COALESCE(project_rec.site_code, 'MAIN')
            AND is_auto_created = true
            ORDER BY created_at DESC 
            LIMIT 1
        )
        WHERE id = NEW.grn_id;
    ELSE
        -- Use existing store
        UPDATE goods_receipts 
        SET store_id = store_rec.id
        WHERE id = NEW.grn_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-create store on GRN creation
CREATE TRIGGER trigger_auto_create_store
    BEFORE INSERT ON grn_lines
    FOR EACH ROW
    EXECUTE FUNCTION auto_create_store_for_receipt();

-- Function to create FIFO layers on stock receipt
CREATE OR REPLACE FUNCTION create_fifo_layer()
RETURNS TRIGGER AS $$
DECLARE
    grn_rec RECORD;
    store_id_val UUID;
BEGIN
    -- Get GRN and store details
    SELECT gr.store_id, gr.grn_number, gr.receipt_date
    INTO grn_rec
    FROM goods_receipts gr
    WHERE gr.id = NEW.grn_id;
    
    store_id_val := grn_rec.store_id;
    
    -- Create FIFO layer for received quantity
    INSERT INTO stock_fifo_layers (
        store_id,
        stock_item_id,
        batch_reference,
        receipt_date,
        original_quantity,
        remaining_quantity,
        unit_cost,
        grn_line_id
    ) VALUES (
        store_id_val,
        (SELECT si.id FROM stock_items si 
         JOIN po_lines pl ON pl.description = si.description 
         WHERE pl.id = NEW.po_line_id LIMIT 1),
        grn_rec.grn_number || '-' || NEW.id,
        grn_rec.receipt_date,
        NEW.accepted_quantity,
        NEW.accepted_quantity,
        NEW.unit_rate,
        NEW.id
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create FIFO layers on GRN line creation
CREATE TRIGGER trigger_create_fifo_layer
    AFTER INSERT ON grn_lines
    FOR EACH ROW
    EXECUTE FUNCTION create_fifo_layer();

-- Function to process FIFO stock issues
CREATE OR REPLACE FUNCTION process_fifo_issue(
    p_store_id UUID,
    p_stock_item_id UUID,
    p_issue_quantity DECIMAL(15,4)
) RETURNS TABLE(
    layer_id UUID,
    quantity_used DECIMAL(15,4),
    unit_cost DECIMAL(15,2),
    total_cost DECIMAL(15,2)
) AS $$
DECLARE
    layer_rec RECORD;
    remaining_to_issue DECIMAL(15,4) := p_issue_quantity;
    quantity_from_layer DECIMAL(15,4);
BEGIN
    -- Process FIFO layers in order (oldest first)
    FOR layer_rec IN 
        SELECT * FROM stock_fifo_layers 
        WHERE store_id = p_store_id 
        AND stock_item_id = p_stock_item_id 
        AND remaining_quantity > 0
        ORDER BY receipt_date, created_at
    LOOP
        EXIT WHEN remaining_to_issue <= 0;
        
        -- Calculate quantity to use from this layer
        quantity_from_layer := LEAST(layer_rec.remaining_quantity, remaining_to_issue);
        
        -- Update layer remaining quantity
        UPDATE stock_fifo_layers 
        SET remaining_quantity = remaining_quantity - quantity_from_layer
        WHERE id = layer_rec.id;
        
        -- Return layer usage details
        layer_id := layer_rec.id;
        quantity_used := quantity_from_layer;
        unit_cost := layer_rec.unit_cost;
        total_cost := quantity_from_layer * layer_rec.unit_cost;
        
        RETURN NEXT;
        
        remaining_to_issue := remaining_to_issue - quantity_from_layer;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to auto-delete empty stores
CREATE OR REPLACE FUNCTION auto_delete_empty_stores()
RETURNS TRIGGER AS $$
DECLARE
    store_rec RECORD;
    total_stock DECIMAL(15,4);
BEGIN
    -- Check if this affects an auto-created store
    SELECT s.* INTO store_rec
    FROM stores s
    WHERE s.id = NEW.store_id
    AND s.is_auto_created = true
    AND s.auto_delete_when_empty = true;
    
    IF store_rec IS NOT NULL THEN
        -- Calculate total stock in store
        SELECT COALESCE(SUM(current_quantity), 0) INTO total_stock
        FROM stock_balances
        WHERE store_id = store_rec.id;
        
        -- Delete store if empty
        IF total_stock = 0 THEN
            UPDATE stores 
            SET is_active = false, 
                updated_at = NOW()
            WHERE id = store_rec.id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-delete empty stores
CREATE TRIGGER trigger_auto_delete_empty_stores
    AFTER UPDATE ON stock_balances
    FOR EACH ROW
    WHEN (NEW.current_quantity = 0 AND OLD.current_quantity > 0)
    EXECUTE FUNCTION auto_delete_empty_stores();

-- Enhanced stock movement function with FIFO
CREATE OR REPLACE FUNCTION create_stock_movement_with_fifo(
    p_store_id UUID,
    p_stock_item_id UUID,
    p_movement_type movement_type,
    p_reference_number VARCHAR(100),
    p_reference_type VARCHAR(50),
    p_reference_id UUID,
    p_quantity DECIMAL(15,4),
    p_unit_cost DECIMAL(15,2),
    p_movement_date DATE,
    p_created_by UUID,
    p_notes TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    movement_id UUID;
    fifo_rec RECORD;
    total_cost DECIMAL(15,2) := 0;
BEGIN
    -- Create stock movement record
    INSERT INTO stock_movements (
        store_id, stock_item_id, movement_type, reference_number,
        reference_type, reference_id, quantity, unit_cost,
        movement_date, created_by, notes
    ) VALUES (
        p_store_id, p_stock_item_id, p_movement_type, p_reference_number,
        p_reference_type, p_reference_id, p_quantity, p_unit_cost,
        p_movement_date, p_created_by, p_notes
    ) RETURNING id INTO movement_id;
    
    -- For issues, process FIFO and calculate actual cost
    IF p_movement_type = 'issue' THEN
        FOR fifo_rec IN 
            SELECT * FROM process_fifo_issue(p_store_id, p_stock_item_id, p_quantity)
        LOOP
            total_cost := total_cost + fifo_rec.total_cost;
        END LOOP;
        
        -- Update movement with actual FIFO cost
        UPDATE stock_movements 
        SET unit_cost = total_cost / p_quantity
        WHERE id = movement_id;
    END IF;
    
    RETURN movement_id;
END;
$$ LANGUAGE plpgsql;

-- View for current stock with FIFO valuation
CREATE OR REPLACE VIEW stock_balances_fifo AS
SELECT 
    sb.store_id,
    sb.stock_item_id,
    sb.current_quantity,
    sb.reserved_quantity,
    sb.available_quantity,
    COALESCE(
        (SELECT SUM(sfl.remaining_quantity * sfl.unit_cost) / NULLIF(SUM(sfl.remaining_quantity), 0)
         FROM stock_fifo_layers sfl 
         WHERE sfl.store_id = sb.store_id 
         AND sfl.stock_item_id = sb.stock_item_id 
         AND sfl.remaining_quantity > 0), 0
    ) as fifo_average_cost,
    COALESCE(
        (SELECT SUM(sfl.remaining_quantity * sfl.unit_cost)
         FROM stock_fifo_layers sfl 
         WHERE sfl.store_id = sb.store_id 
         AND sfl.stock_item_id = sb.stock_item_id 
         AND sfl.remaining_quantity > 0), 0
    ) as fifo_total_value,
    sb.last_movement_date
FROM stock_balances sb;

-- Indexes for performance
CREATE INDEX idx_stores_site_code ON stores(site_code, project_id);
CREATE INDEX idx_stores_auto_created ON stores(is_auto_created, auto_delete_when_empty);
CREATE INDEX idx_stock_fifo_layers_store_item ON stock_fifo_layers(store_id, stock_item_id);
CREATE INDEX idx_stock_fifo_layers_remaining ON stock_fifo_layers(remaining_quantity) WHERE remaining_quantity > 0;
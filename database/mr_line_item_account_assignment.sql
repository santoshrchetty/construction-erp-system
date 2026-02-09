-- Update material_request_items table to include org units and account assignment fields
-- Required for Copy to PR functionality

ALTER TABLE material_request_items 
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS plant_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS storage_location VARCHAR(10),
ADD COLUMN IF NOT EXISTS purchasing_group VARCHAR(10),
ADD COLUMN IF NOT EXISTS purchasing_organization VARCHAR(10),

-- Account Assignment Fields
ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(10) CHECK (account_assignment_category IN ('K', 'P', 'A', 'F', 'O', 'N', 'S', 'U')), -- K=Cost Center, P=Project, A=Asset, F=Order, O=Sales Order, N=Network, S=Cost Object, U=Unknown
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20),
ADD COLUMN IF NOT EXISTS project_code VARCHAR(50),
ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(50),
ADD COLUMN IF NOT EXISTS activity_code VARCHAR(50),
ADD COLUMN IF NOT EXISTS internal_order VARCHAR(20),
ADD COLUMN IF NOT EXISTS asset_number VARCHAR(20),
ADD COLUMN IF NOT EXISTS sales_order VARCHAR(20),
ADD COLUMN IF NOT EXISTS sales_order_item VARCHAR(10),
ADD COLUMN IF NOT EXISTS network_number VARCHAR(20),
ADD COLUMN IF NOT EXISTS network_activity VARCHAR(20),
ADD COLUMN IF NOT EXISTS profit_center VARCHAR(20),
ADD COLUMN IF NOT EXISTS gl_account VARCHAR(20),

-- Additional PR-specific fields
ADD COLUMN IF NOT EXISTS material_group VARCHAR(20),
ADD COLUMN IF NOT EXISTS supplier_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS purchase_info_record VARCHAR(20),
ADD COLUMN IF NOT EXISTS delivery_date DATE,
ADD COLUMN IF NOT EXISTS price_per_unit DECIMAL(15,2),
ADD COLUMN IF NOT EXISTS price_unit INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'GBP',
ADD COLUMN IF NOT EXISTS tax_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS delivery_address TEXT,
ADD COLUMN IF NOT EXISTS requisitioner VARCHAR(50),
ADD COLUMN IF NOT EXISTS tracking_number VARCHAR(50);

-- Create account assignment validation function
CREATE OR REPLACE FUNCTION validate_account_assignment()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate account assignment based on category
    CASE NEW.account_assignment_category
        WHEN 'K' THEN -- Cost Center
            IF NEW.cost_center IS NULL THEN
                RAISE EXCEPTION 'Cost Center is required for account assignment category K';
            END IF;
        WHEN 'P' THEN -- Project/WBS
            IF NEW.project_code IS NULL AND NEW.wbs_element IS NULL THEN
                RAISE EXCEPTION 'Project Code or WBS Element is required for account assignment category P';
            END IF;
        WHEN 'A' THEN -- Asset
            IF NEW.asset_number IS NULL THEN
                RAISE EXCEPTION 'Asset Number is required for account assignment category A';
            END IF;
        WHEN 'F' THEN -- Internal Order
            IF NEW.internal_order IS NULL THEN
                RAISE EXCEPTION 'Internal Order is required for account assignment category F';
            END IF;
        WHEN 'O' THEN -- Sales Order
            IF NEW.sales_order IS NULL THEN
                RAISE EXCEPTION 'Sales Order is required for account assignment category O';
            END IF;
        WHEN 'N' THEN -- Network
            IF NEW.network_number IS NULL THEN
                RAISE EXCEPTION 'Network Number is required for account assignment category N';
            END IF;
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for account assignment validation
DROP TRIGGER IF EXISTS validate_account_assignment_trigger ON material_request_items;
CREATE TRIGGER validate_account_assignment_trigger
    BEFORE INSERT OR UPDATE ON material_request_items
    FOR EACH ROW
    WHEN (NEW.account_assignment_category IS NOT NULL)
    EXECUTE FUNCTION validate_account_assignment();

-- Create purchase requisitions table (target for Copy to PR)
CREATE TABLE IF NOT EXISTS purchase_requisitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pr_number VARCHAR(50) UNIQUE NOT NULL,
    pr_type VARCHAR(20) DEFAULT 'NB' CHECK (pr_type IN ('NB', 'UB', 'KB', 'LB')), -- NB=Standard, UB=Stock Transfer, KB=Consignment, LB=Subcontracting
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'RELEASED', 'ORDERED', 'CLOSED', 'CANCELLED')),
    priority VARCHAR(10) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    created_from_mr VARCHAR(50), -- Reference to source MR
    company_code VARCHAR(10) NOT NULL,
    purchasing_organization VARCHAR(10) NOT NULL,
    purchasing_group VARCHAR(10),
    requested_by VARCHAR(50) NOT NULL,
    created_date DATE DEFAULT CURRENT_DATE,
    total_value DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'GBP',
    approval_status VARCHAR(20) DEFAULT 'PENDING',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_by VARCHAR(50)
);

-- Create purchase requisition items table
CREATE TABLE IF NOT EXISTS purchase_requisition_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pr_id UUID NOT NULL REFERENCES purchase_requisitions(id) ON DELETE CASCADE,
    pr_item_number VARCHAR(10) NOT NULL,
    material_request_item_id UUID REFERENCES material_request_items(id), -- Link back to source MR item
    material_code VARCHAR(50) NOT NULL,
    short_text TEXT,
    quantity DECIMAL(15,3) NOT NULL,
    unit_of_measure VARCHAR(10) NOT NULL,
    delivery_date DATE NOT NULL,
    plant_code VARCHAR(10),
    storage_location VARCHAR(10),
    material_group VARCHAR(20),
    
    -- Pricing
    price_per_unit DECIMAL(15,2),
    price_unit INTEGER DEFAULT 1,
    currency VARCHAR(3) DEFAULT 'GBP',
    net_price DECIMAL(15,2) GENERATED ALWAYS AS ((quantity / price_unit) * price_per_unit) STORED,
    
    -- Account Assignment
    account_assignment_category VARCHAR(10) CHECK (account_assignment_category IN ('K', 'P', 'A', 'F', 'O', 'N', 'S', 'U')),
    cost_center VARCHAR(20),
    project_code VARCHAR(50),
    wbs_element VARCHAR(50),
    activity_code VARCHAR(50),
    internal_order VARCHAR(20),
    asset_number VARCHAR(20),
    sales_order VARCHAR(20),
    sales_order_item VARCHAR(10),
    network_number VARCHAR(20),
    network_activity VARCHAR(20),
    profit_center VARCHAR(20),
    gl_account VARCHAR(20),
    
    -- Supplier Information
    supplier_code VARCHAR(20),
    purchase_info_record VARCHAR(20),
    
    -- Additional Fields
    tax_code VARCHAR(10),
    delivery_address TEXT,
    requisitioner VARCHAR(50),
    tracking_number VARCHAR(50),
    item_category VARCHAR(10) DEFAULT 'M', -- M=Material, S=Service, L=Service Line
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'ORDERED', 'DELIVERED', 'INVOICED', 'CLOSED')),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pr_id, pr_item_number)
);

-- Create function to copy MR to PR
CREATE OR REPLACE FUNCTION copy_mr_to_pr(
    p_mr_id UUID,
    p_purchasing_org VARCHAR(10),
    p_purchasing_group VARCHAR(10) DEFAULT NULL
) RETURNS VARCHAR(50) AS $$
DECLARE
    v_pr_number VARCHAR(50);
    v_pr_id UUID;
    v_mr_record RECORD;
    v_item_record RECORD;
    v_item_counter INTEGER := 10;
BEGIN
    -- Generate PR number
    v_pr_number := 'PR-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(nextval('pr_number_seq')::TEXT, 6, '0');
    
    -- Get MR header information
    SELECT * INTO v_mr_record FROM material_requests WHERE id = p_mr_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Material Request not found: %', p_mr_id;
    END IF;
    
    -- Create PR header
    INSERT INTO purchase_requisitions (
        pr_number,
        created_from_mr,
        company_code,
        purchasing_organization,
        purchasing_group,
        requested_by,
        total_value,
        currency,
        notes,
        created_by
    ) VALUES (
        v_pr_number,
        v_mr_record.request_number,
        v_mr_record.company_code,
        p_purchasing_org,
        p_purchasing_group,
        v_mr_record.requested_by,
        v_mr_record.total_value,
        v_mr_record.currency,
        'Created from MR: ' || v_mr_record.request_number,
        v_mr_record.created_by
    ) RETURNING id INTO v_pr_id;
    
    -- Copy MR items to PR items
    FOR v_item_record IN 
        SELECT * FROM material_request_items 
        WHERE material_request_id = p_mr_id 
        AND status NOT IN ('CANCELLED', 'FULLY_ISSUED')
        ORDER BY line_number
    LOOP
        INSERT INTO purchase_requisition_items (
            pr_id,
            pr_item_number,
            material_request_item_id,
            material_code,
            short_text,
            quantity,
            unit_of_measure,
            delivery_date,
            plant_code,
            storage_location,
            material_group,
            price_per_unit,
            currency,
            account_assignment_category,
            cost_center,
            project_code,
            wbs_element,
            activity_code,
            internal_order,
            asset_number,
            sales_order,
            sales_order_item,
            network_number,
            network_activity,
            profit_center,
            gl_account,
            supplier_code,
            purchase_info_record,
            tax_code,
            delivery_address,
            requisitioner
        ) VALUES (
            v_pr_id,
            LPAD(v_item_counter::TEXT, 5, '0'),
            v_item_record.id,
            v_item_record.material_code,
            v_item_record.material_description,
            v_item_record.quantity - COALESCE(v_item_record.issued_quantity, 0), -- Only remaining quantity
            v_item_record.unit_of_measure,
            COALESCE(v_item_record.delivery_date, CURRENT_DATE + INTERVAL '7 days'),
            v_item_record.plant_code,
            v_item_record.storage_location,
            v_item_record.material_group,
            v_item_record.price_per_unit,
            v_item_record.currency,
            v_item_record.account_assignment_category,
            v_item_record.cost_center,
            v_item_record.project_code,
            v_item_record.wbs_element,
            v_item_record.activity_code,
            v_item_record.internal_order,
            v_item_record.asset_number,
            v_item_record.sales_order,
            v_item_record.sales_order_item,
            v_item_record.network_number,
            v_item_record.network_activity,
            v_item_record.profit_center,
            v_item_record.gl_account,
            v_item_record.supplier_code,
            v_item_record.purchase_info_record,
            v_item_record.tax_code,
            v_item_record.delivery_address,
            v_item_record.requisitioner
        );
        
        v_item_counter := v_item_counter + 10;
    END LOOP;
    
    -- Update MR status
    UPDATE material_requests 
    SET status = 'CONVERTED', 
        updated_at = CURRENT_TIMESTAMP 
    WHERE id = p_mr_id;
    
    RETURN v_pr_number;
END;
$$ LANGUAGE plpgsql;

-- Create sequence for PR numbering
CREATE SEQUENCE IF NOT EXISTS pr_number_seq START 1;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_mr_items_account_assignment ON material_request_items(account_assignment_category);
CREATE INDEX IF NOT EXISTS idx_mr_items_cost_center ON material_request_items(cost_center);
CREATE INDEX IF NOT EXISTS idx_mr_items_project ON material_request_items(project_code);
CREATE INDEX IF NOT EXISTS idx_mr_items_wbs ON material_request_items(wbs_element);
CREATE INDEX IF NOT EXISTS idx_pr_items_mr_item ON purchase_requisition_items(material_request_item_id);
CREATE INDEX IF NOT EXISTS idx_pr_created_from_mr ON purchase_requisitions(created_from_mr);
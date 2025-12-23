-- SCRIPT 5: SAP-Style Material Master Views
-- Run this after the previous 4 scripts

-- Material Plant Data (like SAP MARC table)
CREATE TABLE material_plant_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES stock_items(id) ON DELETE CASCADE,
    plant_id UUID NOT NULL REFERENCES plants(id) ON DELETE CASCADE,
    reorder_level DECIMAL(15,4) DEFAULT 0,
    safety_stock DECIMAL(15,4) DEFAULT 0,
    maximum_stock DECIMAL(15,4) DEFAULT 0,
    default_storage_location_id UUID REFERENCES storage_locations(id),
    procurement_type VARCHAR(1) DEFAULT 'F', -- F=External, E=In-house
    standard_price DECIMAL(15,2) DEFAULT 0,
    price_unit DECIMAL(5,0) DEFAULT 1,
    currency VARCHAR(3) DEFAULT 'INR',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(material_id, plant_id)
);

-- Material Storage Location Data (like SAP MARD table)
CREATE TABLE material_storage_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES stock_items(id) ON DELETE CASCADE,
    storage_location_id UUID NOT NULL REFERENCES storage_locations(id) ON DELETE CASCADE,
    current_stock DECIMAL(15,4) DEFAULT 0,
    reserved_stock DECIMAL(15,4) DEFAULT 0,
    available_stock DECIMAL(15,4) GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
    last_movement_date DATE,
    bin_location VARCHAR(20),
    UNIQUE(material_id, storage_location_id)
);

-- Enhanced Material Master View (combines all views)
CREATE OR REPLACE VIEW material_master_complete AS
SELECT 
    si.id,
    si.item_code,
    si.description,
    si.category,
    si.unit,
    si.is_active,
    -- Plant Data
    mpd.plant_id,
    pl.plant_code,
    pl.plant_name,
    mpd.reorder_level,
    mpd.safety_stock,
    mpd.standard_price,
    mpd.currency,
    -- Storage Location Data  
    msd.storage_location_id,
    sl.sloc_code,
    sl.sloc_name,
    msd.current_stock,
    msd.available_stock,
    -- Project Assignment (Account Assignment 'Q')
    CASE 
        WHEN si.project_id IS NULL THEN 'Normal Stock'
        ELSE 'Q: ' || p.code
    END as account_assignment,
    -- Company Info
    cc.company_code,
    cc.company_name
FROM stock_items si
LEFT JOIN material_plant_data mpd ON si.id = mpd.material_id
LEFT JOIN plants pl ON mpd.plant_id = pl.id
LEFT JOIN material_storage_data msd ON si.id = msd.material_id
LEFT JOIN storage_locations sl ON msd.storage_location_id = sl.id
LEFT JOIN projects p ON si.project_id = p.id
LEFT JOIN company_codes cc ON pl.company_code_id = cc.id;

-- Auto-create plant data for existing materials
INSERT INTO material_plant_data (material_id, plant_id, reorder_level, standard_price)
SELECT 
    si.id,
    pl.id,
    si.reorder_level,
    0 -- Default price, to be updated
FROM stock_items si
CROSS JOIN plants pl
WHERE NOT EXISTS (
    SELECT 1 FROM material_plant_data mpd 
    WHERE mpd.material_id = si.id AND mpd.plant_id = pl.id
);

-- Auto-create storage location data for existing materials
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock)
SELECT 
    si.id,
    sl.id,
    COALESCE(sb.current_quantity, 0)
FROM stock_items si
CROSS JOIN storage_locations sl
LEFT JOIN stores st ON sl.plant_id = (SELECT plant_id FROM plants WHERE project_id = st.project_id)
LEFT JOIN stock_balances sb ON sb.store_id = st.id AND sb.stock_item_id = si.id
WHERE NOT EXISTS (
    SELECT 1 FROM material_storage_data msd 
    WHERE msd.material_id = si.id AND msd.storage_location_id = sl.id
);

-- Indexes for performance
CREATE INDEX idx_material_plant_data_material ON material_plant_data(material_id);
CREATE INDEX idx_material_plant_data_plant ON material_plant_data(plant_id);
CREATE INDEX idx_material_storage_data_material ON material_storage_data(material_id);
CREATE INDEX idx_material_storage_data_storage ON material_storage_data(storage_location_id);
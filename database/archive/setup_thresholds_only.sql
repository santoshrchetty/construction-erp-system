-- Disable the problematic trigger that references store_id
DROP TRIGGER IF EXISTS auto_delete_empty_stores_trigger ON stock_balances;
DROP TRIGGER IF EXISTS trigger_auto_delete_empty_stores ON stock_balances;
DROP FUNCTION IF EXISTS auto_delete_empty_stores() CASCADE;

-- Run the plant threshold system setup
-- Create plant-specific stock thresholds table
CREATE TABLE IF NOT EXISTS plant_stock_thresholds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    material_category VARCHAR(100) NOT NULL,
    low_stock_threshold DECIMAL(15,4) NOT NULL,
    normal_stock_threshold DECIMAL(15,4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(plant_id, material_category)
);

-- Insert plant-specific stock thresholds for P001 (Construction)
INSERT INTO plant_stock_thresholds (plant_id, material_category, low_stock_threshold, normal_stock_threshold) VALUES
((SELECT id FROM plants WHERE plant_code = 'P001'), 'CEMENT', 20, 50),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'STEEL', 100, 300),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'AGGREGATE', 30, 80),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'MASONRY', 500, 1500),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'CONCRETE', 10, 30),
((SELECT id FROM plants WHERE plant_code = 'P001'), 'FINISHING', 50, 150)
ON CONFLICT (plant_id, material_category) DO NOTHING;

-- Insert plant-specific stock thresholds for P006 (Infrastructure)
INSERT INTO plant_stock_thresholds (plant_id, material_category, low_stock_threshold, normal_stock_threshold) VALUES
((SELECT id FROM plants WHERE plant_code = 'P006'), 'ASPHALT', 50, 150),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'POWER', 3, 10),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'DRAINAGE', 20, 60),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'SAFETY', 15, 40),
((SELECT id FROM plants WHERE plant_code = 'P006'), 'SIGNAGE', 10, 25)
ON CONFLICT (plant_id, material_category) DO NOTHING;
-- ERP-Standard Material Master Schema
-- Step 1.1: Create new material tables following SAP/Oracle/Dynamics patterns
-- Field lengths optimized for maximum ERP compatibility

-- 1. Materials Master (Global - No Plant Dependency)
CREATE TABLE IF NOT EXISTS materials (
  material_code VARCHAR(50) PRIMARY KEY,
  material_name VARCHAR(500) NOT NULL,
  description TEXT,
  category VARCHAR(50) NOT NULL,
  material_group VARCHAR(50),
  base_uom VARCHAR(20) NOT NULL,
  material_type VARCHAR(50) DEFAULT 'FERT', -- FERT, HALB, ROH, HIBE
  weight_unit VARCHAR(20),
  gross_weight DECIMAL(15,3),
  net_weight DECIMAL(15,3),
  volume_unit VARCHAR(20),
  volume DECIMAL(15,3),
  created_by UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_by UUID,
  updated_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- 2. Material Plant Data (Plant-Specific Parameters)
CREATE TABLE IF NOT EXISTS material_plant_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(50) NOT NULL,
  plant_code VARCHAR(50) NOT NULL,
  -- Procurement Data
  procurement_type VARCHAR(20) DEFAULT 'E', -- E=Purchase, F=Production, X=Both
  special_procurement VARCHAR(20),
  source_list_required BOOLEAN DEFAULT false,
  -- MRP Data
  mrp_type VARCHAR(20) DEFAULT 'PD', -- PD=MRP, VV=Forecast, ND=No Planning
  mrp_controller VARCHAR(50),
  planning_strategy_group VARCHAR(20),
  consumption_mode VARCHAR(20),
  -- Stock Parameters
  reorder_point DECIMAL(15,3) DEFAULT 0,
  safety_stock DECIMAL(15,3) DEFAULT 0,
  minimum_lot_size DECIMAL(15,3) DEFAULT 1,
  maximum_lot_size DECIMAL(15,3),
  lot_size_increment DECIMAL(15,3) DEFAULT 1,
  -- Planning Parameters
  planned_delivery_time INTEGER DEFAULT 0, -- days
  goods_receipt_processing_time INTEGER DEFAULT 0, -- days
  -- Status
  plant_status VARCHAR(20) DEFAULT 'ACTIVE',
  valid_from DATE DEFAULT CURRENT_DATE,
  valid_to DATE,
  created_by UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_by UUID,
  updated_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  UNIQUE(material_code, plant_code)
);

-- 3. Material Pricing (Company/Plant-Specific)
CREATE TABLE IF NOT EXISTS material_pricing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(50) NOT NULL,
  company_code VARCHAR(50) NOT NULL,
  plant_code VARCHAR(50),
  price_type VARCHAR(20) NOT NULL DEFAULT 'STD', -- STD=Standard, MAP=Moving Average, FIFO, LIFO
  price DECIMAL(15,4) NOT NULL DEFAULT 0,
  currency VARCHAR(10) NOT NULL DEFAULT 'USD',
  price_unit DECIMAL(15,3) DEFAULT 1, -- Price per X units
  price_uom VARCHAR(20),
  valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
  valid_to DATE,
  created_by UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_by UUID,
  updated_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  UNIQUE(material_code, company_code, plant_code, price_type, valid_from)
);

-- 4. Material Categories (Master Data)
CREATE TABLE IF NOT EXISTS material_categories (
  category_code VARCHAR(50) PRIMARY KEY,
  category_name VARCHAR(500) NOT NULL,
  description TEXT,
  parent_category VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. Material Groups (Master Data)
CREATE TABLE IF NOT EXISTS material_groups (
  group_code VARCHAR(50) PRIMARY KEY,
  group_name VARCHAR(500) NOT NULL,
  description TEXT,
  category_code VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Add category_code column if it doesn't exist (for existing tables)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_groups' AND column_name = 'category_code') THEN
        ALTER TABLE material_groups ADD COLUMN category_code VARCHAR(50) REFERENCES material_categories(category_code);
    END IF;
END $$;

-- Update existing table column sizes to accommodate future ERPs
DO $$
BEGIN
    -- Add missing columns to materials table if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'materials' AND column_name = 'material_code') THEN
        ALTER TABLE materials ADD COLUMN material_code VARCHAR(50) PRIMARY KEY;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'materials' AND column_name = 'material_name') THEN
        ALTER TABLE materials ADD COLUMN material_name VARCHAR(500) NOT NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'materials' AND column_name = 'category') THEN
        ALTER TABLE materials ADD COLUMN category VARCHAR(50) NOT NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'materials' AND column_name = 'material_group') THEN
        ALTER TABLE materials ADD COLUMN material_group VARCHAR(50);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'materials' AND column_name = 'base_uom') THEN
        ALTER TABLE materials ADD COLUMN base_uom VARCHAR(20) NOT NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'materials' AND column_name = 'material_type') THEN
        ALTER TABLE materials ADD COLUMN material_type VARCHAR(50) DEFAULT 'FERT';
    END IF;
    
    -- Add missing columns to material_plant_data if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'material_code') THEN
        ALTER TABLE material_plant_data ADD COLUMN material_code VARCHAR(50) NOT NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'material_plant_data' AND column_name = 'plant_code') THEN
        ALTER TABLE material_plant_data ADD COLUMN plant_code VARCHAR(50) NOT NULL;
    END IF;
    
    -- Update material_groups table columns
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_groups' AND column_name = 'group_code') THEN
        ALTER TABLE material_groups ALTER COLUMN group_code TYPE VARCHAR(50);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_groups' AND column_name = 'group_name') THEN
        ALTER TABLE material_groups ALTER COLUMN group_name TYPE VARCHAR(500);
    END IF;
    
    -- Update materials table columns
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'material_code') THEN
        ALTER TABLE materials ALTER COLUMN material_code TYPE VARCHAR(50);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'material_name') THEN
        ALTER TABLE materials ALTER COLUMN material_name TYPE VARCHAR(500);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'category') THEN
        ALTER TABLE materials ALTER COLUMN category TYPE VARCHAR(50);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'material_group') THEN
        ALTER TABLE materials ALTER COLUMN material_group TYPE VARCHAR(50);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'base_uom') THEN
        ALTER TABLE materials ALTER COLUMN base_uom TYPE VARCHAR(20);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'material_type') THEN
        ALTER TABLE materials ALTER COLUMN material_type TYPE VARCHAR(50);
    END IF;
    
    -- Update material_plant_data columns
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_plant_data' AND column_name = 'material_code') THEN
        ALTER TABLE material_plant_data ALTER COLUMN material_code TYPE VARCHAR(50);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_plant_data' AND column_name = 'plant_code') THEN
        ALTER TABLE material_plant_data ALTER COLUMN plant_code TYPE VARCHAR(50);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_plant_data' AND column_name = 'procurement_type') THEN
        ALTER TABLE material_plant_data ALTER COLUMN procurement_type TYPE VARCHAR(20);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_plant_data' AND column_name = 'plant_status') THEN
        ALTER TABLE material_plant_data ALTER COLUMN plant_status TYPE VARCHAR(20);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_plant_data' AND column_name = 'mrp_type') THEN
        ALTER TABLE material_plant_data ALTER COLUMN mrp_type TYPE VARCHAR(20);
    END IF;
    
    -- Update material_categories columns
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_categories' AND column_name = 'category_code') THEN
        ALTER TABLE material_categories ALTER COLUMN category_code TYPE VARCHAR(50);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_categories' AND column_name = 'category_name') THEN
        ALTER TABLE material_categories ALTER COLUMN category_name TYPE VARCHAR(500);
    END IF;
END $$;

-- 6. Insert standard material categories
INSERT INTO material_categories (category_code, category_name, description) VALUES
('CEMENT', 'Cement Products', 'All types of cement and cement-based materials'),
('STEEL', 'Steel Products', 'Steel bars, sheets, and structural steel'),
('AGGREGATE', 'Aggregates', 'Sand, gravel, crushed stone, and other aggregates'),
('ASPHALT', 'Asphalt Products', 'Asphalt, bitumen, and related materials'),
('CONCRETE', 'Concrete Products', 'Ready-mix concrete and concrete products'),
('SAFETY', 'Safety Equipment', 'Personal protective equipment and safety materials'),
('TOOLS', 'Tools & Equipment', 'Construction tools and equipment'),
('ELECTRICAL', 'Electrical Materials', 'Electrical components and materials'),
('PLUMBING', 'Plumbing Materials', 'Pipes, fittings, and plumbing supplies'),
('FINISHING', 'Finishing Materials', 'Paint, tiles, and finishing materials')
ON CONFLICT (category_code) DO NOTHING;

-- 7. Insert standard material groups
INSERT INTO material_groups (group_code, group_name, category_code) VALUES
('CEM-OPC', 'Ordinary Portland Cement', 'CEMENT'),
('CEM-PPC', 'Portland Pozzolan Cement', 'CEMENT'),
('STL-REBAR', 'Reinforcement Bars', 'STEEL'),
('STL-STRUCT', 'Structural Steel', 'STEEL'),
('AGG-SAND', 'Sand', 'AGGREGATE'),
('AGG-GRAVEL', 'Gravel', 'AGGREGATE'),
('ASP-HOT', 'Hot Mix Asphalt', 'ASPHALT'),
('ASP-COLD', 'Cold Mix Asphalt', 'ASPHALT'),
('SAF-PPE', 'Personal Protective Equipment', 'SAFETY'),
('SAF-SIGN', 'Safety Signage', 'SAFETY')
ON CONFLICT (group_code) DO NOTHING;

-- 8. Add foreign key constraints (with existence checks)
DO $$
BEGIN
    -- Add material_plant_data foreign key
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_plant_data' AND column_name = 'material_code') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                       WHERE table_name = 'material_plant_data' AND constraint_name = 'fk_material_plant_data_material') THEN
        ALTER TABLE material_plant_data 
        ADD CONSTRAINT fk_material_plant_data_material 
        FOREIGN KEY (material_code) REFERENCES materials(material_code);
    END IF;
    
    -- Add material_pricing foreign key
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_pricing' AND column_name = 'material_code') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                       WHERE table_name = 'material_pricing' AND constraint_name = 'fk_material_pricing_material') THEN
        ALTER TABLE material_pricing 
        ADD CONSTRAINT fk_material_pricing_material 
        FOREIGN KEY (material_code) REFERENCES materials(material_code);
    END IF;
    
    -- Add material_categories self-reference
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_categories' AND column_name = 'parent_category') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                       WHERE table_name = 'material_categories' AND constraint_name = 'fk_material_categories_parent') THEN
        ALTER TABLE material_categories 
        ADD CONSTRAINT fk_material_categories_parent 
        FOREIGN KEY (parent_category) REFERENCES material_categories(category_code);
    END IF;
    
    -- Add material_groups category reference
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'material_groups' AND column_name = 'category_code') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                       WHERE table_name = 'material_groups' AND constraint_name = 'fk_material_groups_category') THEN
        ALTER TABLE material_groups 
        ADD CONSTRAINT fk_material_groups_category 
        FOREIGN KEY (category_code) REFERENCES material_categories(category_code);
    END IF;
    
    -- Add category foreign key if column exists and constraint doesn't exist
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'category') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                       WHERE table_name = 'materials' AND constraint_name = 'fk_materials_category') THEN
        ALTER TABLE materials 
        ADD CONSTRAINT fk_materials_category 
        FOREIGN KEY (category) REFERENCES material_categories(category_code);
    END IF;
    
    -- Add material_group foreign key if column exists and constraint doesn't exist
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'materials' AND column_name = 'material_group') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                       WHERE table_name = 'materials' AND constraint_name = 'fk_materials_group') THEN
        ALTER TABLE materials 
        ADD CONSTRAINT fk_materials_group 
        FOREIGN KEY (material_group) REFERENCES material_groups(group_code);
    END IF;
END $$;

-- 9. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_materials_category ON materials(category);
CREATE INDEX IF NOT EXISTS idx_materials_group ON materials(material_group);
CREATE INDEX IF NOT EXISTS idx_materials_type ON materials(material_type);
CREATE INDEX IF NOT EXISTS idx_materials_active ON materials(is_active);

CREATE INDEX IF NOT EXISTS idx_material_plant_data_material ON material_plant_data(material_code);
CREATE INDEX IF NOT EXISTS idx_material_plant_data_plant ON material_plant_data(plant_code);
CREATE INDEX IF NOT EXISTS idx_material_plant_data_active ON material_plant_data(is_active);

CREATE INDEX IF NOT EXISTS idx_material_pricing_material ON material_pricing(material_code);
CREATE INDEX IF NOT EXISTS idx_material_pricing_company ON material_pricing(company_code);
CREATE INDEX IF NOT EXISTS idx_material_pricing_dates ON material_pricing(valid_from, valid_to);

-- 10. Create views for common queries
CREATE OR REPLACE VIEW material_master_view AS
SELECT 
  m.material_code,
  m.material_name,
  m.description,
  m.category,
  mc.category_name,
  m.material_group,
  mg.group_name,
  m.base_uom,
  m.material_type,
  m.is_active,
  m.created_at,
  COUNT(mpd.plant_code) as plant_count
FROM materials m
LEFT JOIN material_categories mc ON m.category = mc.category_code
LEFT JOIN material_groups mg ON m.material_group = mg.group_code
LEFT JOIN material_plant_data mpd ON m.material_code = mpd.material_code AND mpd.is_active = true
WHERE m.is_active = true
GROUP BY m.material_code, m.material_name, m.description, m.category, mc.category_name, 
         m.material_group, mg.group_name, m.base_uom, m.material_type, m.is_active, m.created_at;

-- Verify table creation
SELECT 'Materials table created' as status, COUNT(*) as count FROM materials;
SELECT 'Material categories created' as status, COUNT(*) as count FROM material_categories;
SELECT 'Material groups created' as status, COUNT(*) as count FROM material_groups;
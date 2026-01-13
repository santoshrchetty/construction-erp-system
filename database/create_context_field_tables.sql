-- Create tables for field definitions and options if they don't exist

-- Field definitions table
CREATE TABLE IF NOT EXISTS approval_field_definitions (
  id VARCHAR(50) PRIMARY KEY,
  customer_id UUID NOT NULL,
  field_name VARCHAR(100) NOT NULL,
  field_label VARCHAR(200) NOT NULL,
  field_type VARCHAR(50) NOT NULL DEFAULT 'MULTI_SELECT',
  is_required BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(customer_id, field_name)
);

-- Field options table  
CREATE TABLE IF NOT EXISTS approval_field_options (
  id VARCHAR(50) PRIMARY KEY,
  customer_id UUID NOT NULL,
  field_definition_id VARCHAR(50) NOT NULL,
  option_value VARCHAR(100) NOT NULL,
  option_label VARCHAR(200) NOT NULL,
  option_description VARCHAR(500),
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (field_definition_id) REFERENCES approval_field_definitions(id) ON DELETE CASCADE,
  UNIQUE(field_definition_id, option_value)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_field_definitions_customer ON approval_field_definitions(customer_id);
CREATE INDEX IF NOT EXISTS idx_field_options_customer ON approval_field_options(customer_id);
CREATE INDEX IF NOT EXISTS idx_field_options_definition ON approval_field_options(field_definition_id);
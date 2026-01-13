-- Fix movement_types table structure
-- Drop and recreate with correct column names

DROP TABLE IF EXISTS movement_types CASCADE;

CREATE TABLE movement_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type VARCHAR(3) UNIQUE NOT NULL,
    movement_name VARCHAR(40) NOT NULL,
    movement_indicator VARCHAR(1) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample movement types
INSERT INTO movement_types (movement_type, movement_name, movement_indicator, description) VALUES
('101', 'GR from Purchase Order', '+', 'Goods Receipt from Purchase Order'),
('102', 'GR Reversal', '-', 'Goods Receipt Reversal'),
('261', 'Issue to Production', '-', 'Issue to Production Order'),
('262', 'Issue Reversal', '+', 'Issue to Production Reversal'),
('551', 'Transfer Posting', '±', 'Transfer Between Storage Locations'),
('601', 'Initial Stock Entry', '+', 'Initial Stock Entry');

-- Create GL Accounts table if not exists
CREATE TABLE IF NOT EXISTS gl_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_code VARCHAR(10) UNIQUE NOT NULL,
    account_name VARCHAR(50) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Valuation Classes table if not exists
CREATE TABLE IF NOT EXISTS valuation_classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_code VARCHAR(4) UNIQUE NOT NULL,
    class_name VARCHAR(40) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
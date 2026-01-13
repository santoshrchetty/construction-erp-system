-- Create Tiles Table Structure
-- =============================

-- Create tiles table with all required columns
CREATE TABLE IF NOT EXISTS tiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(100) NOT NULL,
    subtitle VARCHAR(200),
    icon VARCHAR(50) NOT NULL,
    color VARCHAR(20) DEFAULT 'bg-blue-500',
    route VARCHAR(200) NOT NULL,
    roles TEXT[] NOT NULL DEFAULT '{}',
    sequence_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    auth_object VARCHAR(20),
    construction_action VARCHAR(20),
    module_code VARCHAR(2),
    tile_category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_tiles_module_code ON tiles(module_code);
CREATE INDEX IF NOT EXISTS idx_tiles_category ON tiles(tile_category);
CREATE INDEX IF NOT EXISTS idx_tiles_active ON tiles(is_active);
CREATE INDEX IF NOT EXISTS idx_tiles_auth_object ON tiles(auth_object);

-- Verify table was created
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;
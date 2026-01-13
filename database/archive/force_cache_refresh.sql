-- Force Complete Tiles Cache Refresh
-- ===================================

-- Update ALL tiles timestamps to force cache refresh
UPDATE tiles SET updated_at = NOW();

-- Specifically update Finance tiles
UPDATE tiles SET updated_at = NOW() WHERE tile_category = 'Finance';

-- Verify update
SELECT 'Cache Refresh Complete' as status, NOW() as timestamp;
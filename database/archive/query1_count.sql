-- Run these queries ONE AT A TIME
-- =================================

-- Query 1: Count Finance tiles
SELECT COUNT(*) as finance_tiles_count
FROM tiles WHERE tile_category = 'Finance';
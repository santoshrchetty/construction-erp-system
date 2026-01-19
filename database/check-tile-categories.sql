-- Check all unique tile categories in the database
SELECT DISTINCT tile_category, COUNT(*) as tile_count
FROM tiles
WHERE is_active = true
GROUP BY tile_category
ORDER BY tile_category;

-- Check if categories match the hardcoded list
-- Hardcoded: Administration, Project Management, Procurement, Materials, Warehouse, Finance, Quality, Safety, Human Resources, Configuration

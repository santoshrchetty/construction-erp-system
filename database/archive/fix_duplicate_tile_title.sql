-- Fix duplicate Material Stock Overview tile title
-- Update to "Inventory Stock Levels" to match Chart of Accounts naming pattern

UPDATE tiles 
SET 
  title = 'Inventory Stock Levels',
  subtitle = 'View current material stock levels and status'
WHERE 
  title = 'Material Stock Overview' 
  AND construction_action = 'stock-overview'
  AND module_code = 'MM';

-- Verify the update
SELECT id, title, subtitle, module_code, construction_action 
FROM tiles 
WHERE construction_action = 'stock-overview' 
  AND module_code = 'MM';
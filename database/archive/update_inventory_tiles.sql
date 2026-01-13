-- Update tile categories from Materials to Inventory for specific tiles
UPDATE tiles 
SET tile_category = 'Inventory' 
WHERE title IN ('Goods Receipt', 'Material Reservations', 'Material Stock Overview');

-- Verify the update
SELECT title, tile_category, module_code 
FROM tiles 
WHERE title IN ('Goods Receipt', 'Material Reservations', 'Material Stock Overview')
ORDER BY title;
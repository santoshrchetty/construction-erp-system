-- Insert missing inventory tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category) VALUES
('Goods Issue', 'Issue materials to projects and cost centers', 'truck', 'MM', 'ISSUE', '/inventory/goods-issue', 'Inventory'),
('Goods Transfer', 'Transfer materials between locations', 'arrow-right-left', 'MM', 'TRANSFER', '/inventory/goods-transfer', 'Inventory'),
('Physical Inventory', 'Count and adjust physical stock', 'clipboard-check', 'MM', 'COUNT', '/inventory/physical-inventory', 'Inventory'),
('Inventory Adjustments', 'Adjust stock levels and valuations', 'settings', 'MM', 'ADJUST', '/inventory/adjustments', 'Inventory');

-- Verify the new tiles
SELECT title, tile_category, module_code 
FROM tiles 
WHERE tile_category = 'Inventory' 
ORDER BY title;
-- Fix Icon Names for Lucide Compatibility
-- ========================================

UPDATE tiles SET icon = 'building' WHERE icon = 'building-2';
UPDATE tiles SET icon = 'plus-circle' WHERE icon = 'plus-circle';
UPDATE tiles SET icon = 'edit' WHERE icon = 'edit-3';
UPDATE tiles SET icon = 'git-branch' WHERE icon = 'git-branch';
UPDATE tiles SET icon = 'shopping-cart' WHERE icon = 'shopping-cart';
UPDATE tiles SET icon = 'check-circle' WHERE icon = 'check-circle';
UPDATE tiles SET icon = 'package' WHERE icon = 'package-check';
UPDATE tiles SET icon = 'box' WHERE icon = 'box';
UPDATE tiles SET icon = 'users' WHERE icon = 'users';
UPDATE tiles SET icon = 'calendar' WHERE icon = 'calendar';
UPDATE tiles SET icon = 'play' WHERE icon = 'play-circle';
UPDATE tiles SET icon = 'user-check' WHERE icon = 'user-check';
UPDATE tiles SET icon = 'trending-up' WHERE icon = 'trending-up';
UPDATE tiles SET icon = 'file-text' WHERE icon = 'file-text';
UPDATE tiles SET icon = 'edit' WHERE icon = 'edit';
UPDATE tiles SET icon = 'shield-check' WHERE icon = 'shield-check';
UPDATE tiles SET icon = 'dollar-sign' WHERE icon = 'dollar-sign';
UPDATE tiles SET icon = 'pie-chart' WHERE icon = 'pie-chart';
UPDATE tiles SET icon = 'bar-chart-3' WHERE icon = 'bar-chart-3';
UPDATE tiles SET icon = 'clock' WHERE icon = 'clock';
UPDATE tiles SET icon = 'check-square' WHERE icon = 'check-square';
UPDATE tiles SET icon = 'settings' WHERE icon = 'user-cog';
UPDATE tiles SET icon = 'package' WHERE icon = 'package';
UPDATE tiles SET icon = 'truck' WHERE icon = 'truck';
UPDATE tiles SET icon = 'warehouse' WHERE icon = 'warehouse';

-- Verify icon updates
SELECT 'UPDATED ICONS' as status, title, icon FROM tiles 
WHERE tile_category = 'Project Management'
ORDER BY sequence_order;
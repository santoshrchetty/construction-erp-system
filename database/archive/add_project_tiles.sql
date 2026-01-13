-- Add New Project Management Tiles
-- =================================

-- Insert new Project Management tiles
INSERT INTO tiles (title, subtitle, icon, color, route, roles, sequence_order, auth_object, construction_action, module_code, tile_category) VALUES

-- Additional PS - Project System Tiles
('WBS Management', 'Work breakdown structure', 'git-branch', 'bg-purple-500', '#', '{admin,manager,engineer}', 14, 'PS_WBS_CREATE', 'INITIATE', 'PS', 'Project Management'),
('Activities', 'Manage project activities', 'settings', 'bg-orange-500', '#', '{admin,manager,engineer}', 15, 'PP_ACT_SCHEDULE', 'INITIATE', 'PS', 'Project Management'),
('Tasks', 'Task management & tracking', 'check-square', 'bg-green-500', '#', '{admin,manager,engineer}', 16, 'PP_TSK_ASSIGN', 'INITIATE', 'PS', 'Project Management'),
('Schedule', 'Project scheduling', 'calendar', 'bg-blue-500', '#', '{admin,manager,engineer}', 17, 'PP_ACT_SCHEDULE', 'INITIATE', 'PS', 'Project Management'),
('Cost Management', 'Project cost tracking', 'dollar-sign', 'bg-red-500', '#', '{admin,manager,finance}', 18, 'CO_BDG_MODIFY', 'MODIFY', 'PS', 'Project Management'),
('Reports', 'Project reports & analytics', 'bar-chart-3', 'bg-indigo-500', '#', '{admin,manager,engineer}', 19, 'PS_PRJ_REVIEW', 'REVIEW', 'PS', 'Project Management');

-- Verify new tiles
SELECT 'NEW PROJECT TILES' as status, title, icon, tile_category FROM tiles 
WHERE tile_category = 'Project Management'
ORDER BY sequence_order;
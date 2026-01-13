-- Insert tile categories based on mockTiles array
INSERT INTO public.tile_categories (category_name, module_code, description, icon, color, sequence_order) VALUES
('Finance', 'FI', 'Financial management and accounting', 'dollar-sign', '#10B981', 1),
('Materials', 'MM', 'Material master and inventory management', 'package', '#3B82F6', 2),
('Procurement', 'MM', 'Purchase orders and vendor management', 'shopping-cart', '#8B5CF6', 3),
('Inventory', 'WM', 'Warehouse and inventory operations', 'warehouse', '#F59E0B', 4),
('Warehouse', 'WM', 'Warehouse management and operations', 'warehouse', '#F59E0B', 5),
('Project Management', 'PS', 'Construction project management', 'building', '#EF4444', 6),
('Time Management', 'HR', 'Human resources and time tracking', 'clock', '#06B6D4', 7),
('Quality', 'QM', 'Quality management and inspections', 'shield-check', '#84CC16', 8),
('Safety', 'EH', 'Environmental health and safety', 'shield', '#F97316', 9),
('Administration', 'AD', 'System administration and user management', 'settings', '#6B7280', 10);

-- Verify the insert
SELECT * FROM public.tile_categories ORDER BY sequence_order;
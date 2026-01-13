-- ADD PURCHASE ORDER TILE
-- Insert PO management tile with proper authorization

INSERT INTO tiles (
  title, 
  construction_action, 
  route, 
  auth_object, 
  tile_category, 
  module_code, 
  is_active
) VALUES (
  'Purchase Orders',
  'PurchaseOrderManagement',
  '/purchase-orders',
  'PO_CREATE',
  'Procurement',
  'MM',
  true
) ON CONFLICT (title) DO UPDATE SET
  construction_action = EXCLUDED.construction_action,
  route = EXCLUDED.route,
  auth_object = EXCLUDED.auth_object;

SELECT 'PURCHASE ORDER TILE ADDED SUCCESSFULLY' as status;
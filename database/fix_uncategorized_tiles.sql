-- =====================================================
-- FIX UNCATEGORIZED TILES
-- =====================================================

-- Update Purchase Order Management tile
UPDATE tiles
SET 
  tile_category = 'Procurement',
  subtitle = 'Create and manage purchase orders',
  module_code = 'MM-PUR',
  construction_action = 'purchase_orders',
  auth_object = 'Z_PO_MANAGE',
  sequence_order = 20
WHERE id = '4effbfe9-cc76-47b0-a65e-9e65a06d3080';

-- Update Budget Approvals tile
UPDATE tiles
SET 
  tile_category = 'Finance',
  subtitle = 'Review and approve budget requests',
  module_code = 'FI-BUD',
  construction_action = 'budget_approvals',
  auth_object = 'Z_BUDGET_APPROVE',
  sequence_order = 50
WHERE id = 'f09bb9ba-e69d-4798-a526-e7989e1a2aa1';

-- Verify the updates
SELECT 
  title,
  subtitle,
  tile_category,
  module_code,
  construction_action,
  auth_object,
  route
FROM tiles
WHERE id IN ('4effbfe9-cc76-47b0-a65e-9e65a06d3080', 'f09bb9ba-e69d-4798-a526-e7989e1a2aa1');

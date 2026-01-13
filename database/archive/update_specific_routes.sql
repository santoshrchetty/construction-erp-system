-- Update Tile Routes to Use Existing Specific Pages
-- =================================================

UPDATE tiles SET route = '/projects/dashboard' WHERE title = 'Projects Dashboard';
UPDATE tiles SET route = '/projects?action=create' WHERE title = 'Create Project';
UPDATE tiles SET route = '/projects?action=edit' WHERE title = 'Modify Projects';
UPDATE tiles SET route = '/dashboard' WHERE title = 'WBS Management';

-- Update other tiles to use existing pages with parameters
UPDATE tiles SET route = '/purchase-orders?action=create' WHERE title = 'Purchase Orders';
UPDATE tiles SET route = '/purchase-orders?action=approve' WHERE title = 'PO Approvals';
UPDATE tiles SET route = '/inventory?action=grn' WHERE title = 'Goods Receipt';
UPDATE tiles SET route = '/materials?action=create' WHERE title = 'Material Master';
UPDATE tiles SET route = '/vendors?action=manage' WHERE title = 'Vendor Management';

-- Finance tiles
UPDATE tiles SET route = '/finance?view=costs' WHERE title = 'Cost Review';
UPDATE tiles SET route = '/finance?view=budget' WHERE title = 'Budget Management';
UPDATE tiles SET route = '/finance?view=analysis' WHERE title = 'Cost Analysis';

-- HR tiles
UPDATE tiles SET route = '/hr?view=timesheet' WHERE title = 'Timesheet Entry';
UPDATE tiles SET route = '/hr?view=approval' WHERE title = 'Timesheet Approval';
UPDATE tiles SET route = '/hr?view=employees' WHERE title = 'Employee Management';

-- Inventory tiles
UPDATE tiles SET route = '/inventory?view=stock' WHERE title = 'Stock Review';
UPDATE tiles SET route = '/inventory?view=transfer' WHERE title = 'Stock Transfer';
UPDATE tiles SET route = '/inventory?view=stores' WHERE title = 'Store Management';

-- Verify updates
SELECT 'UPDATED ROUTES' as status, title, route FROM tiles ORDER BY module_code, title;
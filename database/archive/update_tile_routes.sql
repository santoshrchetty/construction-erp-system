-- Update Tile Routes to Match Existing Pages
-- ==========================================

UPDATE tiles SET route = '/projects' WHERE title = 'Projects Dashboard';
UPDATE tiles SET route = '/projects' WHERE title = 'Create Project';
UPDATE tiles SET route = '/projects' WHERE title = 'Modify Projects';
UPDATE tiles SET route = '/purchase-orders' WHERE title = 'Purchase Orders';
UPDATE tiles SET route = '/purchase-orders' WHERE title = 'PO Approvals';
UPDATE tiles SET route = '/inventory' WHERE title = 'Goods Receipt';
UPDATE tiles SET route = '/materials' WHERE title = 'Material Master';
UPDATE tiles SET route = '/vendors' WHERE title = 'Vendor Management';
UPDATE tiles SET route = '/finance' WHERE title = 'Cost Review';
UPDATE tiles SET route = '/finance' WHERE title = 'Budget Management';
UPDATE tiles SET route = '/finance' WHERE title = 'Cost Analysis';
UPDATE tiles SET route = '/hr' WHERE title = 'Timesheet Entry';
UPDATE tiles SET route = '/hr' WHERE title = 'Timesheet Approval';
UPDATE tiles SET route = '/hr' WHERE title = 'Employee Management';
UPDATE tiles SET route = '/inventory' WHERE title = 'Stock Review';
UPDATE tiles SET route = '/inventory' WHERE title = 'Stock Transfer';
UPDATE tiles SET route = '/inventory' WHERE title = 'Store Management';

-- Create missing routes for activities and tasks
UPDATE tiles SET route = '/dashboard' WHERE title = 'Activity Scheduler';
UPDATE tiles SET route = '/dashboard' WHERE title = 'Activity Execution';
UPDATE tiles SET route = '/dashboard' WHERE title = 'Task Assignment';
UPDATE tiles SET route = '/dashboard' WHERE title = 'Progress Update';
UPDATE tiles SET route = '/dashboard' WHERE title = 'WBS Management';
UPDATE tiles SET route = '/dashboard' WHERE title = 'BOQ Review';
UPDATE tiles SET route = '/dashboard' WHERE title = 'BOQ Modification';
UPDATE tiles SET route = '/dashboard' WHERE title = 'Quality Control';

-- Verify updates
SELECT 'UPDATED ROUTES' as status, title, route FROM tiles ORDER BY module_code, title;
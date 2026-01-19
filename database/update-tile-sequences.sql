-- Update sequence_order for tiles in functional flow order

-- Configuration
UPDATE tiles SET sequence_order = 1 WHERE title = 'Organisation Configuration';
UPDATE tiles SET sequence_order = 2 WHERE title = 'ERP Configuration';
UPDATE tiles SET sequence_order = 3 WHERE title = 'System Configuration';
UPDATE tiles SET sequence_order = 4 WHERE title = 'System Parameters';

-- Administration
UPDATE tiles SET sequence_order = 1 WHERE title = 'User Management';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Role Management';
UPDATE tiles SET sequence_order = 3 WHERE title = 'User Role Assignment';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Authorization Objects';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Approval Configuration';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Document Type Configuration';
UPDATE tiles SET sequence_order = 7 WHERE title = 'Audit Logs';

-- Finance
UPDATE tiles SET sequence_order = 1 WHERE title = 'Chart of Accounts';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Cost Center Accounting';
UPDATE tiles SET sequence_order = 3 WHERE title = 'WBS Management';
UPDATE tiles SET sequence_order = 4 WHERE title = 'GL Account Posting';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Accounts Payable';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Accounts Receivable';
UPDATE tiles SET sequence_order = 7 WHERE title = 'Asset Accounting';
UPDATE tiles SET sequence_order = 8 WHERE title = 'Bank Reconciliation';
UPDATE tiles SET sequence_order = 9 WHERE title = 'Tax Management';
UPDATE tiles SET sequence_order = 10 WHERE title = 'Trial Balance';
UPDATE tiles SET sequence_order = 11 WHERE title = 'Profit & Loss Statement';
UPDATE tiles SET sequence_order = 12 WHERE title = 'Cash Flow Analysis';
UPDATE tiles SET sequence_order = 13 WHERE title = 'Financial Closing';
UPDATE tiles SET sequence_order = 14 WHERE title = 'Audit Trail';
UPDATE tiles SET sequence_order = 15 WHERE title = 'Financial Reports';

-- Materials
UPDATE tiles SET sequence_order = 1 WHERE title = 'Create Material Master';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Display Material Master';
UPDATE tiles SET sequence_order = 3 WHERE title = 'Maintain Material Master';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Extend Material to Plant';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Material Plant Parameters';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Material Pricing';
UPDATE tiles SET sequence_order = 7 WHERE title = 'Bulk Upload Materials';
UPDATE tiles SET sequence_order = 8 WHERE title = 'Material Stock Overview';
UPDATE tiles SET sequence_order = 9 WHERE title = 'Material Reservations';
UPDATE tiles SET sequence_order = 10 WHERE title = 'Material Forecast';
UPDATE tiles SET sequence_order = 11 WHERE title = 'Stock Movement';
UPDATE tiles SET sequence_order = 12 WHERE title = 'Movement History';
UPDATE tiles SET sequence_order = 13 WHERE title = 'Material Reports';

-- Procurement
UPDATE tiles SET sequence_order = 1 WHERE title = 'Material Requests';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Purchase Requisitions';
UPDATE tiles SET sequence_order = 3 WHERE title = 'Material Request Approvals';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Request Status Tracking';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Purchase Orders';
UPDATE tiles SET sequence_order = 6 WHERE title = 'PO Approvals';
UPDATE tiles SET sequence_order = 7 WHERE title = 'PO Overview';
UPDATE tiles SET sequence_order = 8 WHERE title = 'Vendor Master';
UPDATE tiles SET sequence_order = 9 WHERE title = 'Vendor Evaluation';
UPDATE tiles SET sequence_order = 10 WHERE title = 'Contract Management';
UPDATE tiles SET sequence_order = 11 WHERE title = 'RFQ Management';
UPDATE tiles SET sequence_order = 12 WHERE title = 'Source List';
UPDATE tiles SET sequence_order = 13 WHERE title = 'Purchase Analytics';
UPDATE tiles SET sequence_order = 14 WHERE title = 'Delegation Reports';

-- Warehouse
UPDATE tiles SET sequence_order = 1 WHERE title = 'Warehouse Overview';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Goods Receipt';
UPDATE tiles SET sequence_order = 3 WHERE title = 'Goods Issue';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Goods Transfer';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Inventory Management';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Physical Inventory';
UPDATE tiles SET sequence_order = 7 WHERE title = 'Cycle Counting';
UPDATE tiles SET sequence_order = 8 WHERE title = 'Inventory Adjustments';
UPDATE tiles SET sequence_order = 9 WHERE title = 'Bin Management';
UPDATE tiles SET sequence_order = 10 WHERE title = 'Warehouse Reports';

-- Project Management
UPDATE tiles SET sequence_order = 1 WHERE title = 'Projects Dashboard';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Create Project';
UPDATE tiles SET sequence_order = 3 WHERE title = 'Activities';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Tasks';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Schedule';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Resource Planning';
UPDATE tiles SET sequence_order = 7 WHERE title = 'Cost Management';

-- Quality
UPDATE tiles SET sequence_order = 1 WHERE title = 'Quality Control';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Create Inspection';
UPDATE tiles SET sequence_order = 3 WHERE title = 'Quality Inspections';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Quality Certificates';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Compliance Check';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Quality Reports';

-- Safety
UPDATE tiles SET sequence_order = 1 WHERE title = 'Create Incident';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Safety Incidents';
UPDATE tiles SET sequence_order = 3 WHERE title = 'Safety Audits';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Safety Training';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Safety Compliance';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Safety Reports';

-- Human Resources
UPDATE tiles SET sequence_order = 1 WHERE title = 'Employee Overview';
UPDATE tiles SET sequence_order = 2 WHERE title = 'Create Employee';
UPDATE tiles SET sequence_order = 3 WHERE title = 'Attendance Tracking';
UPDATE tiles SET sequence_order = 4 WHERE title = 'Timesheet Overview';
UPDATE tiles SET sequence_order = 5 WHERE title = 'Timesheet Approval';
UPDATE tiles SET sequence_order = 6 WHERE title = 'Leave Management';
UPDATE tiles SET sequence_order = 7 WHERE title = 'Payroll Processing';
UPDATE tiles SET sequence_order = 8 WHERE title = 'HR Reports';

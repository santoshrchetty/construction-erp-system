-- Sample Data for Construction Management SaaS
-- =====================================================

-- Sample Project
INSERT INTO projects (id, name, code, project_type, status, start_date, planned_end_date, budget, location) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Downtown Office Complex', 'DOC-2024-001', 'commercial', 'active', '2024-01-15', '2024-12-31', 5000000.00, 'Downtown Business District');

-- Sample WBS Structure
INSERT INTO wbs_nodes (id, project_id, parent_id, code, name, node_type, level, sequence_order, budget_allocation) VALUES
('550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440001', NULL, 'DOC-01', 'Foundation Phase', 'phase', 1, 1, 1500000.00),
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440010', 'DOC-01.01', 'Site Preparation', 'deliverable', 2, 1, 300000.00),
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440010', 'DOC-01.02', 'Foundation Work', 'deliverable', 2, 2, 1200000.00),
('550e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440001', NULL, 'DOC-02', 'Structure Phase', 'phase', 1, 2, 2500000.00),
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440020', 'DOC-02.01', 'Steel Structure', 'deliverable', 2, 1, 1500000.00);

-- Sample Activities
INSERT INTO activities (id, project_id, wbs_node_id, code, name, planned_start_date, planned_end_date, budget_amount) VALUES
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'ACT-001', 'Site Clearing', '2024-01-15', '2024-01-30', 150000.00),
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'ACT-002', 'Excavation', '2024-02-01', '2024-02-15', 150000.00),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'ACT-003', 'Foundation Concrete', '2024-02-16', '2024-03-15', 600000.00);

-- Sample Tasks
INSERT INTO tasks (id, project_id, activity_id, name, status, priority, planned_start_date, planned_end_date, planned_hours, assigned_to, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', 'Remove existing vegetation', 'completed', 'medium', '2024-01-15', '2024-01-20', 40.0, '550e8400-e29b-41d4-a716-446655440500', '550e8400-e29b-41d4-a716-446655440500'),
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', 'Level the site', 'in_progress', 'high', '2024-01-21', '2024-01-30', 80.0, '550e8400-e29b-41d4-a716-446655440501', '550e8400-e29b-41d4-a716-446655440500'),
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440101', 'Mark excavation boundaries', 'not_started', 'medium', '2024-02-01', '2024-02-03', 24.0, '550e8400-e29b-41d4-a716-446655440502', '550e8400-e29b-41d4-a716-446655440500');

-- Sample Cost Objects
INSERT INTO cost_objects (id, project_id, wbs_node_id, activity_id, task_id, code, name, cost_type, budget_amount) VALUES
('550e8400-e29b-41d4-a716-446655440300', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440200', 'COST-001', 'Site Clearing Labor', 'labor', 25000.00),
('550e8400-e29b-41d4-a716-446655440301', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440200', 'COST-002', 'Site Clearing Equipment', 'equipment', 15000.00),
('550e8400-e29b-41d4-a716-446655440302', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440102', NULL, 'COST-003', 'Concrete Materials', 'material', 400000.00);

-- Sample BOQ Categories
INSERT INTO boq_categories (id, project_id, name, code, sequence_order) VALUES
('550e8400-e29b-41d4-a716-446655440400', '550e8400-e29b-41d4-a716-446655440001', 'Earthwork', 'EW', 1),
('550e8400-e29b-41d4-a716-446655440401', '550e8400-e29b-41d4-a716-446655440001', 'Concrete Work', 'CW', 2),
('550e8400-e29b-41d4-a716-446655440402', '550e8400-e29b-41d4-a716-446655440001', 'Steel Work', 'SW', 3);

-- Sample BOQ Items
INSERT INTO boq_items (id, project_id, wbs_node_id, category_id, item_code, description, unit, quantity, rate) VALUES
('550e8400-e29b-41d4-a716-446655440410', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440400', 'EW-001', 'Site clearing and grubbing', 'sqm', 5000.0000, 15.00),
('550e8400-e29b-41d4-a716-446655440411', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440400', 'EW-002', 'Excavation for foundation', 'cum', 2500.0000, 45.00),
('550e8400-e29b-41d4-a716-446655440412', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440401', 'CW-001', 'Ready mix concrete M25', 'cum', 800.0000, 4500.00);

-- Sample Vendors
INSERT INTO vendors (id, name, code, contact_person, email, phone, status, specializations) VALUES
('550e8400-e29b-41d4-a716-446655440600', 'ABC Construction Supplies', 'VEN-001', 'John Smith', 'john@abcsupplies.com', '+1-555-0101', 'active', ARRAY['concrete', 'steel', 'aggregates']),
('550e8400-e29b-41d4-a716-446655440601', 'XYZ Equipment Rental', 'VEN-002', 'Sarah Johnson', 'sarah@xyzrental.com', '+1-555-0102', 'active', ARRAY['excavators', 'cranes', 'concrete_pumps']),
('550e8400-e29b-41d4-a716-446655440602', 'Elite Subcontractors Ltd', 'VEN-003', 'Mike Wilson', 'mike@elitesub.com', '+1-555-0103', 'active', ARRAY['earthwork', 'concrete_work']);

-- Sample Subcontractor
INSERT INTO subcontractors (id, vendor_id, license_number, license_expiry, safety_rating) VALUES
('550e8400-e29b-41d4-a716-446655440610', '550e8400-e29b-41d4-a716-446655440602', 'LIC-2024-001', '2025-12-31', 4.5);

-- Sample Purchase Order
INSERT INTO purchase_orders (id, project_id, po_number, vendor_id, status, issue_date, delivery_date, total_amount, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440700', '550e8400-e29b-41d4-a716-446655440001', 'PO-2024-001', '550e8400-e29b-41d4-a716-446655440600', 'approved', '2024-01-20', '2024-02-20', 3600000.00, '550e8400-e29b-41d4-a716-446655440500');

-- Sample PO Lines
INSERT INTO po_lines (id, po_id, line_number, boq_item_id, description, quantity, unit, unit_rate) VALUES
('550e8400-e29b-41d4-a716-446655440710', '550e8400-e29b-41d4-a716-446655440700', 1, '550e8400-e29b-41d4-a716-446655440412', 'Ready mix concrete M25', 800.0000, 'cum', 4500.00);

-- Sample Store
INSERT INTO stores (id, project_id, name, code, location) VALUES
('550e8400-e29b-41d4-a716-446655440800', '550e8400-e29b-41d4-a716-446655440001', 'Main Site Store', 'STORE-01', 'Site Office Complex');

-- Sample Stock Items
INSERT INTO stock_items (id, item_code, description, category, unit) VALUES
('550e8400-e29b-41d4-a716-446655440810', 'CONC-M25', 'Ready Mix Concrete M25', 'Concrete', 'cum'),
('550e8400-e29b-41d4-a716-446655440811', 'STEEL-12MM', 'Steel Rebar 12mm', 'Steel', 'kg'),
('550e8400-e29b-41d4-a716-446655440812', 'CEMENT-OPC', 'Ordinary Portland Cement', 'Cement', 'bag');

-- Sample Goods Receipt
INSERT INTO goods_receipts (id, project_id, po_id, store_id, grn_number, vendor_id, receipt_date, received_by, status) VALUES
('550e8400-e29b-41d4-a716-446655440900', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440700', '550e8400-e29b-41d4-a716-446655440800', 'GRN-2024-001', '550e8400-e29b-41d4-a716-446655440600', '2024-02-20', '550e8400-e29b-41d4-a716-446655440501', 'received');

-- Sample GRN Line
INSERT INTO grn_lines (id, grn_id, po_line_id, ordered_quantity, received_quantity, accepted_quantity, unit_rate, quality_status) VALUES
('550e8400-e29b-41d4-a716-446655440910', '550e8400-e29b-41d4-a716-446655440900', '550e8400-e29b-41d4-a716-446655440710', 800.0000, 800.0000, 800.0000, 4500.00, 'passed');

-- Sample Timesheet
INSERT INTO timesheets (id, user_id, project_id, week_ending_date, status, total_hours) VALUES
('550e8400-e29b-41d4-a716-446655441000', '550e8400-e29b-41d4-a716-446655440500', '550e8400-e29b-41d4-a716-446655440001', '2024-01-26', 'approved', 40.0);

-- Sample Timesheet Entries
INSERT INTO timesheet_entries (id, timesheet_id, task_id, cost_object_id, entry_date, hours, description) VALUES
('550e8400-e29b-41d4-a716-446655441010', '550e8400-e29b-41d4-a716-446655441000', '550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440300', '2024-01-22', 8.0, 'Site clearing work'),
('550e8400-e29b-41d4-a716-446655441011', '550e8400-e29b-41d4-a716-446655441000', '550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440300', '2024-01-23', 8.0, 'Site clearing work'),
('550e8400-e29b-41d4-a716-446655441012', '550e8400-e29b-41d4-a716-446655441000', '550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440300', '2024-01-24', 8.0, 'Site clearing work'),
('550e8400-e29b-41d4-a716-446655441013', '550e8400-e29b-41d4-a716-446655441000', '550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440300', '2024-01-25', 8.0, 'Site clearing work'),
('550e8400-e29b-41d4-a716-446655441014', '550e8400-e29b-41d4-a716-446655441000', '550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440300', '2024-01-26', 8.0, 'Site clearing work');

-- Sample Actual Costs
INSERT INTO actual_costs (id, project_id, cost_object_id, task_id, cost_type, amount, cost_date, reference_type, reference_id, created_by) VALUES
('550e8400-e29b-41d4-a716-446655441100', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440300', '550e8400-e29b-41d4-a716-446655440200', 'labor', 2000.00, '2024-01-26', 'TIMESHEET', '550e8400-e29b-41d4-a716-446655441000', '550e8400-e29b-41d4-a716-446655440500'),
('550e8400-e29b-41d4-a716-446655441101', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440302', NULL, 'material', 3600000.00, '2024-02-20', 'GRN', '550e8400-e29b-41d4-a716-446655440900', '550e8400-e29b-41d4-a716-446655440501');
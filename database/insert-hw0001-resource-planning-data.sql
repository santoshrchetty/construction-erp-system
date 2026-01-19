-- Sample Resource Planning Data for Project HW-0001 (National Highway 90)

-- ============================================
-- ACTIVITY MATERIALS
-- ============================================

-- Activity 1: Site Survey & Marking
INSERT INTO activity_materials (activity_id, material_id, required_quantity, unit_of_measure, unit_cost, priority_level, notes) VALUES
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'c1903a24-ce37-492e-be02-9eee1df9a571', 50, 'BAG', 8.50, 'normal', 'Marking paint base'),
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'bc42a47a-d2cc-41ee-90a2-5c8070208e48', 100, 'M', 2.75, 'high', 'Survey stakes');

-- Activity 2: Clear Vegetation
INSERT INTO activity_materials (activity_id, material_id, required_quantity, unit_of_measure, unit_cost, priority_level, notes) VALUES
('c247153f-3382-47b2-b629-444f2656a52f', '7f5b94e3-e1c4-48ca-bf12-9728759afe48', 20, 'M3', 25.00, 'normal', 'Backfill material');

-- Activity 3: Demolition of Existing Structures
INSERT INTO activity_materials (activity_id, material_id, required_quantity, unit_of_measure, unit_cost, priority_level, notes) VALUES
('6b35babc-fba3-4705-a709-a08321f188f5', 'c1903a24-ce37-492e-be02-9eee1df9a571', 200, 'BAG', 8.50, 'high', 'Temporary support'),
('6b35babc-fba3-4705-a709-a08321f188f5', 'bc42a47a-d2cc-41ee-90a2-5c8070208e48', 500, 'M', 2.75, 'critical', 'Reinforcement');

-- Activity 5: Excavation & Grading
INSERT INTO activity_materials (activity_id, material_id, required_quantity, unit_of_measure, unit_cost, priority_level, notes) VALUES
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', '7f5b94e3-e1c4-48ca-bf12-9728759afe48', 500, 'M3', 25.00, 'critical', 'Base course material'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'c1903a24-ce37-492e-be02-9eee1df9a571', 300, 'BAG', 8.50, 'high', 'Stabilization');

-- ============================================
-- ACTIVITY EQUIPMENT
-- ============================================

-- Activity 1: Site Survey & Marking
INSERT INTO activity_equipment (activity_id, equipment_code, equipment_name, required_hours, hourly_rate, priority_level, notes) VALUES
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'EQ-SURVEY-01', 'Total Station', 40, 15.00, 'critical', 'Precision surveying'),
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'EQ-VEH-01', 'Survey Vehicle', 40, 8.00, 'normal', 'Site access');

-- Activity 2: Clear Vegetation
INSERT INTO activity_equipment (activity_id, equipment_code, equipment_name, required_hours, hourly_rate, priority_level, notes) VALUES
('c247153f-3382-47b2-b629-444f2656a52f', 'EQ-BULL-01', 'Bulldozer D6', 80, 120.00, 'critical', 'Vegetation clearing'),
('c247153f-3382-47b2-b629-444f2656a52f', 'EQ-CHAIN-01', 'Chainsaw', 60, 5.00, 'high', 'Tree cutting');

-- Activity 3: Demolition
INSERT INTO activity_equipment (activity_id, equipment_code, equipment_name, required_hours, hourly_rate, priority_level, notes) VALUES
('6b35babc-fba3-4705-a709-a08321f188f5', 'EQ-EXC-01', 'Hydraulic Excavator', 100, 150.00, 'critical', 'Demolition work'),
('6b35babc-fba3-4705-a709-a08321f188f5', 'EQ-BREAK-01', 'Hydraulic Breaker', 80, 45.00, 'high', 'Concrete breaking');

-- Activity 5: Excavation & Grading
INSERT INTO activity_equipment (activity_id, equipment_code, equipment_name, required_hours, hourly_rate, priority_level, notes) VALUES
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'EQ-EXC-02', 'Excavator CAT 320', 200, 180.00, 'critical', 'Mass excavation'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'EQ-GRAD-01', 'Motor Grader', 150, 140.00, 'critical', 'Grading work'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'EQ-ROLL-01', 'Vibratory Roller', 120, 85.00, 'high', 'Compaction');

-- ============================================
-- ACTIVITY MANPOWER
-- ============================================

-- Activity 1: Site Survey & Marking
INSERT INTO activity_manpower (activity_id, role, crew_size, required_hours, hourly_rate, priority_level, notes) VALUES
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'Survey Engineer', 2, 40, 35.00, 'critical', 'Lead surveying'),
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'Survey Assistant', 4, 40, 18.00, 'high', 'Survey support'),
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'Laborer', 6, 40, 12.00, 'normal', 'Marking work');

-- Activity 2: Clear Vegetation
INSERT INTO activity_manpower (activity_id, role, crew_size, required_hours, hourly_rate, priority_level, notes) VALUES
('c247153f-3382-47b2-b629-444f2656a52f', 'Site Supervisor', 1, 80, 40.00, 'high', 'Clearing supervision'),
('c247153f-3382-47b2-b629-444f2656a52f', 'Equipment Operator', 2, 80, 28.00, 'critical', 'Bulldozer operation'),
('c247153f-3382-47b2-b629-444f2656a52f', 'Laborer', 10, 80, 12.00, 'normal', 'Manual clearing');

-- Activity 3: Demolition
INSERT INTO activity_manpower (activity_id, role, crew_size, required_hours, hourly_rate, priority_level, notes) VALUES
('6b35babc-fba3-4705-a709-a08321f188f5', 'Demolition Supervisor', 1, 100, 45.00, 'critical', 'Safety oversight'),
('6b35babc-fba3-4705-a709-a08321f188f5', 'Equipment Operator', 2, 100, 30.00, 'critical', 'Excavator operation'),
('6b35babc-fba3-4705-a709-a08321f188f5', 'Safety Officer', 1, 100, 38.00, 'critical', 'Safety monitoring'),
('6b35babc-fba3-4705-a709-a08321f188f5', 'Laborer', 8, 100, 12.00, 'high', 'Debris handling');

-- Activity 5: Excavation & Grading
INSERT INTO activity_manpower (activity_id, role, crew_size, required_hours, hourly_rate, priority_level, notes) VALUES
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'Civil Engineer', 1, 200, 50.00, 'critical', 'Technical supervision'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'Site Supervisor', 2, 200, 40.00, 'high', 'Work coordination'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'Equipment Operator', 4, 200, 30.00, 'critical', 'Heavy equipment'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'Survey Technician', 2, 200, 22.00, 'high', 'Grade checking'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'Laborer', 15, 200, 12.00, 'normal', 'General support');

-- ============================================
-- ACTIVITY SERVICES
-- ============================================

-- Activity 1: Site Survey & Marking
INSERT INTO activity_services (activity_id, service_type, service_description, scheduled_date, duration_hours, unit_cost, priority_level) VALUES
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'survey', 'Topographic Survey & Mapping', '2026-01-23', 16, 2500.00, 'critical'),
('6f9b9bb1-9e72-436a-b682-f80abd9ebf71', 'testing', 'Soil Testing - Initial', '2026-01-27', 8, 800.00, 'high');

-- Activity 3: Demolition
INSERT INTO activity_services (activity_id, service_type, service_description, scheduled_date, duration_hours, unit_cost, priority_level) VALUES
('6b35babc-fba3-4705-a709-a08321f188f5', 'inspection', 'Structural Safety Inspection', '2026-01-22', 4, 1200.00, 'critical'),
('6b35babc-fba3-4705-a709-a08321f188f5', 'testing', 'Asbestos Testing', '2026-01-23', 6, 950.00, 'critical');

-- Activity 5: Excavation & Grading
INSERT INTO activity_services (activity_id, service_type, service_description, scheduled_date, duration_hours, unit_cost, priority_level) VALUES
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'testing', 'Soil Compaction Testing', '2026-02-10', 12, 1500.00, 'critical'),
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'survey', 'Grade Verification Survey', '2026-02-15', 8, 1800.00, 'high');

-- ============================================
-- ACTIVITY SUBCONTRACTORS
-- ============================================

-- Activity 2: Clear Vegetation
INSERT INTO activity_subcontractors (activity_id, trade, scope_of_work, crew_size, contract_value, priority_level) VALUES
('c247153f-3382-47b2-b629-444f2656a52f', 'landscaping', 'Tree removal and disposal of vegetation waste', 8, 15000.00, 'high');

-- Activity 3: Demolition
INSERT INTO activity_subcontractors (activity_id, trade, scope_of_work, crew_size, contract_value, priority_level) VALUES
('6b35babc-fba3-4705-a709-a08321f188f5', 'concrete', 'Concrete demolition and disposal', 6, 25000.00, 'critical'),
('6b35babc-fba3-4705-a709-a08321f188f5', 'steel', 'Steel structure dismantling', 4, 18000.00, 'high');

-- Activity 5: Excavation & Grading
INSERT INTO activity_subcontractors (activity_id, trade, scope_of_work, crew_size, contract_value, priority_level) VALUES
('6aa3612f-19a2-4330-a8b9-bfec40ae6be9', 'concrete', 'Base course preparation and compaction', 10, 45000.00, 'critical');

-- Verify data inserted
SELECT 'Materials' as resource_type, COUNT(*) as count FROM activity_materials WHERE activity_id IN (
  '6f9b9bb1-9e72-436a-b682-f80abd9ebf71',
  'c247153f-3382-47b2-b629-444f2656a52f',
  '6b35babc-fba3-4705-a709-a08321f188f5',
  '6aa3612f-19a2-4330-a8b9-bfec40ae6be9'
)
UNION ALL
SELECT 'Equipment', COUNT(*) FROM activity_equipment WHERE activity_id IN (
  '6f9b9bb1-9e72-436a-b682-f80abd9ebf71',
  'c247153f-3382-47b2-b629-444f2656a52f',
  '6b35babc-fba3-4705-a709-a08321f188f5',
  '6aa3612f-19a2-4330-a8b9-bfec40ae6be9'
)
UNION ALL
SELECT 'Manpower', COUNT(*) FROM activity_manpower WHERE activity_id IN (
  '6f9b9bb1-9e72-436a-b682-f80abd9ebf71',
  'c247153f-3382-47b2-b629-444f2656a52f',
  '6b35babc-fba3-4705-a709-a08321f188f5',
  '6aa3612f-19a2-4330-a8b9-bfec40ae6be9'
)
UNION ALL
SELECT 'Services', COUNT(*) FROM activity_services WHERE activity_id IN (
  '6f9b9bb1-9e72-436a-b682-f80abd9ebf71',
  'c247153f-3382-47b2-b629-444f2656a52f',
  '6b35babc-fba3-4705-a709-a08321f188f5',
  '6aa3612f-19a2-4330-a8b9-bfec40ae6be9'
)
UNION ALL
SELECT 'Subcontractors', COUNT(*) FROM activity_subcontractors WHERE activity_id IN (
  '6f9b9bb1-9e72-436a-b682-f80abd9ebf71',
  'c247153f-3382-47b2-b629-444f2656a52f',
  '6b35babc-fba3-4705-a709-a08321f188f5',
  '6aa3612f-19a2-4330-a8b9-bfec40ae6be9'
);

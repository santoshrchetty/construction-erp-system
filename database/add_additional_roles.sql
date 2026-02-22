-- Add additional role codes to roles_master table
INSERT INTO roles_master (role_code, role_name, description)
VALUES 
  ('CFO', 'Chief Financial Officer', 'Company-level financial authority'),
  ('FINANCE_CONTROLLER', 'Finance Controller', 'Company-level finance control'),
  ('FINANCE_MANAGER', 'Finance Manager', 'Company-level finance management'),
  ('PLANT_MANAGER', 'Plant Manager', 'Plant-level management authority'),
  ('ELECTRICAL_ENGINEER', 'Electrical Engineer', 'Electrical engineering specialist'),
  ('MECHANICAL_ENGINEER', 'Mechanical Engineer', 'Mechanical engineering specialist'),
  ('STRUCTURAL_ENGINEER', 'Structural Engineer', 'Structural engineering specialist'),
  ('SAFETY_OFFICER', 'Safety Officer', 'Plant safety officer')
ON CONFLICT (role_code) DO NOTHING;

-- Verify all roles
SELECT * FROM roles_master ORDER BY role_code;

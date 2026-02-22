-- Roles Master Table
-- Defines valid role codes that can be assigned to employees

CREATE TABLE IF NOT EXISTS roles_master (
  role_code VARCHAR(50) PRIMARY KEY,
  role_name VARCHAR(200) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key to role_assignments
ALTER TABLE role_assignments 
  DROP CONSTRAINT IF EXISTS fk_role_assignments_role;

ALTER TABLE role_assignments 
  ADD CONSTRAINT fk_role_assignments_role 
  FOREIGN KEY (role_code) REFERENCES roles_master(role_code);

-- Insert standard approval roles
INSERT INTO roles_master (role_code, role_name, description)
VALUES 
  ('DEPT_HEAD', 'Department Head', 'Head of department with approval authority'),
  ('PLANT_MGR', 'Plant Manager', 'Plant manager with approval authority for plant-level requests')
ON CONFLICT (role_code) DO NOTHING;

-- Verify
SELECT * FROM roles_master ORDER BY role_code;

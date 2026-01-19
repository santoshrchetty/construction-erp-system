-- Drop existing tables
DROP TABLE IF EXISTS employee_documents CASCADE;
DROP TABLE IF EXISTS employee_skills CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

-- Create clean employees table
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200),
    phone VARCHAR(50),
    mobile VARCHAR(50),
    employment_type VARCHAR(20) CHECK (employment_type IN ('permanent', 'contract', 'temporary', 'consultant')),
    join_date DATE NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    base_salary DECIMAL(12,2),
    hourly_rate DECIMAL(10,2),
    overtime_rate DECIMAL(10,2),
    company_code VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_employees_code ON employees(employee_code);
CREATE INDEX idx_employees_active ON employees(is_active);

-- Insert sample employees
INSERT INTO employees (employee_code, first_name, last_name, email, mobile, employment_type, join_date, job_title, department, base_salary, hourly_rate, overtime_rate, company_code) VALUES
('EMP-001', 'Rajesh', 'Kumar', 'rajesh.kumar@company.com', '+91-9876543210', 'permanent', '2020-01-15', 'Civil Engineer', 'Engineering', 80000.00, 35.00, 52.50, 'C001'),
('EMP-002', 'Priya', 'Sharma', 'priya.sharma@company.com', '+91-9876543211', 'permanent', '2019-06-01', 'Project Manager', 'Projects', 120000.00, 50.00, 75.00, 'C001'),
('EMP-003', 'Mohammed', 'Ali', 'mohammed.ali@company.com', '+91-9876543212', 'permanent', '2021-03-10', 'Site Supervisor', 'Operations', 60000.00, 28.00, 42.00, 'C001'),
('EMP-004', 'Sunita', 'Patel', 'sunita.patel@company.com', '+91-9876543213', 'permanent', '2020-08-20', 'Quantity Surveyor', 'Engineering', 70000.00, 32.00, 48.00, 'C001'),
('EMP-005', 'Amit', 'Singh', 'amit.singh@company.com', '+91-9876543214', 'contract', '2023-01-05', 'Safety Officer', 'Safety', 55000.00, 25.00, 37.50, 'C001'),
('EMP-006', 'Lakshmi', 'Reddy', 'lakshmi.reddy@company.com', '+91-9876543215', 'permanent', '2018-11-12', 'Senior Engineer', 'Engineering', 95000.00, 42.00, 63.00, 'C001'),
('EMP-007', 'Vikram', 'Mehta', 'vikram.mehta@company.com', '+91-9876543216', 'permanent', '2022-02-28', 'Surveyor', 'Engineering', 50000.00, 22.00, 33.00, 'C001'),
('EMP-008', 'Anita', 'Desai', 'anita.desai@company.com', '+91-9876543217', 'temporary', '2024-01-10', 'Site Engineer', 'Operations', 45000.00, 20.00, 30.00, 'C001');

-- Verify
SELECT COUNT(*) as employee_count FROM employees;
SELECT employee_code, first_name || ' ' || last_name as full_name, job_title, hourly_rate FROM employees;

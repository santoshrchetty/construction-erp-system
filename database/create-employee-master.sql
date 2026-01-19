-- Employee Master Data Structure
-- Integrates with: activity_manpower, timesheets, payroll, leave management

-- 1. Employees Master Table
CREATE TABLE IF NOT EXISTS employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Personal Information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    date_of_birth DATE,
    gender VARCHAR(20),
    nationality VARCHAR(50),
    
    -- Contact Information
    email VARCHAR(200),
    phone VARCHAR(50),
    mobile VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    
    -- Employment Details
    employment_type VARCHAR(20) CHECK (employment_type IN ('permanent', 'contract', 'temporary', 'consultant')),
    employment_status VARCHAR(20) DEFAULT 'active' CHECK (employment_status IN ('active', 'inactive', 'terminated', 'on_leave')),
    join_date DATE NOT NULL,
    termination_date DATE,
    
    -- Job Details
    job_title VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    division VARCHAR(100),
    reporting_to UUID REFERENCES employees(id),
    
    -- Compensation
    base_salary DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'INR',
    hourly_rate DECIMAL(10,2),
    overtime_rate DECIMAL(10,2),
    
    -- Company Assignment
    company_code VARCHAR(10),
    cost_center VARCHAR(20),
    
    -- System Fields
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- 2. Employee Skills & Certifications
CREATE TABLE IF NOT EXISTS employee_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    skill_category VARCHAR(50),
    proficiency_level VARCHAR(20) CHECK (proficiency_level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    certification_name VARCHAR(200),
    certification_number VARCHAR(100),
    issued_date DATE,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Employee Documents
CREATE TABLE IF NOT EXISTS employee_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_name VARCHAR(200) NOT NULL,
    document_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    file_path TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_employees_code ON employees(employee_code);
CREATE INDEX IF NOT EXISTS idx_employees_status ON employees(is_active);
CREATE INDEX IF NOT EXISTS idx_employees_company ON employees(company_code);
CREATE INDEX IF NOT EXISTS idx_employee_skills_emp ON employee_skills(employee_id);
CREATE INDEX IF NOT EXISTS idx_employee_docs_emp ON employee_documents(employee_id);

-- Triggers
CREATE OR REPLACE FUNCTION update_employees_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_employees_timestamp
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION update_employees_timestamp();

-- Sample Employee Data
INSERT INTO employees (
    employee_code, first_name, last_name, email, phone, mobile,
    employment_type, join_date, job_title, department,
    base_salary, hourly_rate, overtime_rate, company_code, is_active
) VALUES
('EMP-001', 'Rajesh', 'Kumar', 'rajesh.kumar@company.com', '+91-11-12345678', '+91-9876543210',
 'permanent', '2020-01-15', 'Civil Engineer', 'Engineering', 80000.00, 35.00, 52.50, 'C001', true),
 
('EMP-002', 'Priya', 'Sharma', 'priya.sharma@company.com', '+91-11-12345679', '+91-9876543211',
 'permanent', '2019-06-01', 'Project Manager', 'Projects', 120000.00, 50.00, 75.00, 'C001', true),
 
('EMP-003', 'Mohammed', 'Ali', 'mohammed.ali@company.com', '+91-11-12345680', '+91-9876543212',
 'permanent', '2021-03-10', 'Site Supervisor', 'Operations', 60000.00, 28.00, 42.00, 'C001', true),
 
('EMP-004', 'Sunita', 'Patel', 'sunita.patel@company.com', '+91-11-12345681', '+91-9876543213',
 'permanent', '2020-08-20', 'Quantity Surveyor', 'Engineering', 70000.00, 32.00, 48.00, 'C001', true),
 
('EMP-005', 'Amit', 'Singh', 'amit.singh@company.com', '+91-11-12345682', '+91-9876543214',
 'contract', '2023-01-05', 'Safety Officer', 'Safety', 55000.00, 25.00, 37.50, 'C001', true),
 
('EMP-006', 'Lakshmi', 'Reddy', 'lakshmi.reddy@company.com', '+91-11-12345683', '+91-9876543215',
 'permanent', '2018-11-12', 'Senior Engineer', 'Engineering', 95000.00, 42.00, 63.00, 'C001', true),
 
('EMP-007', 'Vikram', 'Mehta', 'vikram.mehta@company.com', '+91-11-12345684', '+91-9876543216',
 'permanent', '2022-02-28', 'Surveyor', 'Engineering', 50000.00, 22.00, 33.00, 'C001', true),
 
('EMP-008', 'Anita', 'Desai', 'anita.desai@company.com', '+91-11-12345685', '+91-9876543217',
 'temporary', '2024-01-10', 'Site Engineer', 'Operations', 45000.00, 20.00, 30.00, 'C001', true)
 
ON CONFLICT (employee_code) DO NOTHING;

-- Sample Skills
INSERT INTO employee_skills (employee_id, skill_name, skill_category, proficiency_level, certification_name, issued_date)
SELECT 
    id,
    CASE 
        WHEN job_title LIKE '%Engineer%' THEN 'AutoCAD'
        WHEN job_title LIKE '%Manager%' THEN 'Project Management'
        WHEN job_title LIKE '%Surveyor%' THEN 'Total Station Operation'
        ELSE 'General Construction'
    END,
    'Technical',
    'advanced',
    CASE 
        WHEN job_title LIKE '%Engineer%' THEN 'AutoCAD Certified Professional'
        WHEN job_title LIKE '%Manager%' THEN 'PMP Certification'
        ELSE NULL
    END,
    join_date + INTERVAL '6 months'
FROM employees
WHERE is_active = true;

-- Verify
SELECT COUNT(*) as employee_count FROM employees;
SELECT employee_code, full_name, job_title, hourly_rate FROM employees LIMIT 5;

COMMENT ON TABLE employees IS 'Employee Master Data - Integrates with activity_manpower, timesheets, payroll';
COMMENT ON COLUMN employees.employment_type IS 'permanent, contract, temporary, consultant';
COMMENT ON COLUMN employees.hourly_rate IS 'Standard hourly rate for resource planning and timesheets';

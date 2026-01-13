-- Create persons_responsible table in main database
CREATE TABLE IF NOT EXISTS persons_responsible (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    company_code VARCHAR(10)
);

-- Insert sample data
INSERT INTO persons_responsible (name, role, email, company_code) VALUES 
('John Manager', 'project_manager', 'john@nttdemo.com', 'C001'),
('Jane Engineer', 'site_supervisor', 'jane@nttdemo.com', 'C001'),
('Bob Architect', 'architect', 'bob@nttdemo.com', 'C001'),
('Sarah Director', 'project_director', 'sarah@nttdemo.com', 'C001'),
('Mike Supervisor', 'construction_supervisor', 'mike@nttdemo.com', 'C001')
ON CONFLICT DO NOTHING;
-- DYNAMIC APPROVAL ROLE MANAGEMENT

-- Create approval roles table (configurable, not hardcoded)
CREATE TABLE IF NOT EXISTS approval_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_code VARCHAR(50) UNIQUE NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    department_code VARCHAR(20),
    approval_authority_level INTEGER DEFAULT 1, -- 1=Supervisor, 2=Manager, 3=Director, 4=VP, 5=C-Level
    approval_limit DECIMAL(15,2) DEFAULT 0,
    approval_limit_currency VARCHAR(3) DEFAULT 'USD',
    functional_domains TEXT[] DEFAULT '{}', -- FINANCE, LEGAL, SAFETY, QUALITY
    organizational_scope VARCHAR(20) DEFAULT 'DEPARTMENT', -- DEPARTMENT, COUNTRY, GLOBAL
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert configurable approval roles (not hardcoded)
INSERT INTO approval_roles (role_code, role_name, department_code, approval_authority_level, approval_limit, functional_domains, organizational_scope) VALUES
-- Engineering Department Roles
('ENG_SUPERVISOR', 'Engineering Supervisor', 'ENG', 1, 25000, '{}', 'DEPARTMENT'),
('ENG_MANAGER', 'Engineering Manager', 'ENG', 2, 100000, '{FINANCE}', 'DEPARTMENT'),
('ENG_DIRECTOR', 'Engineering Director', 'ENG', 3, 999999999, '{FINANCE}', 'COUNTRY'),

-- Construction Department Roles  
('CONST_SUPERVISOR', 'Construction Supervisor', 'CONST', 1, 50000, '{SAFETY}', 'DEPARTMENT'),
('CONST_MANAGER', 'Construction Manager', 'CONST', 2, 200000, '{FINANCE,SAFETY}', 'DEPARTMENT'),
('CONST_DIRECTOR', 'Construction Director', 'CONST', 3, 999999999, '{FINANCE,SAFETY}', 'COUNTRY'),

-- Procurement Department Roles
('PROC_BUYER', 'Procurement Buyer', 'PROC', 1, 100000, '{}', 'DEPARTMENT'),
('PROC_MANAGER', 'Procurement Manager', 'PROC', 2, 500000, '{FINANCE}', 'DEPARTMENT'),
('PROC_DIRECTOR', 'Procurement Director', 'PROC', 3, 999999999, '{FINANCE,LEGAL}', 'COUNTRY'),

-- Finance Department Roles
('FIN_ANALYST', 'Finance Analyst', 'FIN', 1, 75000, '{FINANCE}', 'DEPARTMENT'),
('FIN_MANAGER', 'Finance Manager', 'FIN', 2, 300000, '{FINANCE}', 'COUNTRY'),
('CFO', 'Chief Financial Officer', 'FIN', 5, 999999999, '{FINANCE,LEGAL}', 'GLOBAL'),

-- Functional Roles (Cross-Department)
('SAFETY_OFFICER', 'Safety Officer', NULL, 2, 999999999, '{SAFETY}', 'COUNTRY'),
('LEGAL_COUNSEL', 'Legal Counsel', NULL, 3, 999999999, '{LEGAL}', 'GLOBAL'),
('QUALITY_MANAGER', 'Quality Manager', NULL, 2, 999999999, '{QUALITY}', 'COUNTRY');

-- Create user approval role assignments (dynamic)
CREATE TABLE IF NOT EXISTS user_approval_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    approval_role_id UUID REFERENCES approval_roles(id),
    company_code VARCHAR(10) DEFAULT 'C001',
    department_code VARCHAR(20),
    plant_code VARCHAR(10),
    effective_from DATE DEFAULT CURRENT_DATE,
    effective_to DATE DEFAULT '9999-12-31',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Function to add new approval role (completely dynamic)
CREATE OR REPLACE FUNCTION add_approval_role(
    p_role_code VARCHAR(50),
    p_role_name VARCHAR(100),
    p_department_code VARCHAR(20) DEFAULT NULL,
    p_authority_level INTEGER DEFAULT 1,
    p_approval_limit DECIMAL(15,2) DEFAULT 0,
    p_functional_domains TEXT[] DEFAULT '{}',
    p_organizational_scope VARCHAR(20) DEFAULT 'DEPARTMENT'
) RETURNS UUID AS $$
DECLARE
    v_role_id UUID;
BEGIN
    INSERT INTO approval_roles (
        role_code, role_name, department_code, approval_authority_level,
        approval_limit, functional_domains, organizational_scope
    ) VALUES (
        p_role_code, p_role_name, p_department_code, p_authority_level,
        p_approval_limit, p_functional_domains, p_organizational_scope
    ) RETURNING id INTO v_role_id;
    
    RETURN v_role_id;
END;
$$ LANGUAGE plpgsql;

-- Function to assign user to approval role (dynamic assignment)
CREATE OR REPLACE FUNCTION assign_user_approval_role(
    p_user_id UUID,
    p_role_code VARCHAR(50),
    p_company_code VARCHAR(10) DEFAULT 'C001',
    p_department_code VARCHAR(20) DEFAULT NULL,
    p_plant_code VARCHAR(10) DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_role_id UUID;
BEGIN
    -- Get role ID
    SELECT id INTO v_role_id FROM approval_roles WHERE role_code = p_role_code AND is_active = true;
    
    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Approval role % not found', p_role_code;
    END IF;
    
    -- Assign role to user
    INSERT INTO user_approval_roles (
        user_id, approval_role_id, company_code, department_code, plant_code
    ) VALUES (
        p_user_id, v_role_id, p_company_code, p_department_code, p_plant_code
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- View for active user approval roles
CREATE OR REPLACE VIEW v_user_approval_roles AS
SELECT 
    uar.user_id,
    ar.role_code,
    ar.role_name,
    ar.department_code,
    ar.approval_authority_level,
    ar.approval_limit,
    ar.functional_domains,
    ar.organizational_scope,
    uar.company_code,
    uar.plant_code
FROM user_approval_roles uar
JOIN approval_roles ar ON uar.approval_role_id = ar.id
WHERE uar.is_active = true 
  AND ar.is_active = true
  AND CURRENT_DATE BETWEEN uar.effective_from AND uar.effective_to;

SELECT 'DYNAMIC APPROVAL ROLES CONFIGURED - NO HARDCODING' as status;
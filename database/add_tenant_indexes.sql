-- =====================================================
-- MULTI-TENANT PERFORMANCE INDEXES
-- =====================================================
-- Purpose: Add indexes for tenant-scoped queries
-- Critical for multi-tenant query performance

-- =====================================================
-- CORE TENANT TABLES
-- =====================================================

-- Users table - most critical for auth flow
CREATE INDEX IF NOT EXISTS idx_users_email_tenant ON users(email, tenant_id);
CREATE INDEX IF NOT EXISTS idx_users_tenant ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role_id);

-- Roles table
CREATE INDEX IF NOT EXISTS idx_roles_tenant ON roles(tenant_id);

-- Authorization objects
CREATE INDEX IF NOT EXISTS idx_auth_objects_tenant ON authorization_objects(tenant_id);
CREATE INDEX IF NOT EXISTS idx_auth_objects_name_tenant ON authorization_objects(object_name, tenant_id);
CREATE INDEX IF NOT EXISTS idx_auth_objects_module_tenant ON authorization_objects(module, tenant_id);

-- Role authorization mappings
CREATE INDEX IF NOT EXISTS idx_role_auth_tenant ON role_authorization_objects(tenant_id);
CREATE INDEX IF NOT EXISTS idx_role_auth_role ON role_authorization_objects(role_id);
CREATE INDEX IF NOT EXISTS idx_role_auth_object ON role_authorization_objects(auth_object_id);

-- =====================================================
-- DOCUMENT GOVERNANCE TABLES
-- =====================================================

-- Drawings
CREATE INDEX IF NOT EXISTS idx_drawings_tenant ON drawings(tenant_id);
CREATE INDEX IF NOT EXISTS idx_drawings_status ON drawings(status);

-- Contracts
CREATE INDEX IF NOT EXISTS idx_contracts_tenant ON contracts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts(status);

-- RFIs
CREATE INDEX IF NOT EXISTS idx_rfis_tenant ON rfis(tenant_id);
CREATE INDEX IF NOT EXISTS idx_rfis_status ON rfis(status);

-- Specifications
CREATE INDEX IF NOT EXISTS idx_specifications_tenant ON specifications(tenant_id);

-- Submittals
CREATE INDEX IF NOT EXISTS idx_submittals_tenant ON submittals(tenant_id);
CREATE INDEX IF NOT EXISTS idx_submittals_status ON submittals(status);

-- Change Orders
CREATE INDEX IF NOT EXISTS idx_change_orders_tenant ON change_orders(tenant_id);
CREATE INDEX IF NOT EXISTS idx_change_orders_status ON change_orders(status);

-- Master Data Documents
CREATE INDEX IF NOT EXISTS idx_master_docs_tenant ON master_data_documents(tenant_id);
CREATE INDEX IF NOT EXISTS idx_master_docs_type ON master_data_documents(document_type);

-- Contract Amendments
CREATE INDEX IF NOT EXISTS idx_contract_amendments_tenant ON contract_amendments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_contract_amendments_contract ON contract_amendments(contract_id);

-- RFI Responses
CREATE INDEX IF NOT EXISTS idx_rfi_responses_tenant ON rfi_responses(tenant_id);
CREATE INDEX IF NOT EXISTS idx_rfi_responses_rfi ON rfi_responses(rfi_id);

-- =====================================================
-- CORE BUSINESS TABLES (High Priority)
-- =====================================================

-- Projects
CREATE INDEX IF NOT EXISTS idx_projects_tenant ON projects(tenant_id);

-- Materials
CREATE INDEX IF NOT EXISTS idx_materials_tenant ON materials(tenant_id);

-- Material Categories
CREATE INDEX IF NOT EXISTS idx_material_categories_tenant ON material_categories(tenant_id);

-- Material Requests
CREATE INDEX IF NOT EXISTS idx_material_requests_tenant ON material_requests(tenant_id);
CREATE INDEX IF NOT EXISTS idx_material_requests_status ON material_requests(status);

-- Material Request Items
CREATE INDEX IF NOT EXISTS idx_material_request_items_tenant ON material_request_items(tenant_id);

-- Employees
CREATE INDEX IF NOT EXISTS idx_employees_tenant ON employees(tenant_id);

-- Departments
CREATE INDEX IF NOT EXISTS idx_departments_tenant ON departments(tenant_id);

-- Cost Centers
CREATE INDEX IF NOT EXISTS idx_cost_centers_tenant ON cost_centers(tenant_id);

-- GL Accounts
CREATE INDEX IF NOT EXISTS idx_gl_accounts_tenant ON gl_accounts(tenant_id);

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Check indexes created
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE 'idx_%_tenant%'
ORDER BY tablename, indexname;

-- Count indexes per table
SELECT 
    tablename,
    COUNT(*) as index_count
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE 'idx_%'
GROUP BY tablename
ORDER BY index_count DESC, tablename;

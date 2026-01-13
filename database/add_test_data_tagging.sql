-- Add test_run_id column to all major tables for test data isolation
-- This enables safe cleanup and prevents test data pollution

-- Projects table
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS test_run_id UUID;

-- Universal Journal (Financial postings)
ALTER TABLE universal_journal 
ADD COLUMN IF NOT EXISTS test_run_id UUID;

-- WBS Elements
ALTER TABLE wbs_elements 
ADD COLUMN IF NOT EXISTS test_run_id UUID;

-- Materials
ALTER TABLE materials 
ADD COLUMN IF NOT EXISTS test_run_id UUID;

-- Purchase Orders
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS test_run_id UUID;

-- Create test users table
CREATE TABLE IF NOT EXISTS test_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    test_run_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create system config table for environment detection
CREATE TABLE IF NOT EXISTS system_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    environment VARCHAR(10) NOT NULL CHECK (environment IN ('DEV', 'TEST', 'PROD')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert current environment marker
INSERT INTO system_config (environment) 
VALUES ('DEV') 
ON CONFLICT DO NOTHING;

-- Create indexes for test data cleanup
CREATE INDEX IF NOT EXISTS idx_projects_test_run_id ON projects(test_run_id);
CREATE INDEX IF NOT EXISTS idx_universal_journal_test_run_id ON universal_journal(test_run_id);
CREATE INDEX IF NOT EXISTS idx_wbs_elements_test_run_id ON wbs_elements(test_run_id);
CREATE INDEX IF NOT EXISTS idx_materials_test_run_id ON materials(test_run_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_test_run_id ON purchase_orders(test_run_id);
CREATE INDEX IF NOT EXISTS idx_test_users_test_run_id ON test_users(test_run_id);
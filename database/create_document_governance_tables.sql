-- =====================================================
-- DOCUMENT GOVERNANCE DATABASE TABLES
-- =====================================================

-- 1. DRAWINGS TABLE
CREATE TABLE IF NOT EXISTS public.drawings (
  drawing_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  drawing_number VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  revision VARCHAR(20) DEFAULT 'Rev 0',
  discipline VARCHAR(50),
  project_id UUID,
  status VARCHAR(50) DEFAULT 'Draft',
  file_url TEXT,
  file_size BIGINT,
  created_by UUID,
  modified_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT drawings_pkey PRIMARY KEY (drawing_id),
  CONSTRAINT drawings_unique UNIQUE (tenant_id, drawing_number, revision)
);

CREATE INDEX IF NOT EXISTS idx_drawings_tenant ON drawings(tenant_id);
CREATE INDEX IF NOT EXISTS idx_drawings_project ON drawings(project_id);
CREATE INDEX IF NOT EXISTS idx_drawings_status ON drawings(status);

-- 2. CONTRACTS TABLE
CREATE TABLE IF NOT EXISTS public.contracts (
  contract_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  contract_number VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  vendor_id UUID,
  vendor_name VARCHAR(200),
  contract_value DECIMAL(15,2),
  currency VARCHAR(10) DEFAULT 'USD',
  start_date DATE,
  end_date DATE,
  status VARCHAR(50) DEFAULT 'Draft',
  project_id UUID,
  file_url TEXT,
  created_by UUID,
  modified_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT contracts_pkey PRIMARY KEY (contract_id),
  CONSTRAINT contracts_unique UNIQUE (tenant_id, contract_number)
);

CREATE INDEX IF NOT EXISTS idx_contracts_tenant ON contracts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_contracts_vendor ON contracts(vendor_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts(status);

-- 3. CONTRACT AMENDMENTS TABLE
CREATE TABLE IF NOT EXISTS public.contract_amendments (
  amendment_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  contract_id UUID NOT NULL,
  amendment_number VARCHAR(50) NOT NULL,
  description TEXT,
  value_change DECIMAL(15,2),
  new_end_date DATE,
  status VARCHAR(50) DEFAULT 'Pending',
  file_url TEXT,
  created_by UUID,
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT contract_amendments_pkey PRIMARY KEY (amendment_id)
);

CREATE INDEX IF NOT EXISTS idx_amendments_contract ON contract_amendments(contract_id);

-- 4. RFIS TABLE
CREATE TABLE IF NOT EXISTS public.rfis (
  rfi_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  rfi_number VARCHAR(50) NOT NULL,
  subject VARCHAR(200) NOT NULL,
  description TEXT,
  discipline VARCHAR(50),
  project_id UUID,
  priority VARCHAR(20) DEFAULT 'Medium',
  status VARCHAR(50) DEFAULT 'Open',
  due_date DATE,
  created_by UUID,
  assigned_to UUID,
  closed_by UUID,
  closed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT rfis_pkey PRIMARY KEY (rfi_id),
  CONSTRAINT rfis_unique UNIQUE (tenant_id, rfi_number)
);

CREATE INDEX IF NOT EXISTS idx_rfis_tenant ON rfis(tenant_id);
CREATE INDEX IF NOT EXISTS idx_rfis_project ON rfis(project_id);
CREATE INDEX IF NOT EXISTS idx_rfis_status ON rfis(status);

-- 5. RFI RESPONSES TABLE
CREATE TABLE IF NOT EXISTS public.rfi_responses (
  response_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  rfi_id UUID NOT NULL,
  response_text TEXT NOT NULL,
  responded_by UUID,
  responded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT rfi_responses_pkey PRIMARY KEY (response_id)
);

CREATE INDEX IF NOT EXISTS idx_rfi_responses_rfi ON rfi_responses(rfi_id);

-- 6. SPECIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.specifications (
  spec_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  spec_number VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  discipline VARCHAR(50),
  project_id UUID,
  status VARCHAR(50) DEFAULT 'Draft',
  version VARCHAR(20) DEFAULT 'v1.0',
  file_url TEXT,
  created_by UUID,
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT specifications_pkey PRIMARY KEY (spec_id),
  CONSTRAINT specifications_unique UNIQUE (tenant_id, spec_number, version)
);

CREATE INDEX IF NOT EXISTS idx_specs_tenant ON specifications(tenant_id);
CREATE INDEX IF NOT EXISTS idx_specs_project ON specifications(project_id);
CREATE INDEX IF NOT EXISTS idx_specs_status ON specifications(status);

-- 7. SUBMITTALS TABLE
CREATE TABLE IF NOT EXISTS public.submittals (
  submittal_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  submittal_number VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  vendor_id UUID,
  vendor_name VARCHAR(200),
  project_id UUID,
  spec_section VARCHAR(50),
  status VARCHAR(50) DEFAULT 'Submitted',
  review_status VARCHAR(50) DEFAULT 'Pending',
  submitted_date DATE,
  required_date DATE,
  file_url TEXT,
  created_by UUID,
  reviewed_by UUID,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT submittals_pkey PRIMARY KEY (submittal_id),
  CONSTRAINT submittals_unique UNIQUE (tenant_id, submittal_number)
);

CREATE INDEX IF NOT EXISTS idx_submittals_tenant ON submittals(tenant_id);
CREATE INDEX IF NOT EXISTS idx_submittals_vendor ON submittals(vendor_id);
CREATE INDEX IF NOT EXISTS idx_submittals_status ON submittals(status);

-- 8. CHANGE ORDERS TABLE
CREATE TABLE IF NOT EXISTS public.change_orders (
  change_order_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  change_order_number VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  project_id UUID,
  contract_id UUID,
  cost_impact DECIMAL(15,2),
  schedule_impact_days INTEGER,
  status VARCHAR(50) DEFAULT 'Pending',
  priority VARCHAR(20) DEFAULT 'Medium',
  justification TEXT,
  created_by UUID,
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT change_orders_pkey PRIMARY KEY (change_order_id),
  CONSTRAINT change_orders_unique UNIQUE (tenant_id, change_order_number)
);

CREATE INDEX IF NOT EXISTS idx_change_orders_tenant ON change_orders(tenant_id);
CREATE INDEX IF NOT EXISTS idx_change_orders_project ON change_orders(project_id);
CREATE INDEX IF NOT EXISTS idx_change_orders_status ON change_orders(status);

-- 9. MASTER DATA DOCUMENTS TABLE
CREATE TABLE IF NOT EXISTS public.master_data_documents (
  document_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  document_number VARCHAR(50) NOT NULL,
  document_type VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  category VARCHAR(50),
  status VARCHAR(50) DEFAULT 'Draft',
  version VARCHAR(20) DEFAULT 'v1.0',
  file_url TEXT,
  created_by UUID,
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT master_data_documents_pkey PRIMARY KEY (document_id),
  CONSTRAINT master_data_documents_unique UNIQUE (tenant_id, document_number, version)
);

CREATE INDEX IF NOT EXISTS idx_master_docs_tenant ON master_data_documents(tenant_id);
CREATE INDEX IF NOT EXISTS idx_master_docs_type ON master_data_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_master_docs_status ON master_data_documents(status);

-- CREATE UPDATE TRIGGERS
DO $$ BEGIN
  CREATE TRIGGER update_drawings_updated_at BEFORE UPDATE ON drawings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TRIGGER update_contracts_updated_at BEFORE UPDATE ON contracts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TRIGGER update_contract_amendments_updated_at BEFORE UPDATE ON contract_amendments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TRIGGER update_rfis_updated_at BEFORE UPDATE ON rfis FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TRIGGER update_specifications_updated_at BEFORE UPDATE ON specifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TRIGGER update_submittals_updated_at BEFORE UPDATE ON submittals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TRIGGER update_change_orders_updated_at BEFORE UPDATE ON change_orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TRIGGER update_master_data_documents_updated_at BEFORE UPDATE ON master_data_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- VERIFICATION
SELECT 'Tables Created' AS status, COUNT(*) AS count
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('drawings', 'contracts', 'contract_amendments', 'rfis', 'rfi_responses', 
                     'specifications', 'submittals', 'change_orders', 'master_data_documents');

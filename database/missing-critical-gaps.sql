-- MISSING CRITICAL GAPS - FINAL COMPLIANCE
-- Addresses the remaining 3 gaps from ChatGPT's "MUST-HAVE" list

-- ========================================
-- MISSING 1: DOCUMENT TYPE MASTER (SAP BKPF-BLART)
-- ========================================

CREATE TABLE document_type_master (
  document_type VARCHAR(2) PRIMARY KEY,
  description VARCHAR(50) NOT NULL,
  number_range VARCHAR(10) NOT NULL,
  account_type VARCHAR(1) NOT NULL, -- K=Vendor, D=Customer, S=GL
  reverse_allowed BOOLEAN DEFAULT true
);

INSERT INTO document_type_master VALUES
('RE', 'Vendor Invoice', 'RE', 'K', true),
('KR', 'Vendor Credit Memo', 'KR', 'K', true),
('DR', 'Customer Invoice', 'DR', 'D', true),
('DG', 'Customer Credit Memo', 'DG', 'D', true),
('SA', 'GL Document', 'SA', 'S', true),
('WE', 'Goods Receipt', 'WE', 'S', false);

-- ========================================
-- MISSING 2: REVERSAL REASONS (FI CONTROL)
-- ========================================

CREATE TABLE reversal_reasons (
  reason_code VARCHAR(2) PRIMARY KEY,
  description VARCHAR(50) NOT NULL,
  negative_posting BOOLEAN DEFAULT false,
  reversal_posting BOOLEAN DEFAULT true
);

INSERT INTO reversal_reasons VALUES
('01', 'Reversal in current period', false, true),
('02', 'Reversal in previous period', true, false),
('03', 'Correction posting', false, true);

-- ========================================
-- MISSING 3: PERIOD CONTROLS (POSTING LOCK)
-- ========================================

CREATE TABLE period_controls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_code VARCHAR(10) NOT NULL,
  fiscal_year VARCHAR(4) NOT NULL,
  period VARCHAR(2) NOT NULL,
  account_type VARCHAR(1) NOT NULL, -- S=GL, K=Vendor, D=Customer
  from_account VARCHAR(20),
  to_account VARCHAR(20),
  posting_allowed BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(company_code, fiscal_year, period, account_type)
);

INSERT INTO period_controls VALUES
(gen_random_uuid(), 'C001', '2024', '01', 'S', NULL, NULL, true),
(gen_random_uuid(), 'C001', '2024', '02', 'S', NULL, NULL, true),
(gen_random_uuid(), 'C001', '2024', '03', 'S', NULL, NULL, false); -- Closed period

SELECT 'FINAL COMPLIANCE GAPS CLOSED' as status;
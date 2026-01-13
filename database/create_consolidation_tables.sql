-- Phase 3: Multi-Company Consolidation Schema
-- Create tables for cross-company reporting and currency consolidation

-- 1. Reporting Currencies for consolidation
CREATE TABLE IF NOT EXISTS reporting_currencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporting_currency VARCHAR(3) NOT NULL REFERENCES currencies(currency_code),
  description VARCHAR(100) NOT NULL,
  is_default BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Company Consolidation Groups
CREATE TABLE IF NOT EXISTS consolidation_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_code VARCHAR(31) UNIQUE NOT NULL,
  group_name VARCHAR(240) NOT NULL,
  parent_company_code VARCHAR(31) NOT NULL REFERENCES company_codes(company_code),
  reporting_currency VARCHAR(3) NOT NULL REFERENCES currencies(currency_code),
  consolidation_method VARCHAR(20) DEFAULT 'FULL', -- FULL, PROPORTIONAL, EQUITY
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Company Group Assignments
CREATE TABLE IF NOT EXISTS company_group_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES consolidation_groups(id),
  company_code VARCHAR(31) NOT NULL REFERENCES company_codes(company_code),
  ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
  consolidation_method VARCHAR(20) DEFAULT 'FULL',
  effective_from DATE NOT NULL,
  effective_to DATE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(group_id, company_code, effective_from)
);

-- 4. Consolidated Stock View
CREATE OR REPLACE VIEW consolidated_stock_overview AS
SELECT 
  cga.group_id,
  cg.group_code,
  cg.group_name,
  cg.reporting_currency,
  sb.stock_items,
  sb.storage_locations,
  sb.current_quantity,
  sb.total_value as company_currency_value,
  cc.currency as company_currency,
  -- Convert to reporting currency (simplified - would use current rates)
  CASE 
    WHEN cc.currency = cg.reporting_currency THEN sb.total_value
    ELSE sb.total_value * 1.0 -- Placeholder for exchange rate conversion
  END as reporting_currency_value,
  cga.ownership_percentage,
  -- Apply ownership percentage for consolidation
  CASE 
    WHEN cga.consolidation_method = 'PROPORTIONAL' 
    THEN (sb.total_value * cga.ownership_percentage / 100.0)
    ELSE sb.total_value
  END as consolidated_value
FROM stock_balances sb
JOIN storage_locations sl ON sb.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
JOIN company_codes cc ON p.company_code_id = cc.id
JOIN company_group_assignments cga ON cc.company_code = cga.company_code
JOIN consolidation_groups cg ON cga.group_id = cg.id
WHERE cga.is_active = true 
  AND cg.is_active = true
  AND (cga.effective_to IS NULL OR cga.effective_to >= CURRENT_DATE)
  AND cga.effective_from <= CURRENT_DATE;

-- 5. Insert sample consolidation data
INSERT INTO reporting_currencies (reporting_currency, description, is_default) VALUES
('USD', 'US Dollar Reporting', true),
('EUR', 'Euro Reporting', false),
('GBP', 'British Pound Reporting', false)
ON CONFLICT DO NOTHING;

INSERT INTO consolidation_groups (group_code, group_name, parent_company_code, reporting_currency) VALUES
('GLOBAL', 'Global Construction Group', 'N001', 'USD'),
('EUROPE', 'European Operations', 'N001', 'EUR'),
('AMERICAS', 'Americas Operations', 'N001', 'USD')
ON CONFLICT (group_code) DO NOTHING;

-- 6. Sample company assignments
INSERT INTO company_group_assignments (group_id, company_code, ownership_percentage, effective_from) 
SELECT 
  cg.id,
  cc.company_code,
  100.00,
  CURRENT_DATE
FROM consolidation_groups cg
CROSS JOIN company_codes cc
WHERE cg.group_code = 'GLOBAL'
  AND cc.is_active = true
ON CONFLICT (group_id, company_code, effective_from) DO NOTHING;

-- 7. Create indexes
CREATE INDEX IF NOT EXISTS idx_consolidation_groups_parent ON consolidation_groups(parent_company_code);
CREATE INDEX IF NOT EXISTS idx_company_group_assignments_group ON company_group_assignments(group_id);
CREATE INDEX IF NOT EXISTS idx_company_group_assignments_company ON company_group_assignments(company_code);
CREATE INDEX IF NOT EXISTS idx_company_group_assignments_dates ON company_group_assignments(effective_from, effective_to);
-- Create fiscal year variants table for SAP controlling areas
-- Run this script in Supabase SQL Editor

-- 1. Create fiscal_year_variants table
CREATE TABLE IF NOT EXISTS fiscal_year_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  variant_code VARCHAR(2) UNIQUE NOT NULL,
  variant_name VARCHAR(100) NOT NULL,
  description TEXT,
  start_month INTEGER NOT NULL, -- 1-12
  start_day INTEGER NOT NULL,   -- 1-31
  periods INTEGER DEFAULT 12,   -- Number of periods (usually 12)
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Insert standard SAP fiscal year variants
INSERT INTO fiscal_year_variants (variant_code, variant_name, description, start_month, start_day, periods) VALUES
-- Calendar Year Variants
('K4', 'Calendar Year', 'January to December (Standard)', 1, 1, 12),
('K1', 'Calendar Year - Short', 'January to December with 4 special periods', 1, 1, 16),

-- April Start Variants  
('V3', 'April to March', 'April to March fiscal year', 4, 1, 12),
('V1', 'April to March - Extended', 'April to March with special periods', 4, 1, 16),

-- July Start Variants
('V6', 'July to June', 'July to June fiscal year', 7, 1, 12),
('V4', 'July to June - Extended', 'July to June with special periods', 7, 1, 16),

-- October Start Variants
('V9', 'October to September', 'October to September fiscal year', 10, 1, 12),
('V7', 'October to September - Extended', 'October to September with special periods', 10, 1, 16),

-- Other Common Variants
('V2', 'May to April', 'May to April fiscal year', 5, 1, 12),
('V5', 'August to July', 'August to July fiscal year', 8, 1, 12),
('V8', 'September to August', 'September to August fiscal year', 9, 1, 12),
('K2', 'Calendar Year - Weekly', 'Calendar year with weekly periods', 1, 1, 52),
('K3', 'Calendar Year - Quarterly', 'Calendar year with quarterly periods', 1, 1, 4),

-- Regional Variants
('GB', 'UK Fiscal Year', 'April to March (UK standard)', 4, 6, 12),
('US', 'US Federal Fiscal Year', 'October to September (US Government)', 10, 1, 12),
('IN', 'India Fiscal Year', 'April to March (India standard)', 4, 1, 12),
('AU', 'Australia Fiscal Year', 'July to June (Australia standard)', 7, 1, 12),
('CA', 'Canada Fiscal Year', 'April to March (Canada Government)', 4, 1, 12),
('JP', 'Japan Fiscal Year', 'April to March (Japan standard)', 4, 1, 12)

ON CONFLICT (variant_code) DO NOTHING;

-- 3. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_fiscal_variants_code ON fiscal_year_variants(variant_code);
CREATE INDEX IF NOT EXISTS idx_fiscal_variants_active ON fiscal_year_variants(is_active);
CREATE INDEX IF NOT EXISTS idx_fiscal_variants_start_month ON fiscal_year_variants(start_month);

-- 4. Verify data insertion
SELECT 'Fiscal Year Variants inserted:' as info, COUNT(*) as count FROM fiscal_year_variants;
SELECT 'Variants by start month:' as info, start_month, COUNT(*) as count 
FROM fiscal_year_variants 
GROUP BY start_month 
ORDER BY start_month;
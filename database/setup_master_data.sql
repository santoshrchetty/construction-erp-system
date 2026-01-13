-- Complete Master Data Setup Script
-- Run this script in Supabase SQL Editor to create all master data tables

-- 1. Create currencies table
CREATE TABLE IF NOT EXISTS currencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  currency_code VARCHAR(3) UNIQUE NOT NULL,
  currency_name VARCHAR(100) NOT NULL,
  currency_symbol VARCHAR(10),
  decimal_places INTEGER DEFAULT 2,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Create countries table
CREATE TABLE IF NOT EXISTS countries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code VARCHAR(2) UNIQUE NOT NULL,
  country_name VARCHAR(100) NOT NULL,
  country_code_3 VARCHAR(3),
  region VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. Create fiscal_year_variants table
CREATE TABLE IF NOT EXISTS fiscal_year_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  variant_code VARCHAR(2) UNIQUE NOT NULL,
  variant_name VARCHAR(100) NOT NULL,
  description TEXT,
  start_month INTEGER NOT NULL,
  start_day INTEGER NOT NULL,
  periods INTEGER DEFAULT 12,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. Insert currencies
INSERT INTO currencies (currency_code, currency_name, currency_symbol, decimal_places) VALUES
('USD', 'US Dollar', '$', 2),
('EUR', 'Euro', '€', 2),
('GBP', 'British Pound Sterling', '£', 2),
('JPY', 'Japanese Yen', '¥', 0),
('CAD', 'Canadian Dollar', 'C$', 2),
('AUD', 'Australian Dollar', 'A$', 2),
('CHF', 'Swiss Franc', 'CHF', 2),
('CNY', 'Chinese Yuan', '¥', 2),
('INR', 'Indian Rupee', '₹', 2),
('BRL', 'Brazilian Real', 'R$', 2)
ON CONFLICT (currency_code) DO NOTHING;

-- 5. Insert countries
INSERT INTO countries (country_code, country_name, country_code_3, region) VALUES
('US', 'United States', 'USA', 'Americas'),
('CA', 'Canada', 'CAN', 'Americas'),
('GB', 'United Kingdom', 'GBR', 'Europe'),
('DE', 'Germany', 'DEU', 'Europe'),
('FR', 'France', 'FRA', 'Europe'),
('JP', 'Japan', 'JPN', 'Asia-Pacific'),
('AU', 'Australia', 'AUS', 'Asia-Pacific'),
('IN', 'India', 'IND', 'Asia-Pacific'),
('BR', 'Brazil', 'BRA', 'Americas'),
('CN', 'China', 'CHN', 'Asia-Pacific')
ON CONFLICT (country_code) DO NOTHING;

-- 6. Insert fiscal year variants
INSERT INTO fiscal_year_variants (variant_code, variant_name, description, start_month, start_day, periods) VALUES
('K4', 'Calendar Year', 'January to December (Standard)', 1, 1, 12),
('V3', 'April to March', 'April to March fiscal year', 4, 1, 12),
('V6', 'July to June', 'July to June fiscal year', 7, 1, 12),
('V9', 'October to September', 'October to September fiscal year', 10, 1, 12),
('GB', 'UK Fiscal Year', 'April to March (UK standard)', 4, 6, 12),
('US', 'US Federal Fiscal Year', 'October to September (US Government)', 10, 1, 12),
('IN', 'India Fiscal Year', 'April to March (India standard)', 4, 1, 12),
('AU', 'Australia Fiscal Year', 'July to June (Australia standard)', 7, 1, 12),
('CA', 'Canada Fiscal Year', 'April to March (Canada Government)', 4, 1, 12),
('JP', 'Japan Fiscal Year', 'April to March (Japan standard)', 4, 1, 12)
ON CONFLICT (variant_code) DO NOTHING;

-- 7. Add country_code column to company_codes table if it doesn't exist
ALTER TABLE company_codes 
ADD COLUMN IF NOT EXISTS country_code VARCHAR(2) REFERENCES countries(country_code);

-- 8. Create indexes
CREATE INDEX IF NOT EXISTS idx_currencies_code ON currencies(currency_code);
CREATE INDEX IF NOT EXISTS idx_countries_code ON countries(country_code);
CREATE INDEX IF NOT EXISTS idx_fiscal_variants_code ON fiscal_year_variants(variant_code);

-- 9. Verify setup
SELECT 'Setup Complete!' as status;
SELECT 'Currencies:' as table_name, COUNT(*) as count FROM currencies
UNION ALL
SELECT 'Countries:', COUNT(*) FROM countries
UNION ALL
SELECT 'Fiscal Variants:', COUNT(*) FROM fiscal_year_variants;
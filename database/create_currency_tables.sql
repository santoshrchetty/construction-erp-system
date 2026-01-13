-- Phase 2: Purchase Currency Handling Schema
-- Create tables for exchange rates and multi-currency purchase processing

-- 1. Exchange Rates table for currency conversion
CREATE TABLE IF NOT EXISTS exchange_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_currency VARCHAR(3) NOT NULL REFERENCES currencies(currency_code),
  to_currency VARCHAR(3) NOT NULL REFERENCES currencies(currency_code),
  exchange_rate DECIMAL(15,6) NOT NULL,
  rate_date DATE NOT NULL,
  rate_type VARCHAR(20) DEFAULT 'DAILY', -- DAILY, MONTHLY, FIXED
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  created_by UUID,
  UNIQUE(from_currency, to_currency, rate_date, rate_type)
);

-- 2. Purchase Orders table with multi-currency support
CREATE TABLE IF NOT EXISTS purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_number VARCHAR(31) UNIQUE NOT NULL,
  vendor_code VARCHAR(31) NOT NULL,
  company_code VARCHAR(31) NOT NULL REFERENCES company_codes(company_code),
  plant_code VARCHAR(31),
  po_date DATE NOT NULL,
  -- Original currency fields
  document_currency VARCHAR(3) NOT NULL REFERENCES currencies(currency_code),
  total_amount DECIMAL(15,2) NOT NULL,
  -- Company currency fields (converted)
  company_currency VARCHAR(3) NOT NULL REFERENCES currencies(currency_code),
  company_amount DECIMAL(15,2) NOT NULL,
  exchange_rate DECIMAL(15,6) NOT NULL,
  rate_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'OPEN',
  created_at TIMESTAMP DEFAULT NOW(),
  created_by UUID
);

-- 3. Purchase Order Items with currency details
CREATE TABLE IF NOT EXISTS purchase_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_id UUID NOT NULL REFERENCES purchase_orders(id),
  line_number INTEGER NOT NULL,
  material_code VARCHAR(31) NOT NULL,
  quantity DECIMAL(15,3) NOT NULL,
  unit VARCHAR(10) NOT NULL,
  -- Original currency pricing
  unit_price DECIMAL(15,4) NOT NULL,
  line_amount DECIMAL(15,2) NOT NULL,
  -- Company currency pricing (converted)
  company_unit_price DECIMAL(15,4) NOT NULL,
  company_line_amount DECIMAL(15,2) NOT NULL,
  delivery_date DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(po_id, line_number)
);

-- 4. Material Receipts with currency conversion tracking
CREATE TABLE IF NOT EXISTS material_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  receipt_number VARCHAR(31) UNIQUE NOT NULL,
  po_id UUID NOT NULL REFERENCES purchase_orders(id),
  po_item_id UUID NOT NULL REFERENCES purchase_order_items(id),
  material_code VARCHAR(31) NOT NULL,
  plant_code VARCHAR(31) NOT NULL,
  storage_location VARCHAR(31) NOT NULL,
  receipt_date DATE NOT NULL,
  quantity_received DECIMAL(15,3) NOT NULL,
  -- Original currency values
  document_currency VARCHAR(3) NOT NULL,
  unit_cost DECIMAL(15,4) NOT NULL,
  total_value DECIMAL(15,2) NOT NULL,
  -- Company currency values (for stock valuation)
  company_currency VARCHAR(3) NOT NULL,
  company_unit_cost DECIMAL(15,4) NOT NULL,
  company_total_value DECIMAL(15,2) NOT NULL,
  exchange_rate DECIMAL(15,6) NOT NULL,
  rate_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  created_by UUID
);

-- 5. Insert sample exchange rates
INSERT INTO exchange_rates (from_currency, to_currency, exchange_rate, rate_date, rate_type) VALUES
-- USD base rates
('USD', 'EUR', 0.85, CURRENT_DATE, 'DAILY'),
('USD', 'GBP', 0.75, CURRENT_DATE, 'DAILY'),
('USD', 'JPY', 110.0, CURRENT_DATE, 'DAILY'),
('USD', 'CAD', 1.25, CURRENT_DATE, 'DAILY'),
-- Reverse rates
('EUR', 'USD', 1.18, CURRENT_DATE, 'DAILY'),
('GBP', 'USD', 1.33, CURRENT_DATE, 'DAILY'),
('JPY', 'USD', 0.009, CURRENT_DATE, 'DAILY'),
('CAD', 'USD', 0.80, CURRENT_DATE, 'DAILY')
ON CONFLICT (from_currency, to_currency, rate_date, rate_type) DO NOTHING;

-- 6. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_exchange_rates_currencies ON exchange_rates(from_currency, to_currency);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_date ON exchange_rates(rate_date);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_company ON purchase_orders(company_code);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_date ON purchase_orders(po_date);
CREATE INDEX IF NOT EXISTS idx_material_receipts_date ON material_receipts(receipt_date);
CREATE INDEX IF NOT EXISTS idx_material_receipts_material ON material_receipts(material_code);
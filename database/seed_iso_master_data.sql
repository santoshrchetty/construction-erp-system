-- Add ISO standard currencies and countries to respective tables
-- Run this script in Supabase SQL Editor

-- 1. Create currencies table if not exists
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

-- 2. Create countries table if not exists
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

-- 3. Insert ISO 4217 currencies (major world currencies)
INSERT INTO currencies (currency_code, currency_name, currency_symbol, decimal_places) VALUES
-- Major Reserve Currencies
('USD', 'US Dollar', '$', 2),
('EUR', 'Euro', '€', 2),
('JPY', 'Japanese Yen', '¥', 0),
('GBP', 'British Pound Sterling', '£', 2),
('CHF', 'Swiss Franc', 'CHF', 2),
-- Americas
('CAD', 'Canadian Dollar', 'C$', 2),
('BRL', 'Brazilian Real', 'R$', 2),
('MXN', 'Mexican Peso', '$', 2),
('ARS', 'Argentine Peso', '$', 2),
('CLP', 'Chilean Peso', '$', 0),
('COP', 'Colombian Peso', '$', 2),
('PEN', 'Peruvian Sol', 'S/', 2),
('UYU', 'Uruguayan Peso', '$U', 2),
-- Europe
('NOK', 'Norwegian Krone', 'kr', 2),
('SEK', 'Swedish Krona', 'kr', 2),
('DKK', 'Danish Krone', 'kr', 2),
('PLN', 'Polish Zloty', 'zł', 2),
('CZK', 'Czech Koruna', 'Kč', 2),
('HUF', 'Hungarian Forint', 'Ft', 2),
('RUB', 'Russian Ruble', '₽', 2),
('TRY', 'Turkish Lira', '₺', 2),
-- Asia-Pacific
('CNY', 'Chinese Yuan Renminbi', '¥', 2),
('INR', 'Indian Rupee', '₹', 2),
('KRW', 'South Korean Won', '₩', 0),
('SGD', 'Singapore Dollar', 'S$', 2),
('HKD', 'Hong Kong Dollar', 'HK$', 2),
('AUD', 'Australian Dollar', 'A$', 2),
('NZD', 'New Zealand Dollar', 'NZ$', 2),
('THB', 'Thai Baht', '฿', 2),
('MYR', 'Malaysian Ringgit', 'RM', 2),
('IDR', 'Indonesian Rupiah', 'Rp', 2),
('PHP', 'Philippine Peso', '₱', 2),
('VND', 'Vietnamese Dong', '₫', 0),
-- Middle East & Africa
('SAR', 'Saudi Riyal', 'SR', 2),
('AED', 'UAE Dirham', 'د.إ', 2),
('QAR', 'Qatari Riyal', 'QR', 2),
('KWD', 'Kuwaiti Dinar', 'KD', 3),
('BHD', 'Bahraini Dinar', 'BD', 3),
('OMR', 'Omani Rial', 'OMR', 3),
('JOD', 'Jordanian Dinar', 'JD', 3),
('LBP', 'Lebanese Pound', 'L£', 2),
('ILS', 'Israeli New Shekel', '₪', 2),
('EGP', 'Egyptian Pound', 'E£', 2),
('ZAR', 'South African Rand', 'R', 2)
ON CONFLICT (currency_code) DO NOTHING;

-- 4. Insert ISO 3166 countries (major countries by region)
INSERT INTO countries (country_code, country_name, country_code_3, region) VALUES
-- Americas
('US', 'United States', 'USA', 'Americas'),
('CA', 'Canada', 'CAN', 'Americas'),
('MX', 'Mexico', 'MEX', 'Americas'),
('BR', 'Brazil', 'BRA', 'Americas'),
('AR', 'Argentina', 'ARG', 'Americas'),
('CL', 'Chile', 'CHL', 'Americas'),
('CO', 'Colombia', 'COL', 'Americas'),
('PE', 'Peru', 'PER', 'Americas'),
('UY', 'Uruguay', 'URY', 'Americas'),
('VE', 'Venezuela', 'VEN', 'Americas'),
('EC', 'Ecuador', 'ECU', 'Americas'),
('BO', 'Bolivia', 'BOL', 'Americas'),
('PY', 'Paraguay', 'PRY', 'Americas'),
-- Europe
('GB', 'United Kingdom', 'GBR', 'Europe'),
('DE', 'Germany', 'DEU', 'Europe'),
('FR', 'France', 'FRA', 'Europe'),
('IT', 'Italy', 'ITA', 'Europe'),
('ES', 'Spain', 'ESP', 'Europe'),
('NL', 'Netherlands', 'NLD', 'Europe'),
('BE', 'Belgium', 'BEL', 'Europe'),
('CH', 'Switzerland', 'CHE', 'Europe'),
('AT', 'Austria', 'AUT', 'Europe'),
('NO', 'Norway', 'NOR', 'Europe'),
('SE', 'Sweden', 'SWE', 'Europe'),
('DK', 'Denmark', 'DNK', 'Europe'),
('FI', 'Finland', 'FIN', 'Europe'),
('IE', 'Ireland', 'IRL', 'Europe'),
('PT', 'Portugal', 'PRT', 'Europe'),
('PL', 'Poland', 'POL', 'Europe'),
('CZ', 'Czech Republic', 'CZE', 'Europe'),
('HU', 'Hungary', 'HUN', 'Europe'),
('SK', 'Slovakia', 'SVK', 'Europe'),
('SI', 'Slovenia', 'SVN', 'Europe'),
('HR', 'Croatia', 'HRV', 'Europe'),
('RO', 'Romania', 'ROU', 'Europe'),
('BG', 'Bulgaria', 'BGR', 'Europe'),
('GR', 'Greece', 'GRC', 'Europe'),
('RU', 'Russia', 'RUS', 'Europe'),
('TR', 'Turkey', 'TUR', 'Europe'),
-- Asia-Pacific
('CN', 'China', 'CHN', 'Asia-Pacific'),
('JP', 'Japan', 'JPN', 'Asia-Pacific'),
('IN', 'India', 'IND', 'Asia-Pacific'),
('KR', 'South Korea', 'KOR', 'Asia-Pacific'),
('SG', 'Singapore', 'SGP', 'Asia-Pacific'),
('HK', 'Hong Kong', 'HKG', 'Asia-Pacific'),
('TW', 'Taiwan', 'TWN', 'Asia-Pacific'),
('TH', 'Thailand', 'THA', 'Asia-Pacific'),
('MY', 'Malaysia', 'MYS', 'Asia-Pacific'),
('ID', 'Indonesia', 'IDN', 'Asia-Pacific'),
('PH', 'Philippines', 'PHL', 'Asia-Pacific'),
('VN', 'Vietnam', 'VNM', 'Asia-Pacific'),
('AU', 'Australia', 'AUS', 'Asia-Pacific'),
('NZ', 'New Zealand', 'NZL', 'Asia-Pacific'),
('BD', 'Bangladesh', 'BGD', 'Asia-Pacific'),
('PK', 'Pakistan', 'PAK', 'Asia-Pacific'),
('LK', 'Sri Lanka', 'LKA', 'Asia-Pacific'),
-- Middle East & Africa
('SA', 'Saudi Arabia', 'SAU', 'Middle East & Africa'),
('AE', 'United Arab Emirates', 'ARE', 'Middle East & Africa'),
('QA', 'Qatar', 'QAT', 'Middle East & Africa'),
('KW', 'Kuwait', 'KWT', 'Middle East & Africa'),
('BH', 'Bahrain', 'BHR', 'Middle East & Africa'),
('OM', 'Oman', 'OMN', 'Middle East & Africa'),
('JO', 'Jordan', 'JOR', 'Middle East & Africa'),
('LB', 'Lebanon', 'LBN', 'Middle East & Africa'),
('IL', 'Israel', 'ISR', 'Middle East & Africa'),
('EG', 'Egypt', 'EGY', 'Middle East & Africa'),
('ZA', 'South Africa', 'ZAF', 'Middle East & Africa'),
('NG', 'Nigeria', 'NGA', 'Middle East & Africa'),
('KE', 'Kenya', 'KEN', 'Middle East & Africa'),
('MA', 'Morocco', 'MAR', 'Middle East & Africa'),
('TN', 'Tunisia', 'TUN', 'Middle East & Africa'),
('GH', 'Ghana', 'GHA', 'Middle East & Africa'),
('ET', 'Ethiopia', 'ETH', 'Middle East & Africa')
ON CONFLICT (country_code) DO NOTHING;

-- 5. Add country_code column to company_codes table
ALTER TABLE company_codes 
ADD COLUMN IF NOT EXISTS country_code VARCHAR(2) REFERENCES countries(country_code);

-- 6. Update existing company codes with default country (US)
UPDATE company_codes SET country_code = 'US' WHERE country_code IS NULL;

-- 7. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_currencies_code ON currencies(currency_code);
CREATE INDEX IF NOT EXISTS idx_currencies_active ON currencies(is_active);
CREATE INDEX IF NOT EXISTS idx_countries_code ON countries(country_code);
CREATE INDEX IF NOT EXISTS idx_countries_region ON countries(region);
CREATE INDEX IF NOT EXISTS idx_countries_active ON countries(is_active);

-- 8. Verify data insertion
SELECT 'Currencies inserted:' as info, COUNT(*) as count FROM currencies;
SELECT 'Countries inserted:' as info, COUNT(*) as count FROM countries;
SELECT 'Countries by region:' as info, region, COUNT(*) as count FROM countries GROUP BY region ORDER BY region;
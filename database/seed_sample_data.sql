-- Add sample purchasing organizations
INSERT INTO purchasing_organizations (porg_code, porg_name, currency, is_active) VALUES
('P001', 'Main Purchasing Organization', 'USD', true),
('P002', 'Regional Purchasing East', 'USD', true),
('P003', 'International Purchasing', 'EUR', true);

-- Add sample company codes
INSERT INTO company_codes (company_code, company_name, legal_entity_name, currency, is_active) VALUES
('C001', 'Main Company', 'Main Company LLC', 'USD', true),
('C002', 'Regional Office', 'Regional Office Inc', 'USD', true);
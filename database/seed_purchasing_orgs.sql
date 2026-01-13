-- Seed purchasing organizations with sample data
INSERT INTO purchasing_organizations (porg_code, porg_name, currency, is_active) VALUES
('MAIN-PURCH', 'Main Purchasing Organization', 'USD', true),
('REGIONAL-EAST', 'Regional East Purchasing', 'USD', true),
('REGIONAL-WEST', 'Regional West Purchasing', 'USD', true),
('INTL-PURCH', 'International Purchasing', 'EUR', true),
('PROJECT-PURCH', 'Project-Specific Purchasing', 'USD', true);
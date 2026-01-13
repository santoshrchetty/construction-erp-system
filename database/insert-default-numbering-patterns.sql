-- Check if project_numbering_rules table exists and has data
SELECT * FROM project_numbering_rules WHERE company_code = 'C001' LIMIT 10;

-- Insert default numbering patterns for C001
INSERT INTO project_numbering_rules (entity_type, pattern, current_number, description, company_code, is_active) VALUES
('PROJECT', 'P-{####}', 0, 'Standard Project Numbering', 'C001', true),
('PROJECT', 'HW-{####}', 0, 'Highway Projects', 'C001', true),
('PROJECT', 'BLD-{####}', 0, 'Building Projects', 'C001', true),
('PROJECT', 'INF-{####}', 0, 'Infrastructure Projects', 'C001', true),
('PROJECT', '{COMPANY}-{YY}-{###}', 0, 'Company Year Sequential', 'C001', true)
ON CONFLICT DO NOTHING;
-- FUTURE MODULES NUMBER RANGE CONFIGURATION - PART 2
-- Plant Maintenance, Human Resources, Fixed Assets

INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object,
    from_number, to_number, current_number,
    status, external_numbering, fiscal_year,
    fiscal_year_variant, year_dependent,
    warning_threshold, critical_threshold,
    buffer_size, number_range_group
) 
SELECT * FROM (
    VALUES
    -- PLANT MAINTENANCE MODULE
    ('C001', 'EQ', 'PM_EQUNR', 0000000010000000, 0000000019999999, 0000000010000000, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '70'),
    ('C001', 'FL', 'PM_TPLNR', 0000000001, 9999999999, 0000000001, 'INACTIVE', true, 0, 'K4', false, 80, 95, 0, '70'),
    ('C001', 'PM', 'PM_AUFNR', 2024700000000, 2024709999999, 2024700000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 50, '70'),
    ('C001', 'BR', 'PM_QMNUM', 2024710000000, 2024719999999, 2024710000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 100, '70'),
    ('C001', 'MP', 'PM_WARPL', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '71'),
    ('C001', 'TS', 'PM_PLNTY', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '71'),
    
    -- HUMAN RESOURCES MODULE
    ('C001', 'PA', 'HR_PERNR', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '80'),
    ('C001', 'PY', 'HR_SEQNR', 2024800000000, 2024809999999, 2024800000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 500, '80'),
    ('C001', 'TM', 'HR_COUNTER', 2024810000000, 2024819999999, 2024810000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 1000, '80'),
    ('C001', 'LV', 'HR_SUBTY', 2024820000000, 2024829999999, 2024820000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 100, '80'),
    ('C001', 'AP', 'HR_PLVAR', 2024830000000, 2024839999999, 2024830000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 10, '81'),
    ('C001', 'TR', 'HR_OBJID', 2024840000000, 2024849999999, 2024840000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 50, '81'),
    
    -- FIXED ASSETS MODULE
    ('C001', 'AA', 'AA_ANLN1', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '90'),
    ('C001', 'AF', 'AA_BELEG', 2024900000000, 2024909999999, 2024900000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 50, '90'),
    ('C001', 'AB', 'AA_BELEG', 2024910000000, 2024919999999, 2024910000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 100, '90'),
    ('C001', 'AT', 'AA_BELEG', 2024920000000, 2024929999999, 2024920000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 20, '90'),
    ('C001', 'AR', 'AA_BELEG', 2024930000000, 2024939999999, 2024930000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 10, '90')
) AS v(company_code, document_type, number_range_object, from_number, to_number, current_number, status, external_numbering, fiscal_year, fiscal_year_variant, year_dependent, warning_threshold, critical_threshold, buffer_size, number_range_group)
WHERE NOT EXISTS (
    SELECT 1 FROM document_number_ranges d 
    WHERE d.company_code = v.company_code 
    AND d.document_type = v.document_type 
    AND d.fiscal_year = v.fiscal_year
);

-- Add Future Module Number Range Groups
INSERT INTO number_range_groups (group_code, group_name, company_code, description) VALUES
('40', 'Sales & Distribution', 'C001', 'Sales orders, quotations, deliveries, invoices'),
('50', 'Production Planning', 'C001', 'Production orders, planned orders, schedules'),
('51', 'Production Master Data', 'C001', 'BOMs, routings, work centers'),
('60', 'Quality Management', 'C001', 'Quality notifications, inspections, certificates'),
('61', 'Quality Master Data', 'C001', 'Quality plans, specifications'),
('70', 'Plant Maintenance', 'C001', 'Equipment, maintenance orders, notifications'),
('71', 'Maintenance Master Data', 'C001', 'Maintenance plans, task lists'),
('80', 'Human Resources', 'C001', 'Personnel, payroll, timesheets, leave'),
('81', 'HR Master Data', 'C001', 'Appraisals, training records'),
('90', 'Fixed Assets', 'C001', 'Asset master, acquisitions, depreciation, transfers')
ON CONFLICT (company_code, group_code) DO NOTHING;

SELECT 'Future Modules Part 2 Ranges Added' as status;
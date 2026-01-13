-- Procurement Cycle Number Range Configuration
-- Complete setup for RFQ, MR, PRPO, GR processes

-- Insert Procurement Document Number Ranges
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object,
    from_number, to_number, current_number,
    status, warning_threshold, critical_threshold,
    external_numbering, fiscal_year, fiscal_year_variant,
    year_dependent, interval_size, buffer_size,
    number_range_group
) 
SELECT * FROM (
    VALUES
    -- RFQ (Request for Quotation) - Year Dependent
    ('C001', 'AN', 'M_ANFNR', 2024100000000, 2024199999999, 2024100000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20'),
    ('B001', 'AN', 'M_ANFNR', 2024100000000, 2024199999999, 2024100000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20'),
    
    -- Material Requisition (Purchase Requisition) - Year Dependent  
    ('C001', 'NB', 'M_BANFN', 2024200000000, 2024299999999, 2024200000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20'),
    ('B001', 'NB', 'M_BANFN', 2024200000000, 2024299999999, 2024200000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20'),
    
    -- Purchase Orders - Year Dependent
    ('C001', 'F1', 'M_EBELN', 2024300000000, 2024399999999, 2024300000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20'),
    ('C001', 'F2', 'M_EBELN', 2024400000000, 2024499999999, 2024400000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20'),
    ('B001', 'F1', 'M_EBELN', 2024300000000, 2024399999999, 2024300000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20'),
    
    -- Goods Receipt/Issue - Year Dependent
    ('C001', 'WE', 'M_MBLNR', 2024500000000, 2024599999999, 2024500000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '21'),
    ('C001', 'WA', 'M_MBLNR', 2024600000000, 2024699999999, 2024600000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '21'),
    ('B001', 'WE', 'M_MBLNR', 2024500000000, 2024599999999, 2024500000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '21'),
    
    -- Construction-Specific Documents
    ('C001', 'SC', 'M_EBELN', 2024800000000, 2024899999999, 2024800000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '30'),
    ('C001', 'WO', 'CO_AUFNR', 2024000100000, 2024000199999, 2024000100000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '30'),
    ('C001', 'MTO', 'M_RSNUM', 2024900000000, 2024999999999, 2024900000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '21'),
    ('C001', 'SRV', 'M_EBELN', 2024350000000, 2024359999999, 2024350000000, 'ACTIVE', 80, 95, false, 2024, 'K4', true, 1, 10, '20')
) AS v(company_code, document_type, number_range_object, from_number, to_number, current_number, status, warning_threshold, critical_threshold, external_numbering, fiscal_year, fiscal_year_variant, year_dependent, interval_size, buffer_size, number_range_group)
WHERE NOT EXISTS (
    SELECT 1 FROM document_number_ranges d 
    WHERE d.company_code = v.company_code 
    AND d.document_type = v.document_type 
    AND d.fiscal_year = v.fiscal_year
);

-- Insert Number Range Groups for Procurement
INSERT INTO number_range_groups (group_code, group_name, company_code, description) VALUES
('20', 'Procurement Documents', 'C001', 'RFQ, PR, PO document numbering'),
('21', 'Inventory Documents', 'C001', 'GR, GI, Transfer document numbering'),
('30', 'Construction Documents', 'C001', 'Sub-contracts, Work Orders'),
('20', 'Procurement Documents', 'B001', 'RFQ, PR, PO document numbering'),
('21', 'Inventory Documents', 'B001', 'GR, GI, Transfer document numbering')
ON CONFLICT (company_code, group_code) DO NOTHING;

SELECT 'Procurement Number Ranges Configured Successfully' as status;
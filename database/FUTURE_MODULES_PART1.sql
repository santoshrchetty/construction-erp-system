-- FUTURE MODULES NUMBER RANGE CONFIGURATION
-- Sales & Distribution, Production Planning, Quality Management, Plant Maintenance, HR, Fixed Assets

-- SALES & DISTRIBUTION MODULE
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
    -- Sales Documents
    ('C001', 'OR', 'SD_VBELN', 2024400000000, 2024409999999, 2024400000000, 'INACTIVE', true, 2024, 'K4', true, 80, 95, 100, '40'),
    ('C001', 'QT', 'SD_VBELN', 2024410000000, 2024419999999, 2024410000000, 'INACTIVE', true, 2024, 'K4', true, 80, 95, 50, '40'),
    ('C001', 'CT', 'SD_VBELN', 2024420000000, 2024429999999, 2024420000000, 'INACTIVE', true, 2024, 'K4', true, 80, 95, 10, '40'),
    ('C001', 'DL', 'SD_VBELN', 2024430000000, 2024439999999, 2024430000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 200, '40'),
    ('C001', 'IV', 'SD_VBELN', 2024440000000, 2024449999999, 2024440000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 100, '40'),
    ('C001', 'CM', 'SD_VBELN', 2024450000000, 2024459999999, 2024450000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 20, '40'),
    ('C001', 'DM', 'SD_VBELN', 2024460000000, 2024469999999, 2024460000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 20, '40'),
    
    -- PRODUCTION PLANNING MODULE
    ('C001', 'PO', 'PP_AUFNR', 2024500000000, 2024509999999, 2024500000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 50, '50'),
    ('C001', 'PP', 'PP_PLNUM', 2024510000000, 2024519999999, 2024510000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 100, '50'),
    ('C001', 'BM', 'CS_STLNR', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '51'),
    ('C001', 'RT', 'PP_PLNTY', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '51'),
    ('C001', 'WC', 'PP_ARBPL', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '51'),
    ('C001', 'RR', 'PP_RSNUM', 2024520000000, 2024529999999, 2024520000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 50, '50'),
    
    -- QUALITY MANAGEMENT MODULE
    ('C001', 'QN', 'QM_QMNUM', 2024600000000, 2024609999999, 2024600000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 50, '60'),
    ('C001', 'QL', 'QM_PRUEFLOS', 2024610000000, 2024619999999, 2024610000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 100, '60'),
    ('C001', 'QC', 'QM_ZEUGNIS', 2024620000000, 2024629999999, 2024620000000, 'INACTIVE', true, 2024, 'K4', true, 80, 95, 10, '60'),
    ('C001', 'QI', 'QM_QALS', 2024630000000, 2024639999999, 2024630000000, 'INACTIVE', false, 2024, 'K4', true, 80, 95, 200, '60'),
    ('C001', 'QP', 'QM_PLNTY', 0000000001, 9999999999, 0000000001, 'INACTIVE', false, 0, 'K4', false, 80, 95, 0, '61')
) AS v(company_code, document_type, number_range_object, from_number, to_number, current_number, status, external_numbering, fiscal_year, fiscal_year_variant, year_dependent, warning_threshold, critical_threshold, buffer_size, number_range_group)
WHERE NOT EXISTS (
    SELECT 1 FROM document_number_ranges d 
    WHERE d.company_code = v.company_code 
    AND d.document_type = v.document_type 
    AND d.fiscal_year = v.fiscal_year
);

SELECT 'Future Modules Part 1 Ranges Added' as status;
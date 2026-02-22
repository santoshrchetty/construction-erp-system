-- Check column names for all DG tables

-- Contracts
SELECT 'contracts' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'contracts'
ORDER BY ordinal_position;

-- RFIs
SELECT 'rfis' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'rfis'
ORDER BY ordinal_position;

-- Specifications
SELECT 'specifications' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'specifications'
ORDER BY ordinal_position;

-- Submittals
SELECT 'submittals' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'submittals'
ORDER BY ordinal_position;

-- Change Orders
SELECT 'change_orders' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'change_orders'
ORDER BY ordinal_position;

-- Master Data Documents
SELECT 'master_data_documents' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'master_data_documents'
ORDER BY ordinal_position;

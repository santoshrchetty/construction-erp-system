-- Rename subcontractors to vendors (to match FK constraint)
ALTER TABLE subcontractors RENAME TO vendors;

-- Verify
SELECT COUNT(*) as vendor_count FROM vendors;
SELECT id, subcontractor_code as vendor_code, company_name, trade FROM vendors LIMIT 3;

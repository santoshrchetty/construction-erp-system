-- ============================================================================
-- Authorization Field Value Sources
-- ============================================================================
-- This defines where each authorization field should get its values from
-- ============================================================================

-- Field to Table Mapping
-- Format: field_name -> source_table.value_column (display_column)

/*
ORGANIZATIONAL FIELDS (from database tables):
- COMP_CODE -> company_codes.company_code (company_name)
- BUKRS -> company_codes.company_code (company_name)
- PLANT -> plants.plant_code (plant_name)
- WERKS -> plants.plant_code (plant_name)
- LGORT -> storage_locations.sloc_code (sloc_name)
- DEPT -> departments.dept_code (name)
- KOSTL -> cost_centers.cost_center_code (cost_center_name)
- EKORG -> purchasing_organizations.porg_code (porg_name)
- PROFIT_CENTER -> profit_centers.profit_center_code (profit_center_name)

ACTIVITY FIELDS (standard SAP codes):
- ACTVT -> ['01', '02', '03', '05', '06', '08', '09', '16', '22', '23', '24', '70', '71', '72', '73', '74', '75', '76', '77', '78']
  01 = Create/Add
  02 = Change
  03 = Display
  05 = Lock/Unlock
  06 = Delete
  08 = Display Change Documents
  09 = Workflow
  16 = Execute
  22 = Create with Template
  23 = Maintain
  24 = Plan Versions
  70 = Administer
  71 = Transport
  72 = Generate
  73 = Delete Version
  74 = Activate
  75 = Debug
  76 = Call
  77 = Inquiry
  78 = Release

BUSINESS OBJECT FIELDS (from reference tables):
- PROJ_TYPE -> project_categories.category_code (category_name)
- PO_TYPE -> ['standard', 'blanket', 'contract', 'emergency', 'subcontract']
- MAT_TYPE -> ['FERT', 'ROH', 'HALB', 'ERSA', 'HIBE', 'NLAG', 'UNBW', 'VERP']
- DOC_TYPE -> document_types table (if exists)
- GL_ACCT -> chart_of_accounts.account_code (account_name)

VALUE LIMITS (numeric ranges):
- PO_VALUE -> ['0-50000', '50001-100000', '100001-500000', '500001-1000000', '1000001-*']
- AMOUNT -> ['0-10000', '10001-50000', '50001-100000', '100001-*']
*/

-- Query to get company codes with tenant filtering
SELECT 
    company_code as value,
    company_code || ' - ' || company_name as display_text
FROM company_codes
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND is_active = true
ORDER BY company_code;

-- Query to get plants with tenant filtering
SELECT 
    plant_code as value,
    plant_code || ' - ' || plant_name as display_text
FROM plants
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND is_active = true
ORDER BY plant_code;

-- Query to get storage locations with tenant filtering
SELECT 
    sloc_code as value,
    sloc_code || ' - ' || sloc_name as display_text
FROM storage_locations
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND is_active = true
ORDER BY sloc_code;

-- Query to get departments with tenant filtering
SELECT 
    dept_code as value,
    dept_code || ' - ' || name as display_text
FROM departments
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND is_active = true
ORDER BY dept_code;

-- Query to get cost centers with tenant filtering
SELECT 
    cost_center_code as value,
    cost_center_code || ' - ' || cost_center_name as display_text
FROM cost_centers
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND is_active = true
ORDER BY cost_center_code;

-- Query to get purchasing organizations with tenant filtering
SELECT 
    porg_code as value,
    porg_code || ' - ' || porg_name as display_text
FROM purchasing_organizations
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND is_active = true
ORDER BY porg_code;

-- Query to get project categories with tenant filtering
SELECT 
    category_code as value,
    category_code || ' - ' || category_name as display_text
FROM project_categories
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND is_active = true
ORDER BY category_code;

# Complete Organizational Units - Construction ERP

## ✅ All Available Organizational Units

### 1. **Group & Company Structure**
- **Company Groups** (`company_groups`)
  - `grpcompany_code` - Group identifier
  - `grpcompany_name` - Group name

- **Company Codes** (`company_codes`)
  - `company_code` - Legal entity
  - `company_name` - Company name
  - `currency` - Company currency
  - `country_code` - Country assignment

### 2. **Physical Structure**
- **Plants** (`plants`)
  - `plant_code` - Site/location identifier
  - `plant_name` - Site name
  - `plant_type` - WAREHOUSE, SITE, OFFICE, YARD

- **Storage Locations** (`storage_locations`)
  - `location_code` - Storage location
  - `location_name` - Location description
  - `location_type` - Storage type

### 3. **Procurement Structure**
- **Purchasing Organizations** (`purchasing_organizations`)
  - `purch_org_code` - Procurement authority
  - `purch_org_name` - Organization name

- **Purchasing Groups** (`purchasing_groups`)
  - `purch_group_code` - Procurement team
  - `purch_group_name` - Group name

### 4. **Cost Accounting Structure**
- **Controlling Areas** (`controlling_areas`)
  - `controlling_area_code` - Cost accounting area
  - `controlling_area_name` - Area name

- **Cost Centers** (`cost_centers`)
  - `cost_center_code` - Cost responsibility
  - `cost_center_name` - Cost center name
  - `department_code` - Department link

- **Profit Centers** (`profit_centers`)
  - `profit_center_code` - Profit responsibility
  - `profit_center_name` - Profit center name

### 5. **Departmental Structure**
- **Departments** (`departments`)
  - `department_code` - Department identifier
  - `department_name` - Department name
  - `manager_id` - Department manager

### 6. **Project Structure**
- **Project Categories** (`project_categories`)
  - `category_code` - Project type
  - `category_name` - Category name

- **Projects** (`projects`)
  - `project_code` - Project identifier
  - `project_name` - Project name
  - `company_code` - Company assignment
  - `plant_code` - Site assignment
  - `cost_center` - Cost center assignment
  - `profit_center` - Profit center assignment

- **WBS Elements** (`wbs_element`)
  - `wbs_element_code` - Work breakdown structure
  - `project_code` - Project link
  - `parent_wbs_code` - Hierarchy
  - `level` - WBS level

- **Activities** (`activities`)
  - `activity_code` - Activity identifier
  - `project_code` - Project link
  - `wbs_element_code` - WBS link
  - `parent_activity_code` - Activity hierarchy

## Material Request Line Item Org Unit Assignment

### Required Fields (All Available):

**Organizational Units:**
- `company_code` ✅ - Legal entity
- `plant_code` ✅ - Physical location
- `purchasing_organization` ✅ - Procurement authority
- `purchasing_group` ✅ - Procurement team

**Account Assignment:**
- `cost_center` ✅ - Cost responsibility
- `profit_center` ✅ - Profit responsibility
- `department_code` ✅ - Department assignment
- `project_code` ✅ - Project assignment
- `wbs_element` ✅ - WBS assignment
- `activity_code` ✅ - Activity assignment

**Additional Assignment:**
- `controlling_area` ✅ - Cost accounting area
- `storage_location` ✅ - Storage assignment

## Complete Organizational Hierarchy

```
Group Company (OMEGA_GROUP)
├── Company Code (ODL_UK) ✅
│   ├── Controlling Area (CA_UK) ✅
│   ├── Purchasing Organization (PO_UK) ✅
│   │   └── Purchasing Groups (PG_CONST, PG_OFFICE) ✅
│   ├── Plants/Sites ✅
│   │   ├── SITE001 (Main Warehouse)
│   │   ├── SITE002 (Project Site A)
│   │   └── OFF001 (Head Office)
│   ├── Departments ✅
│   │   ├── MAINT (Maintenance)
│   │   ├── ADMIN (Administration)
│   │   └── SAFETY (Safety Department)
│   ├── Cost Centers ✅
│   │   ├── CC001 (Maintenance)
│   │   ├── CC002 (Administration)
│   │   └── CC003 (Project Management)
│   ├── Profit Centers ✅
│   │   ├── PC001 (Construction Division)
│   │   └── PC002 (Services Division)
│   └── Projects ✅
│       ├── PRJ001 (Building A)
│       │   ├── WBS Elements ✅
│       │   └── Activities ✅
│       └── PRJ002 (Building B)
```

## Copy to PR Functionality - Complete Coverage

With all master data tables available, the Material Request line items can capture:

1. **Full Organizational Assignment** - Complete org unit hierarchy
2. **Proper Account Assignment** - All cost accounting objects
3. **Procurement Authority** - Purchasing org and group assignment
4. **Physical Location** - Plant and storage location
5. **Project Integration** - Full project, WBS, and activity links

This ensures **100% accurate Copy to PR** functionality with complete organizational unit and account assignment data at the line item level.

## Benefits

✅ **Complete ERP Integration** - All org units available
✅ **Accurate Cost Allocation** - Proper account assignment
✅ **Procurement Control** - Purchasing authority defined
✅ **Project Tracking** - Full project integration
✅ **Financial Reporting** - Complete cost/profit center assignment
✅ **Audit Compliance** - Full traceability and controls
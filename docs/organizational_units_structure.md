# Organizational Units in Construction ERP Database

## Current Organizational Structure

### 1. **Company Group Level**
```
company_groups table:
- grpcompany_code (Primary Key)
- grpcompany_name
- description
```
**Purpose:** Top-level holding company or group structure
**Example:** "OMEGA_GROUP" - Omega Data Labs Group

### 2. **Company Code Level**
```
company_codes table:
- company_code (Primary Key)
- company_name
- grpcompany_code (Foreign Key to company_groups)
- currency
- country_code
```
**Purpose:** Individual legal entities within the group
**Examples:** 
- "ODL_UK" - Omega Data Labs UK Ltd
- "ODL_US" - Omega Data Labs USA Inc
- "ODL_AU" - Omega Data Labs Australia Pty

### 3. **Project Structure**
```
projects table:
- code (Project Code)
- company_code (Foreign Key)
- plant_code
- cost_center
- profit_center
- category_code (Foreign Key to project_categories)
```

```
project_categories table:
- category_code (Primary Key)
- category_name
```
**Examples:**
- "RESIDENTIAL" - Residential Construction
- "COMMERCIAL" - Commercial Buildings
- "INFRASTRUCTURE" - Infrastructure Projects

### 4. **Work Breakdown Structure (WBS)**
```
wbs_element table:
- wbs_element_code (Primary Key)
- project_code (Foreign Key)
- parent_wbs_code (Self-referencing)
- level (Hierarchy level)
```
**Purpose:** Project work breakdown structure
**Example Hierarchy:**
- Level 1: "PRJ001" - Building A Project
- Level 2: "PRJ001.100" - Foundation Work
- Level 3: "PRJ001.110" - Excavation
- Level 3: "PRJ001.120" - Concrete Pour

### 5. **Activity Structure**
```
activities table:
- activity_code (Primary Key)
- project_code (Foreign Key)
- wbs_element_code (Foreign Key)
- parent_activity_code (Self-referencing)
```
**Purpose:** Detailed project activities/tasks

## Missing Organizational Units for Complete ERP

### 1. **Plant/Site Structure**
```sql
-- Need to create plants table
CREATE TABLE plants (
    plant_code VARCHAR(10) PRIMARY KEY,
    plant_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(10) REFERENCES company_codes(company_code),
    address TEXT,
    plant_type VARCHAR(20), -- WAREHOUSE, SITE, OFFICE, YARD
    is_active BOOLEAN DEFAULT true
);
```

### 2. **Purchasing Organization**
```sql
-- Need to create purchasing organizations
CREATE TABLE purchasing_organizations (
    purch_org_code VARCHAR(10) PRIMARY KEY,
    purch_org_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(10) REFERENCES company_codes(company_code),
    currency VARCHAR(3),
    is_active BOOLEAN DEFAULT true
);
```

### 3. **Purchasing Groups**
```sql
-- Need to create purchasing groups
CREATE TABLE purchasing_groups (
    purch_group_code VARCHAR(10) PRIMARY KEY,
    purch_group_name VARCHAR(100) NOT NULL,
    purch_org_code VARCHAR(10) REFERENCES purchasing_organizations(purch_org_code),
    is_active BOOLEAN DEFAULT true
);
```

### 4. **Cost Centers** (Already partially referenced)
```sql
-- Enhance existing cost_centers table
ALTER TABLE cost_centers ADD COLUMN IF NOT EXISTS 
    controlling_area VARCHAR(10),
    company_code VARCHAR(10) REFERENCES company_codes(company_code),
    profit_center VARCHAR(10);
```

### 5. **Profit Centers**
```sql
-- Need to create profit centers table
CREATE TABLE profit_centers (
    profit_center_code VARCHAR(10) PRIMARY KEY,
    profit_center_name VARCHAR(100) NOT NULL,
    controlling_area VARCHAR(10),
    company_code VARCHAR(10) REFERENCES company_codes(company_code),
    is_active BOOLEAN DEFAULT true
);
```

### 6. **Controlling Area**
```sql
-- Need controlling area for cost accounting
CREATE TABLE controlling_areas (
    controlling_area_code VARCHAR(10) PRIMARY KEY,
    controlling_area_name VARCHAR(100) NOT NULL,
    currency VARCHAR(3),
    company_code VARCHAR(10) REFERENCES company_codes(company_code),
    is_active BOOLEAN DEFAULT true
);
```

## Complete Organizational Hierarchy

```
Group Company (OMEGA_GROUP)
├── Company Code (ODL_UK)
│   ├── Controlling Area (CA_UK)
│   ├── Purchasing Organization (PO_UK)
│   │   └── Purchasing Groups (PG_CONST, PG_OFFICE)
│   ├── Plants/Sites
│   │   ├── SITE001 (Main Warehouse)
│   │   ├── SITE002 (Project Site A)
│   │   └── OFF001 (Head Office)
│   ├── Cost Centers
│   │   ├── CC001 (Maintenance)
│   │   ├── CC002 (Administration)
│   │   └── CC003 (Project Management)
│   ├── Profit Centers
│   │   ├── PC001 (Construction Division)
│   │   └── PC002 (Services Division)
│   └── Projects
│       ├── PRJ001 (Building A)
│       │   ├── WBS Elements
│       │   └── Activities
│       └── PRJ002 (Building B)
```

## Material Request Line Item Org Unit Assignment

For each MR line item, these org units should be captured:
- **company_code** - Legal entity
- **plant_code** - Physical location/site
- **purchasing_organization** - Procurement authority
- **purchasing_group** - Procurement team
- **cost_center** - Cost responsibility
- **profit_center** - Profit responsibility
- **project_code** - Project assignment (if applicable)
- **wbs_element** - WBS assignment (if applicable)
- **activity_code** - Activity assignment (if applicable)

This structure ensures proper cost allocation, procurement authority, and financial reporting at the line item level for accurate Copy to PR functionality.
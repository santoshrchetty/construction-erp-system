# Database Design Reference - VARCHAR Codes Standard

## Table Design Patterns

### Master Data Tables
```sql
-- Company Codes
CREATE TABLE company_codes (
    id UUID PRIMARY KEY,
    company_code VARCHAR(10) UNIQUE NOT NULL,  -- Business key
    company_name VARCHAR(100) NOT NULL
);

-- Plants
CREATE TABLE plants (
    id UUID PRIMARY KEY,
    plant_code VARCHAR(10) UNIQUE NOT NULL,    -- Business key
    plant_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(10) NOT NULL          -- VARCHAR reference
);

-- Cost Centers
CREATE TABLE cost_centers (
    id UUID PRIMARY KEY,
    cost_center_code VARCHAR(10) UNIQUE NOT NULL,  -- Business key
    cost_center_name VARCHAR(100) NOT NULL,
    company_code VARCHAR(10) NOT NULL              -- VARCHAR reference
);
```

### Transaction Tables
```sql
-- Material Requests
CREATE TABLE material_requests (
    id UUID PRIMARY KEY,
    request_number VARCHAR(50) UNIQUE NOT NULL,
    company_code VARCHAR(10) NOT NULL,         -- VARCHAR reference
    plant_code VARCHAR(10),                    -- VARCHAR reference
    project_code VARCHAR(20),                  -- VARCHAR reference
    cost_center VARCHAR(10),                   -- VARCHAR reference
    wbs_element VARCHAR(50),                   -- VARCHAR reference
    storage_location VARCHAR(31),              -- VARCHAR reference
    activity_code VARCHAR(31)                  -- VARCHAR reference
);

-- Projects
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,          -- Business key
    name VARCHAR(200) NOT NULL,
    company_code VARCHAR(10) NOT NULL,         -- VARCHAR reference
    category_code VARCHAR(20),                 -- VARCHAR reference
    project_type VARCHAR(50)
);
```

## Index Strategy
```sql
-- Always index VARCHAR code columns for performance
CREATE INDEX idx_material_requests_company_code ON material_requests(company_code);
CREATE INDEX idx_material_requests_plant_code ON material_requests(plant_code);
CREATE INDEX idx_material_requests_project_code ON material_requests(project_code);
CREATE INDEX idx_projects_company_code ON projects(company_code);
CREATE INDEX idx_plants_company_code ON plants(company_code);
```

## Query Patterns
```sql
-- JOIN using VARCHAR codes (CORRECT)
SELECT mr.*, p.plant_name, cc.company_name
FROM material_requests mr
JOIN plants p ON mr.plant_code = p.plant_code
JOIN company_codes cc ON mr.company_code = cc.company_code;

-- Filter using VARCHAR codes (CORRECT)
SELECT * FROM projects WHERE company_code = 'C001';
SELECT * FROM plants WHERE company_code = 'C001';
```

## API Response Format
```json
{
  "id": "uuid-here",
  "request_number": "MR-2024-001",
  "company_code": "C001",           // VARCHAR code
  "plant_code": "P001",             // VARCHAR code
  "project_code": "PROJ-2024-001",  // VARCHAR code
  "cost_center": "CC001"            // VARCHAR code
}
```

## Migration Template
```sql
-- Template for adding VARCHAR code columns
ALTER TABLE {table_name} 
ADD COLUMN IF NOT EXISTS {field}_code VARCHAR({length});

-- Template for adding indexes
CREATE INDEX IF NOT EXISTS idx_{table_name}_{field}_code 
ON {table_name}({field}_code);

-- Template for populating from existing UUID references (if needed)
UPDATE {table_name} 
SET {field}_code = ref.{field}_code
FROM {reference_table} ref 
WHERE {table_name}.{field}_id = ref.id 
AND {table_name}.{field}_code IS NULL;
```

This design ensures:
- Human-readable data
- Fast lookups with indexes
- No conversion overhead
- Consistent patterns across all tables
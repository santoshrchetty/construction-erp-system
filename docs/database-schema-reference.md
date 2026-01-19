# Database Schema Reference - Updated

## 📋 Table Structures

### 1. `companies` Table (Parent/Group Companies)

**Purpose:** Stores parent company groups that own multiple company codes

```sql
CREATE TABLE companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grpcompany_name VARCHAR(200) NOT NULL,  -- ⚠️ Changed from company_name
    industry VARCHAR(50),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Example Data:**
| company_id | grpcompany_name | industry | country |
|------------|-----------------|----------|---------|
| uuid-1 | ABC Construction Group | CONSTRUCTION | IN |
| uuid-2 | Bramen Group | CONSTRUCTION | IN |
| uuid-3 | Nascar Group | CONSTRUCTION | IN |

---

### 2. `company_codes` Table (Individual Companies)

**Purpose:** Stores individual company entities with unique codes

```sql
CREATE TABLE company_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(10) NOT NULL UNIQUE,
    company_name VARCHAR(200) NOT NULL,
    company_id UUID REFERENCES companies(company_id),
    legal_entity_name VARCHAR(200),
    currency VARCHAR(3),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Example Data:**
| company_code | company_name | company_id | grpcompany_name (via FK) |
|--------------|--------------|------------|--------------------------|
| C001 | ABC Construction Ltd | uuid-1 | ABC Construction Group |
| C002 | ABC Infrastructure | uuid-1 | ABC Construction Group |
| B001 | Bramen Ltd | uuid-2 | Bramen Group |
| N001 | Nascar Ltd | uuid-3 | Nascar Group |

---

### 3. `projects` Table

**Purpose:** Stores project information

```sql
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    company_code_id UUID REFERENCES company_codes(id),
    project_type VARCHAR(50),
    status VARCHAR(50),
    start_date DATE,
    planned_end_date DATE,
    budget NUMERIC(15,2),
    location VARCHAR(200),
    description TEXT,
    created_by UUID,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Example Data:**
| code | name | company_code_id | company_code (via FK) |
|------|------|-----------------|----------------------|
| P001 | Highway Project | uuid-c001 | C001 |
| HW0001 | Bridge Construction | uuid-c002 | C002 |

---

## 🔗 Relationships

```
companies (Parent Groups)
    ↓ (1:N)
company_codes (Individual Companies)
    ↓ (1:N)
projects (Projects)
```

**SQL Join Example:**
```sql
SELECT 
    p.code as project_code,
    p.name as project_name,
    cc.company_code,
    cc.company_name,
    c.grpcompany_name as parent_company
FROM projects p
JOIN company_codes cc ON p.company_code_id = cc.id
JOIN companies c ON cc.company_id = c.company_id
WHERE p.status = 'active';
```

---

## 🎯 Column Naming Convention

### Why Different Names?

| Table | Column | Purpose | Example Value |
|-------|--------|---------|---------------|
| `companies` | `grpcompany_name` | Parent group name | "ABC Construction Group" |
| `company_codes` | `company_name` | Individual company name | "ABC Construction Ltd" |
| `company_codes` | `company_code` | Company identifier | "C001" |
| `projects` | `code` | Project identifier | "P001" |

**Rationale:**
- `grpcompany_name` prefix distinguishes it from `company_codes.company_name`
- Prevents confusion when joining tables
- Makes queries more readable

---

## 📝 Migration History

### Migration 1: Rename companies.company_name → grpcompany_name
**Date:** 2024
**File:** `database/rename-companies-company-name.sql`

```sql
ALTER TABLE companies 
RENAME COLUMN company_name TO grpcompany_name;
```

**Affected Files:**
- `database/discover-all-company-codes.sql`
- `database/consolidate-abc-companies.sql`
- `database/setup-existing-companies.sql`

**Rollback:** `database/rollback-companies-rename.sql`

---

## 🔍 Common Queries

### Get all projects with company details
```sql
SELECT 
    p.code,
    p.name,
    cc.company_code,
    cc.company_name,
    c.grpcompany_name
FROM projects p
JOIN company_codes cc ON p.company_code_id = cc.id
LEFT JOIN companies c ON cc.company_id = c.company_id
ORDER BY p.created_at DESC;
```

### Get all companies under a parent group
```sql
SELECT 
    cc.company_code,
    cc.company_name,
    c.grpcompany_name
FROM company_codes cc
JOIN companies c ON cc.company_id = c.company_id
WHERE c.grpcompany_name = 'ABC Construction Group'
ORDER BY cc.company_code;
```

### Get project count by company
```sql
SELECT 
    cc.company_code,
    cc.company_name,
    COUNT(p.id) as project_count
FROM company_codes cc
LEFT JOIN projects p ON cc.id = p.company_code_id
GROUP BY cc.company_code, cc.company_name
ORDER BY project_count DESC;
```

---

## ⚠️ Important Notes

### Foreign Key References
- Always use UUID foreign keys, not string codes
- `projects.company_code_id` → `company_codes.id` (not company_code)
- This ensures referential integrity

### Data Integrity
- `company_codes.company_code` must be unique
- `projects.code` must be unique
- All foreign keys should have indexes for performance

### Application Layer
- UI displays `company_code` (e.g., "C001")
- Backend stores `company_code_id` (UUID)
- Joins fetch related data when needed

---

**Last Updated:** After grpcompany_name migration
**Status:** ✅ Current Schema

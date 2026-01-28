# MANDATORY CODING STANDARDS - VARCHAR CODES ONLY

## Core Principle: Human-Readable Codes
**RULE**: Always use VARCHAR codes, never UUID foreign keys for business entities.

## Database Design Standards

### ✅ CORRECT Approach - VARCHAR Codes
```sql
-- Table structure
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    company_code VARCHAR(10),     -- ✅ Use this
    plant_code VARCHAR(10),       -- ✅ Use this
    project_code VARCHAR(20),     -- ✅ Use this
    cost_center VARCHAR(10)       -- ✅ Use this
);

-- Indexes for performance
CREATE INDEX idx_projects_company_code ON projects(company_code);
```

### ❌ FORBIDDEN Approach - UUID Foreign Keys
```sql
-- DO NOT USE
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    company_code_id UUID,         -- ❌ Never use this
    plant_code_id UUID,           -- ❌ Never use this
    project_code_id UUID          -- ❌ Never use this
);
```

## Backend Service Standards

### ✅ CORRECT Service Implementation
```typescript
export async function updateProject(id: string, payload: any, userId: string) {
  const { data, error } = await supabase
    .from('projects')
    .update({
      company_code: payload.company_code,    // ✅ Direct VARCHAR mapping
      plant_code: payload.plant_code,        // ✅ Direct VARCHAR mapping
      project_code: payload.project_code     // ✅ Direct VARCHAR mapping
    })
    .eq('id', id)
}
```

### ❌ FORBIDDEN Service Implementation
```typescript
// DO NOT USE - No conversions allowed
export async function updateProject(id: string, payload: any, userId: string) {
  // ❌ Never convert codes to UUIDs
  const { data: company } = await supabase
    .from('company_codes')
    .select('id')
    .eq('company_code', payload.company_code)
  
  const { data, error } = await supabase
    .from('projects')
    .update({
      company_code_id: company.id  // ❌ Forbidden
    })
}
```

## Frontend Standards

### ✅ CORRECT Frontend Implementation
```typescript
// Form data structure
const formData = {
  company_code: "C001",           // ✅ Send VARCHAR codes
  plant_code: "P001",             // ✅ Send VARCHAR codes
  project_code: "PROJ-2024-001"   // ✅ Send VARCHAR codes
}

// API call
const response = await fetch('/api/projects', {
  method: 'POST',
  body: JSON.stringify(formData)  // ✅ Direct code submission
})
```

### ❌ FORBIDDEN Frontend Implementation
```typescript
// DO NOT USE
const formData = {
  company_code_id: "uuid-here",   // ❌ Never send UUIDs
  plant_code_id: "uuid-here"      // ❌ Never send UUIDs
}
```

## API Design Standards

### ✅ CORRECT API Parameters
```typescript
// GET /api/projects?companyCode=C001        ✅ Use codes
// GET /api/plants?companyCode=C001          ✅ Use codes
// GET /api/cost-centers?companyCode=C001    ✅ Use codes
```

### ❌ FORBIDDEN API Parameters
```typescript
// GET /api/projects?companyId=uuid-here     ❌ Never use UUIDs
// GET /api/plants?companyId=uuid-here       ❌ Never use UUIDs
```

## Migration Standards

### ✅ CORRECT Migration Pattern
```sql
-- Always add VARCHAR code columns
ALTER TABLE material_requests 
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

-- Always add indexes on codes
CREATE INDEX IF NOT EXISTS idx_material_requests_company_code 
ON material_requests(company_code);
```

### ❌ FORBIDDEN Migration Pattern
```sql
-- DO NOT ADD UUID foreign key columns
ALTER TABLE material_requests 
ADD COLUMN company_code_id UUID REFERENCES company_codes(id);  -- ❌ Forbidden
```

## Benefits of VARCHAR Code Approach

1. **Human Readable**: Codes are meaningful (C001, P001, PROJ-2024-001)
2. **No Conversions**: Direct mapping between frontend and database
3. **Performance**: Indexed VARCHAR lookups are fast
4. **Debugging**: Easy to trace data flow
5. **Consistency**: Same approach across all modules

## Enforcement Rules

1. **Code Reviews**: Reject any UUID foreign key implementations
2. **Database Schema**: Only VARCHAR code columns allowed
3. **API Design**: Only accept/return codes, never UUIDs
4. **Service Layer**: No code-to-UUID conversions permitted
5. **Frontend**: Only send/receive VARCHAR codes

## Exception Policy
**NO EXCEPTIONS** - This standard is mandatory for all business entity relationships.

---
**Last Updated**: Current Date
**Applies To**: All modules, all developers, all new features
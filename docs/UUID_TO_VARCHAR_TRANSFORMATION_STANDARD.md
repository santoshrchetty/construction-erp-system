# UUID to VARCHAR Transformation Standard Procedure

## Overview
This document outlines the complete step-by-step process for transforming UUID-based foreign key relationships to VARCHAR business code relationships. This standard was successfully applied to the organizational hierarchy (companies → projects) and can be replicated for other table transformations.

## Phase 1: Analysis and Planning

### Step 1: Analyze Current Structure
```sql
-- Check table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = '[target_table]' 
ORDER BY ordinal_position;

-- Check foreign key dependencies
SELECT 
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_name = '[target_table]';
```

### Step 2: Design VARCHAR Hierarchy
- Identify business entities and their natural codes
- Design VARCHAR code patterns (e.g., GRP001, C001, PROJ-001)
- Map relationships using business codes instead of UUIDs
- Plan master data tables vs operational tables

## Phase 2: Database Schema Transformation

### Step 3: Create Master Data Tables
```sql
-- Create master tables with VARCHAR primary keys
CREATE TABLE [master_table] (
    [code_field] VARCHAR(10) PRIMARY KEY,
    [name_field] VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Populate with business codes
INSERT INTO [master_table] ([code_field], [name_field])
SELECT DISTINCT 
    'PREFIX' || LPAD(ROW_NUMBER() OVER (ORDER BY [sort_field])::text, 3, '0'),
    [name_field]
FROM [source_table];
```

### Step 4: Add VARCHAR Columns to Existing Tables
```sql
-- Add VARCHAR foreign key columns
ALTER TABLE [target_table] 
ADD COLUMN IF NOT EXISTS [varchar_code_field] VARCHAR(10);

-- Populate from existing relationships
UPDATE [target_table] 
SET [varchar_code_field] = mt.[code_field]
FROM [master_table] mt
JOIN [old_table] ot ON [existing_relationship]
WHERE [target_table].[old_uuid_field] = ot.id;
```

### Step 5: Remove UUID Dependencies
```sql
-- Drop UUID foreign key constraints
ALTER TABLE [target_table] 
DROP CONSTRAINT IF EXISTS [old_fk_constraint_name];

-- Drop UUID columns
ALTER TABLE [target_table] 
DROP COLUMN IF EXISTS [old_uuid_field];

-- Make VARCHAR fields NOT NULL
ALTER TABLE [target_table] 
ALTER COLUMN [varchar_code_field] SET NOT NULL;
```

### Step 6: Add VARCHAR Foreign Key Constraints
```sql
-- Add new VARCHAR foreign key constraints
ALTER TABLE [target_table] 
ADD CONSTRAINT fk_[target_table]_[master_table] 
  FOREIGN KEY ([varchar_code_field]) 
  REFERENCES [master_table]([code_field]);
```

### Step 7: Add Performance Indexes
```sql
-- Add indexes for VARCHAR lookups
CREATE INDEX IF NOT EXISTS idx_[target_table]_[varchar_field] 
ON [target_table]([varchar_code_field]);

-- Add composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_[target_table]_[field1]_[field2] 
ON [target_table]([varchar_field1], [varchar_field2]);
```

## Phase 3: Application Layer Updates

### Step 8: Update TypeScript Schema Definitions
```typescript
// Update types/database.ts
export interface Database {
  public: {
    Tables: {
      [table_name]: {
        Row: {
          // Remove UUID fields
          // Add VARCHAR fields
          [varchar_code_field]: string
        }
        Insert: {
          [varchar_code_field]: string
        }
        Update: {
          [varchar_code_field]?: string
        }
      }
    }
  }
}
```

### Step 9: Update Zod Validation Schemas
```typescript
// Update types/schemas/[entity].schema.ts
export const [Entity]Schema = z.object({
  // Remove UUID validations
  // Add VARCHAR validations
  [varchar_code_field]: z.string().min(1).max(10)
})
```

### Step 10: Update API Routes
```typescript
// Update API parameters from UUID to VARCHAR
// BEFORE: ?companyId=uuid
// AFTER:  ?companyCode=varchar

// Update queries
const { data } = await supabase
  .from('[table]')
  .select('*')
  .eq('[varchar_field]', varcharCode) // Instead of UUID
```

### Step 11: Update Service Layer
```typescript
// Update service methods
export async function getRecords(code: string) { // VARCHAR instead of UUID
  const { data } = await supabase
    .from('[table]')
    .select('*')
    .eq('[varchar_field]', code)
}

// Update joins to use VARCHAR codes
.select(`
  *,
  [master_table]!inner([varchar_field])
`)
```

### Step 12: Update React Components
```typescript
// Update component props and state
interface Props {
  [entity]Code: string // VARCHAR instead of UUID
}

// Update dropdown loading
const load[Entity]Data = async (code: string) => {
  const response = await fetch(`/api/[endpoint]?[entity]Code=${code}`)
}

// Update form field references
<select 
  value={formData.[varchar_field]}
  onChange={(e) => setFormData(prev => ({ 
    ...prev, 
    [varchar_field]: e.target.value 
  }))}
>
```

## Phase 4: Middleware and Authorization Updates

### Step 13: Update Authorization Services
```typescript
// Update authorization queries to use VARCHAR codes
const { data } = await supabase
  .from('[auth_table]')
  .select('*')
  .eq('[varchar_field]', userVarcharCode) // Instead of UUID
```

### Step 14: Update Permission Checks
```typescript
// Update permission validation to use VARCHAR codes
async function checkAccess(userCode: string, resourceCode: string) {
  // Use VARCHAR codes for access control
}
```

## Phase 5: Cleanup and Verification

### Step 15: Remove Redundant Tables
```sql
-- Check dependencies before removal
SELECT tc.table_name, tc.constraint_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND ccu.table_name = '[old_table]';

-- Drop redundant tables
DROP TABLE IF EXISTS [old_table] CASCADE;
```

### Step 16: Final Verification
```sql
-- Verify no UUID foreign keys remain
SELECT table_name, column_name, data_type
FROM information_schema.columns 
WHERE table_name IN ('[transformed_tables]')
AND data_type = 'uuid'
AND column_name LIKE '%_id';

-- Test VARCHAR hierarchy queries
SELECT [master].[code], [detail].[varchar_field], COUNT(*)
FROM [master_table] [master]
LEFT JOIN [detail_table] [detail] ON [master].[code] = [detail].[varchar_field]
GROUP BY [master].[code], [detail].[varchar_field];
```

## Success Criteria Checklist

- [ ] All UUID foreign keys removed from target tables
- [ ] VARCHAR master data tables created with business codes
- [ ] Foreign key constraints use VARCHAR codes only
- [ ] Performance indexes added for VARCHAR lookups
- [ ] TypeScript schemas updated (database.ts, zod schemas)
- [ ] API routes use VARCHAR parameters
- [ ] Service layer queries use VARCHAR codes
- [ ] React components reference VARCHAR fields
- [ ] Authorization services use VARCHAR codes
- [ ] Middleware updated for VARCHAR hierarchy
- [ ] Redundant UUID tables removed
- [ ] All queries tested and working
- [ ] No UUID dependencies remain

## Benefits Achieved

1. **Human Readable**: Business codes instead of UUIDs
2. **Performance**: VARCHAR indexes faster than UUID joins
3. **Debugging**: Easy to trace relationships in logs
4. **ERP Integration**: Direct mapping to business systems
5. **Maintainability**: Simpler queries and relationships
6. **Data Integrity**: Foreign key constraints ensure validity

## Example Application: Organizational Hierarchy

This standard was successfully applied to transform:
```
UUID Hierarchy (BEFORE):
companies(id) → company_codes(company_id) → projects(company_code_id)

VARCHAR Hierarchy (AFTER):
company_groups(grpcompany_code) → company_codes(grpcompany_code) → projects(company_code)
```

**Result**: Complete elimination of UUID dependencies with pure VARCHAR business code relationships.
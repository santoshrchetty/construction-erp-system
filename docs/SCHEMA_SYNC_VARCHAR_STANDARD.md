# Database Schema Sync Workflow - VARCHAR Codes Standard

## Overview
This project uses **VARCHAR codes as the MANDATORY standard** for all business entity relationships. Database-generated types must reflect this standard.

## Workflow Steps

### 1. After Database Changes (VARCHAR Codes Only)
```bash
# Run migration (must use VARCHAR codes)
psql -d your_db -f database/migrate-to-foreign-keys-only.sql

# Generate new types
npm run generate-types
```

### 2. Validate Types Compliance
```bash
# Check TypeScript compilation
npm run validate-schema

# Verify VARCHAR code compliance
npm run check-varchar-compliance
```

### 3. Update Components (VARCHAR Codes Only)
- Components must use VARCHAR codes from `types/database.ts`
- Form data must conform to `MaterialRequestFormData` with VARCHAR codes
- Use `validateMaterialRequestData()` before API calls (VARCHAR codes only)

### 4. Development Workflow
```bash
# Full sync after schema changes
npm run sync-schema

# During development
npm run dev
```

## File Structure (VARCHAR Codes Standard)
```
types/
├── database.ts      # Generated from Supabase (VARCHAR codes only)
├── forms.ts         # Form types derived from database types (VARCHAR codes)
└── index.ts         # Re-exports

components/
└── tiles/
    └── UnifiedMaterialRequestComponent.tsx  # Uses VARCHAR coded form data
```

## Type Safety Rules (VARCHAR Codes Mandatory)
1. **Never** manually edit `types/database.ts`
2. **Always** derive form types from database types (VARCHAR codes only)
3. **Use** validation functions before API calls (VARCHAR codes only)
4. **Run** `npm run sync-schema` after schema changes
5. **Reject** any UUID foreign key implementations in code reviews

## Generated Type Example (CORRECT)
```typescript
export interface MaterialRequest {
  id: string
  request_number: string
  company_code: string        // ✅ VARCHAR code
  plant_code: string | null   // ✅ VARCHAR code
  project_code: string | null // ✅ VARCHAR code
  cost_center: string | null  // ✅ VARCHAR code
  wbs_element: string | null  // ✅ VARCHAR code
}
```

## Generated Type Example (FORBIDDEN)
```typescript
export interface MaterialRequest {
  id: string
  request_number: string
  company_code_id: string     // ❌ UUID foreign key - FORBIDDEN
  plant_code_id: string       // ❌ UUID foreign key - FORBIDDEN
  project_code_id: string     // ❌ UUID foreign key - FORBIDDEN
}
```

## Benefits of VARCHAR Code Standard
- ✅ Compile-time field validation (VARCHAR codes)
- ✅ Automatic type updates (VARCHAR codes)
- ✅ Prevents field mismatches (VARCHAR codes)
- ✅ IDE autocomplete support (VARCHAR codes)
- ✅ Human-readable debugging
- ✅ No conversion overhead

## Compliance Checking
```bash
# Add to package.json scripts
"check-varchar-compliance": "node scripts/check-varchar-compliance.js"
```

## Enforcement
- All generated types must use VARCHAR codes
- Code reviews must verify VARCHAR code compliance
- No UUID foreign key types allowed in any generated schema
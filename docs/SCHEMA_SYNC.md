# Database Schema Sync Workflow

## Overview
This project uses database-generated types as the source of truth to ensure components stay in sync with the database schema.

## Workflow Steps

### 1. After Database Changes
```bash
# Run migration
psql -d your_db -f database/migrate-to-foreign-keys-only.sql

# Generate new types
npm run generate-types
```

### 2. Validate Types
```bash
# Check TypeScript compilation
npm run validate-schema
```

### 3. Update Components
- Components must use types from `types/database.ts`
- Form data must conform to `MaterialRequestFormData`
- Use `validateMaterialRequestData()` before API calls

### 4. Development Workflow
```bash
# Full sync after schema changes
npm run sync-schema

# During development
npm run dev
```

## File Structure
```
types/
├── database.ts      # Generated from Supabase
├── forms.ts         # Form types derived from database types
└── index.ts         # Re-exports

components/
└── tiles/
    └── UnifiedMaterialRequestComponent.tsx  # Uses typed form data
```

## Type Safety Rules
1. **Never** manually edit `types/database.ts`
2. **Always** derive form types from database types
3. **Use** validation functions before API calls
4. **Run** `npm run sync-schema` after schema changes

## Benefits
- ✅ Compile-time field validation
- ✅ Automatic type updates
- ✅ Prevents field mismatches
- ✅ IDE autocomplete support
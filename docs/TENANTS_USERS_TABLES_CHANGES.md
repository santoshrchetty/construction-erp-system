# TENANTS AND USERS TABLES - CHANGES ANALYSIS

## TENANTS TABLE

### ✅ NO CHANGES REQUIRED

**Reason:** The existing tenants table structure is sufficient for external access.

**Existing structure (assumed):**
```sql
tenants (
  tenant_id UUID PRIMARY KEY,
  tenant_name VARCHAR,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  ...
)
```

**Why no changes needed:**
- Tenant isolation already works via tenant_id in all tables
- External organizations belong to the same tenant
- No additional tenant-level fields needed for external access
- RLS policies use existing tenant_id

**Verification:**
```sql
-- Ensure tenants table exists and has tenant_id
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tenants' 
AND column_name = 'tenant_id';
```

---

## USERS TABLE

### ⚠️ OPTIONAL CHANGE (Recommended but not required)

**Option 1: Add user_type field (RECOMMENDED)**

```sql
-- Add user_type to distinguish internal vs external users
ALTER TABLE users ADD COLUMN IF NOT EXISTS user_type VARCHAR(20) DEFAULT 'INTERNAL';
ALTER TABLE users ADD CONSTRAINT IF NOT EXISTS users_user_type_check 
  CHECK (user_type IN ('INTERNAL', 'EXTERNAL'));

-- Add index
CREATE INDEX IF NOT EXISTS idx_users_type ON users(user_type);
```

**Benefits:**
- Quick identification of external users
- Easier reporting and analytics
- Simpler RLS policy logic
- Better user management

**Alternative (NO CHANGE):**
```sql
-- Can determine user type by checking organization_users table
-- If user exists in organization_users → External
-- If user NOT in organization_users → Internal

-- Example query:
SELECT u.*, 
  CASE 
    WHEN ou.org_user_id IS NOT NULL THEN 'EXTERNAL'
    ELSE 'INTERNAL'
  END as user_type
FROM users u
LEFT JOIN organization_users ou ON u.user_id = ou.user_id;
```

---

## RECOMMENDATION

### **Minimal Approach (No Changes):**
✅ **tenants table:** No changes  
✅ **users table:** No changes  
✅ Use `organization_users` table to identify external users

**Pros:**
- No schema changes to core tables
- Less risk
- Backward compatible

**Cons:**
- Slightly more complex queries
- Need JOIN to check if user is external

---

### **Recommended Approach (1 field):**
✅ **tenants table:** No changes  
⚠️ **users table:** Add `user_type` field

**Pros:**
- Clear user classification
- Simpler queries
- Better performance (no JOIN needed)
- Easier to understand

**Cons:**
- One schema change to core table
- Need to set user_type on user creation

---

## MIGRATION SQL (If adding user_type)

```sql
-- Add user_type field to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS user_type VARCHAR(20) DEFAULT 'INTERNAL';

-- Add constraint
ALTER TABLE users ADD CONSTRAINT IF NOT EXISTS users_user_type_check 
  CHECK (user_type IN ('INTERNAL', 'EXTERNAL'));

-- Add index
CREATE INDEX IF NOT EXISTS idx_users_type ON users(user_type);

-- Update existing external users (if any already exist in organization_users)
UPDATE users u
SET user_type = 'EXTERNAL'
WHERE EXISTS (
  SELECT 1 FROM organization_users ou 
  WHERE ou.user_id = u.user_id
);
```

---

## RLS POLICY COMPARISON

### Without user_type field:
```sql
-- Check if user is external by looking up organization_users
CREATE POLICY drawings_external_access ON drawings
  FOR SELECT
  USING (
    -- Internal users (NOT in organization_users)
    NOT EXISTS (
      SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid()
    )
    OR
    -- External users (in organization_users) with access
    (
      is_released = true
      AND EXISTS (
        SELECT 1 FROM organization_users ou
        JOIN resource_access ra ON ou.organization_id = ra.organization_id
        WHERE ou.user_id = auth.uid()
        ...
      )
    )
  );
```

### With user_type field:
```sql
-- Simpler check using user_type
CREATE POLICY drawings_external_access ON drawings
  FOR SELECT
  USING (
    -- Internal users
    (SELECT user_type FROM users WHERE user_id = auth.uid()) = 'INTERNAL'
    OR
    -- External users with access
    (
      (SELECT user_type FROM users WHERE user_id = auth.uid()) = 'EXTERNAL'
      AND is_released = true
      AND EXISTS (
        SELECT 1 FROM organization_users ou
        JOIN resource_access ra ON ou.organization_id = ra.organization_id
        WHERE ou.user_id = auth.uid()
        ...
      )
    )
  );
```

---

## FINAL RECOMMENDATION

### **For Phase 1: NO CHANGES to tenants or users tables**

**Rationale:**
1. Keep core tables stable
2. Use `organization_users` table to identify external users
3. Less risk, faster deployment
4. Can add `user_type` later if needed

**Implementation:**
```sql
-- Function to check if user is external
CREATE OR REPLACE FUNCTION is_external_user(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM organization_users 
    WHERE user_id = p_user_id 
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Use in RLS policies
CREATE POLICY drawings_external_access ON drawings
  FOR SELECT
  USING (
    NOT is_external_user(auth.uid())  -- Internal user
    OR
    (is_released = true AND ...)      -- External user with access
  );
```

---

## SUMMARY

| Table | Changes | Required | Recommended |
|-------|---------|----------|-------------|
| **tenants** | None | ❌ No | ❌ No |
| **users** | Add user_type field | ❌ No | ⚠️ Optional |

**Decision:** 
- ✅ **Phase 1:** No changes to tenants or users tables
- ⚠️ **Phase 2:** Consider adding user_type to users table for convenience

**Impact:** Zero changes to core tables in Phase 1 ✅

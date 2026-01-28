# Material Request Number Migration - Options & Recommendations

## Current Situation

**Old Format:** `MR-{timestamp}` (e.g., MR-1737912345678)
**New Format:** `MR{10-digit}` (e.g., MR5300000001)

## Migration Options

### Option 1: Keep Old Numbers, New System for New Records ✅ RECOMMENDED
**Approach:** Leave existing MRs unchanged, use number range only for new MRs

**Pros:**
- ✅ No data migration needed
- ✅ Zero risk to existing records
- ✅ Maintains audit trail integrity
- ✅ No impact on existing integrations/reports
- ✅ Simple implementation

**Cons:**
- ❌ Mixed number formats in system
- ❌ May confuse users initially

**Implementation:**
```sql
-- No changes needed to existing records
-- New MRs automatically use number range via updated API
```

**SAP Precedent:** SAP allows this - legacy numbers remain, new numbers follow current range

---

### Option 2: Renumber All Existing MRs
**Approach:** Assign new sequential numbers to all existing MRs

**Pros:**
- ✅ Consistent numbering across all records
- ✅ Clean system appearance

**Cons:**
- ❌ HIGH RISK - breaks references in related tables
- ❌ Audit trail concerns (number changes)
- ❌ Complex migration with rollback needed
- ❌ May break printed documents/external references
- ❌ Requires updating material_request_items FK references

**Implementation:**
```sql
-- NOT RECOMMENDED - Complex and risky
-- Would need to:
-- 1. Create mapping table (old_number → new_number)
-- 2. Update all FKs in related tables
-- 3. Update any external integrations
-- 4. Maintain mapping for historical lookups
```

**SAP Precedent:** SAP does NOT renumber historical documents

---

### Option 3: Hybrid - Add New Number, Keep Old as Reference
**Approach:** Add `legacy_request_number` field, assign new numbers

**Pros:**
- ✅ Consistent new numbering
- ✅ Preserves old numbers for reference
- ✅ Maintains audit trail

**Cons:**
- ❌ Schema change required
- ❌ Application code updates needed
- ❌ Still need to handle dual numbering in UI

**Implementation:**
```sql
-- Add legacy field
ALTER TABLE material_requests 
ADD COLUMN legacy_request_number VARCHAR(50);

-- Migrate
UPDATE material_requests 
SET legacy_request_number = request_number,
    request_number = 'MR' || LPAD((ROW_NUMBER() OVER (ORDER BY created_at))::TEXT, 10, '0')
WHERE request_number LIKE 'MR-%';

-- Update current_number in range
UPDATE document_number_ranges
SET current_number = (
    SELECT MAX(SUBSTRING(request_number FROM 3)::BIGINT)
    FROM material_requests
    WHERE request_number ~ '^MR[0-9]{10}$'
)::TEXT
WHERE document_type = 'MR';
```

---

### Option 4: Prefix-Based Separation
**Approach:** Use different prefix for old vs new (e.g., OLD-MR vs MR)

**Pros:**
- ✅ Clear visual distinction
- ✅ No renumbering needed

**Cons:**
- ❌ Requires retroactive prefix change
- ❌ Still mixed formats

---

## Recommendation: Option 1 (Keep Old, Use Range for New)

### Why This is Best:

1. **SAP Standard Practice**
   - SAP never renumbers historical documents
   - Legacy numbers remain valid indefinitely
   - New ranges apply only to new documents

2. **Zero Risk**
   - No data migration = no data loss risk
   - No FK constraint issues
   - No audit trail concerns

3. **Immediate Implementation**
   - Already done via API update
   - No database changes needed
   - Works immediately

4. **User Communication**
   ```
   "Material Request numbering has been standardized. 
   Existing MRs retain their original numbers (MR-xxxxx).
   New MRs will use the format MR5300000001, MR5300000002, etc."
   ```

### Implementation Checklist

- [x] Number range configured (MR: 5300000000-5399999999)
- [x] API updated to use get_next_number
- [ ] Update UI to show format info
- [ ] Add tooltip: "Format changed on [date]"
- [ ] Update reports to handle both formats
- [ ] Document in user guide

### Handling in Reports/Searches

```sql
-- Search works for both formats
SELECT * FROM material_requests 
WHERE request_number LIKE '%MR%' 
  AND (
    request_number = 'MR-1234567890' 
    OR request_number = 'MR5300000001'
  );

-- Sort chronologically (not by number)
ORDER BY created_at DESC;
```

### Future Considerations

**After 1-2 years:**
- Old format MRs will be archived/closed
- Active MRs will all be new format
- Can add UI filter: "Show legacy format" checkbox

**Data Retention:**
- Keep old numbers forever (audit requirement)
- No need to ever renumber

## Decision Matrix

| Criteria | Option 1 | Option 2 | Option 3 | Option 4 |
|----------|----------|----------|----------|----------|
| Risk Level | ✅ Low | ❌ High | ⚠️ Medium | ⚠️ Medium |
| Implementation Time | ✅ Done | ❌ Weeks | ⚠️ Days | ⚠️ Days |
| SAP Alignment | ✅ Yes | ❌ No | ⚠️ Partial | ❌ No |
| Audit Trail | ✅ Intact | ❌ Broken | ✅ Intact | ✅ Intact |
| User Impact | ✅ Minimal | ❌ High | ⚠️ Medium | ⚠️ Medium |

## Conclusion

**Proceed with Option 1** - Keep existing MR numbers unchanged, use number range for all new MRs going forward. This is the SAP-standard approach and carries zero risk.

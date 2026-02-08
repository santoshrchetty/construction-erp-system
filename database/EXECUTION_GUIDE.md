# Authorization Improvements: Execution Guide

## Quick Summary
Eliminate SAP codes (AD, CF, MM, PS, FI, etc.) and use friendly module names (admin, configuration, materials, projects, finance, etc.) throughout the system.

## Key Benefit
**Fixes HR Role Issue**: HR users currently see Materials + Procurement tiles because both map to "MM". After migration, HR will only see HR tiles.

## Pre-Execution Checklist
- [ ] Database backup completed
- [ ] No active users in system (or maintenance window scheduled)
- [ ] Supabase dashboard access ready
- [ ] Rollback script reviewed (step6_rollback_if_needed.sql)

---

## Execution Steps

### STEP 1: Backup Current State ✅
**File**: `database/step1_backup_tiles.sql`
**Duration**: ~1 minute
**Risk**: None (read-only + backup)

**Execute in Supabase SQL Editor:**
```sql
-- Run entire file: step1_backup_tiles.sql
```

**Expected Output:**
- Backup table created: `tiles_backup_sap_codes`
- Shows 89 tiles backed up
- Shows MM split: 14 Materials + 10 Procurement tiles

**Verification:**
```sql
SELECT COUNT(*) FROM tiles_backup_sap_codes;
-- Should return: 89
```

---

### STEP 2: Migrate Tiles Module Codes ⚠️
**File**: `database/step2_migrate_tiles_module_codes.sql`
**Duration**: ~1 minute
**Risk**: Low (reversible via rollback)

**Execute in Supabase SQL Editor:**
```sql
-- Run entire file: step2_migrate_tiles_module_codes.sql
```

**Expected Output:**
- 13 UPDATE statements executed (AD→admin, CF→configuration, etc.)
- MM split into materials (14 tiles) and procurement (10 tiles)
- Verification shows 0 SAP codes remaining
- Module count increases from 13 to 14 (MM split)

**Verification:**
```sql
-- Should return 0
SELECT COUNT(*) FROM tiles WHERE module_code = 'MM';

-- Should return 14
SELECT COUNT(*) FROM tiles WHERE module_code = 'materials';

-- Should return 10
SELECT COUNT(*) FROM tiles WHERE module_code = 'procurement';
```

---

### STEP 3: Simplify RPC Function ✅
**File**: `database/step3_simplify_rpc_function.sql`
**Duration**: ~30 seconds
**Risk**: Low (function replacement)

**Execute in Supabase SQL Editor:**
```sql
-- Run entire file: step3_simplify_rpc_function.sql
```

**Expected Output:**
- Old function dropped
- New simplified function created (no CASE mapping)
- Test query shows friendly module names
- Verification shows 0 SAP codes in output

**Verification:**
```sql
-- Should return friendly names (admin, finance, materials, etc.)
SELECT * FROM get_user_modules('<admin-user-id>'::uuid);
```

---

### STEP 4: Frontend Code Review 📋
**File**: `database/step4_frontend_checklist.md`
**Duration**: 30-60 minutes
**Risk**: Medium (requires code changes)

**Actions:**
1. Search for hardcoded SAP codes in TypeScript files
2. Replace with friendly module names
3. Pay special attention to 'MM' → decide 'materials' or 'procurement'
4. Run TypeScript compilation: `npm run build`
5. Test in browser

**Search Command (PowerShell):**
```powershell
Get-ChildItem -Path . -Include *.ts,*.tsx -Recurse | Select-String -Pattern "'(AD|CF|MM|PS|FI|HR)'" | Select-Object Path, LineNumber, Line
```

**Common Replacements:**
- `module_code === 'MM'` → `module_code === 'materials'`
- `module_code === 'PS'` → `module_code === 'projects'`
- `module_code === 'FI'` → `module_code === 'finance'`

---

### STEP 5: Test Authorization Flow ✅
**File**: `database/step5_test_authorization.sql`
**Duration**: ~5 minutes
**Risk**: None (read-only + optional HR fix)

**Execute in Supabase SQL Editor:**
```sql
-- Run entire file: step5_test_authorization.sql
```

**Expected Output:**
- HR role cleaned up (materials module removed)
- HR user (emy@prom.com) only sees HR tiles
- Admin user sees all authorized modules
- Engineer/PlanEng users see correct modules
- Summary report shows migration success

**Key Tests:**
```sql
-- HR user should only see 'hr' module
SELECT * FROM get_user_modules((SELECT id FROM users WHERE email = 'emy@prom.com'));

-- Should return only HR category tiles
SELECT title, module_code FROM tiles 
WHERE module_code IN (SELECT * FROM get_user_modules((SELECT id FROM users WHERE email = 'emy@prom.com')));
```

---

### STEP 6: Final Verification ✅
**File**: `database/step6_verify_and_cleanup.sql`
**Duration**: ~2 minutes
**Risk**: None (read-only + optional cleanup)

**Execute in Supabase SQL Editor:**
```sql
-- Run entire file: step6_verify_and_cleanup.sql
```

**Expected Output:**
- ✓ PASS - No SAP codes in tiles
- ✓ PASS - All tiles have friendly names
- ✓ PASS - MM successfully split
- ✓ PASS - RPC returns friendly names
- ✓ PASS - Module consistency verified

**Optional Cleanup (after 1 week of testing):**
```sql
DROP TABLE IF EXISTS tiles_backup_sap_codes;
```

---

## Rollback Procedure (Emergency Only)

**File**: `database/step6_rollback_if_needed.sql`

**When to use:**
- Migration causes unexpected issues
- Frontend breaks due to hardcoded SAP codes
- Need to revert to original state

**Execute:**
```sql
-- Run entire file: step6_rollback_if_needed.sql
```

**Result:**
- Tiles restored to SAP codes
- RPC function restored with CASE mapping
- HR role restored to original state (sees materials)

---

## Success Criteria

### Database
- [ ] No SAP codes in `tiles.module_code`
- [ ] MM split into `materials` (14) and `procurement` (10)
- [ ] `get_user_modules()` returns friendly names
- [ ] All verification checks pass

### Application
- [ ] TypeScript compiles without errors
- [ ] Users can login successfully
- [ ] Tiles display correctly for all roles
- [ ] HR user only sees HR tiles (not materials/procurement)
- [ ] No console errors in browser

### Authorization
- [ ] Admin sees all authorized modules
- [ ] Engineer sees correct modules
- [ ] PlanEng sees projects, materials, procurement
- [ ] HR sees only HR module

---

## Timeline

| Step | Duration | Can Run Concurrently |
|------|----------|---------------------|
| Step 1: Backup | 1 min | No |
| Step 2: Migrate Tiles | 1 min | No |
| Step 3: Simplify RPC | 30 sec | No |
| Step 4: Frontend | 30-60 min | After Step 3 |
| Step 5: Test | 5 min | After Step 4 |
| Step 6: Verify | 2 min | After Step 5 |
| **Total** | **40-70 min** | |

---

## Post-Migration Monitoring

### Day 1
- [ ] Monitor application logs for errors
- [ ] Check user feedback on tile visibility
- [ ] Verify authorization checks work correctly

### Week 1
- [ ] Confirm no issues reported
- [ ] Verify all roles see correct tiles
- [ ] Test with different user types

### After Week 1
- [ ] Drop backup table if all is well
- [ ] Update documentation
- [ ] Close migration ticket

---

## Support

**If issues occur:**
1. Check browser console for errors
2. Verify database queries in Supabase logs
3. Run verification queries from Step 6
4. If critical: Execute rollback script
5. Review frontend code for hardcoded SAP codes

**Common Issues:**
- **Tiles not showing**: Check `get_user_modules()` output
- **Wrong tiles visible**: Verify role assignments
- **TypeScript errors**: Search for hardcoded SAP codes
- **Authorization fails**: Check module names match exactly

---

## Files Created

1. ✅ `migration_eliminate_sap_codes.md` - Overall plan
2. ✅ `step1_backup_tiles.sql` - Backup script
3. ✅ `step2_migrate_tiles_module_codes.sql` - Migration script
4. ✅ `step3_simplify_rpc_function.sql` - RPC update
5. ✅ `step4_frontend_checklist.md` - Frontend guide
6. ✅ `step5_test_authorization.sql` - Testing script
7. ✅ `step6_verify_and_cleanup.sql` - Verification script
8. ✅ `step6_rollback_if_needed.sql` - Rollback script
9. ✅ `EXECUTION_GUIDE.md` - This file

---

## Ready to Execute?

**Start with Step 1:**
```sql
-- Open Supabase SQL Editor
-- Copy and paste: database/step1_backup_tiles.sql
-- Click "Run"
```

**Then proceed through Steps 2-6 in order.**

Good luck! 🚀

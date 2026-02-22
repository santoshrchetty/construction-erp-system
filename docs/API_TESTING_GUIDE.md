# External Access API Testing Guide

## Quick Start

### Option 1: Browser Test (Easiest)
1. Start your Next.js dev server:
   ```bash
   npm run dev
   ```

2. Open in browser:
   ```
   http://localhost:3000/test_external_access_api.html
   ```

3. Click "Run All Tests" button

---

### Option 2: Windows Command Line
1. Start dev server:
   ```bash
   npm run dev
   ```

2. Run test script:
   ```bash
   test_api.bat
   ```

---

### Option 3: Manual curl Tests

**Test 1: List Organizations**
```bash
curl "http://localhost:3000/api/external-access?action=list-organizations"
```

**Test 2: List Drawings**
```bash
curl "http://localhost:3000/api/external-access?action=list-drawings"
```

**Test 3: List Facilities**
```bash
curl "http://localhost:3000/api/external-access?action=list-facilities"
```

**Test 4: List Equipment**
```bash
curl "http://localhost:3000/api/external-access?action=list-equipment"
```

**Test 5: List Resource Access**
```bash
curl "http://localhost:3000/api/external-access?action=list-resource-access"
```

**Test 6: Create Organization**
```bash
curl -X POST "http://localhost:3000/api/external-access?action=create-organization" ^
  -H "Content-Type: application/json" ^
  -d "{\"tenant_id\":\"YOUR_TENANT_ID\",\"name\":\"Test Contractor\",\"org_type\":\"CONTRACTOR\",\"is_internal\":false}"
```

**Test 7: Grant Access**
```bash
curl -X POST "http://localhost:3000/api/external-access?action=grant-access" ^
  -H "Content-Type: application/json" ^
  -d "{\"tenant_id\":\"YOUR_TENANT_ID\",\"external_org_id\":\"ORG_ID\",\"resource_type\":\"DRAWING\",\"resource_id\":\"DRAWING_ID\",\"access_level\":\"VIEW\",\"granted_by\":\"USER_ID\"}"
```

---

### Option 4: Database Direct Test

Run SQL test in your database client (pgAdmin, DBeaver, etc.):
```sql
-- Open: database/test_external_access_api.sql
-- Execute all queries
```

---

## Expected Results

### Successful Response
```json
{
  "success": true,
  "data": [...]
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message"
}
```

---

## Troubleshooting

### Issue: "Action required" error
- Make sure you include `?action=` parameter in URL

### Issue: Empty data arrays
- Run sample data script first: `database/external_access_sample_data.sql`

### Issue: 500 errors
- Check Next.js console for detailed error messages
- Verify database connection in `.env.local`

### Issue: RLS blocking queries
- Ensure `app.current_user_id` session variable is set
- Check user has proper organization membership

---

## Test Files Created

1. **test_external_access_api.html** - Browser-based visual tester
2. **test_api.bat** - Windows batch script
3. **test_api.sh** - Linux/Mac bash script
4. **test_external_access_api.js** - Node.js test suite
5. **database/test_external_access_api.sql** - Database layer tests

---

## Next Steps After Testing

1. ✅ Verify all endpoints return data
2. ✅ Check RLS policies work (external users see only RELEASED)
3. ✅ Test access control (users see only their org's resources)
4. 🔄 Build frontend UI components
5. 🔄 Implement user invitation system
6. 🔄 Add file upload for drawings

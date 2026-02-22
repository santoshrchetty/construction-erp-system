# Document Governance Testing Guide

## Test Steps

### 1. Database Setup (Supabase SQL Editor)

Run these scripts in order:

```sql
-- Step 1: Run test data script
-- File: database/test_document_governance.sql
-- Expected: 5 drawings, 4 contracts, 5 RFIs, 3 specs, 3 submittals, 3 change orders, 4 master docs
```

### 2. API Testing

**Option A: Browser Testing**
- Start dev server: `npm run dev`
- Open browser console (F12)
- Test endpoints:

```javascript
// Test Drawings
fetch('/api/document-governance?resource=drawings')
  .then(r => r.json())
  .then(d => console.log('Drawings:', d));

// Test Contracts
fetch('/api/document-governance?resource=contracts')
  .then(r => r.json())
  .then(d => console.log('Contracts:', d));

// Test RFIs
fetch('/api/document-governance?resource=rfis')
  .then(r => r.json())
  .then(d => console.log('RFIs:', d));
```

**Option B: Node Script**
```bash
node database/test_api.js
```

### 3. Frontend Testing

1. Start dev server: `npm run dev`
2. Navigate to Document Governance tiles
3. Test each component:

**Drawing Management**
- ✅ Displays 5 drawings
- ✅ Search works
- ✅ Filter by discipline works
- ✅ Shows correct columns: Number, Title, Revision, Discipline, Status

**Contract Management**
- ✅ Displays 4 contracts
- ✅ Search works
- ✅ Filter by status works
- ✅ Shows correct columns: Number, Title, Vendor, Value, Status

**RFI Management**
- ✅ Displays 5 RFIs
- ✅ Search works
- ✅ Filter by status works
- ✅ Priority badges display correctly
- ✅ Shows correct columns: Number, Subject, Priority, Status, Due Date

### 4. Expected Results

**Database:**
- ✅ 7 tables populated with test data
- ✅ Total ~27 records across all tables

**API:**
- ✅ All 7 endpoints return 200 OK
- ✅ Data matches database records
- ✅ Tenant isolation working

**Frontend:**
- ✅ All 3 components load without errors
- ✅ Data displays correctly
- ✅ Search and filters functional
- ✅ Loading states work

## Quick Verification Queries

```sql
-- Count all records
SELECT 
  'Drawings' as table_name, COUNT(*) FROM drawings
UNION ALL SELECT 'Contracts', COUNT(*) FROM contracts
UNION ALL SELECT 'RFIs', COUNT(*) FROM rfis
UNION ALL SELECT 'Specifications', COUNT(*) FROM specifications
UNION ALL SELECT 'Submittals', COUNT(*) FROM submittals
UNION ALL SELECT 'Change Orders', COUNT(*) FROM change_orders
UNION ALL SELECT 'Master Data', COUNT(*) FROM master_data_documents;

-- View sample data
SELECT drawing_number, title, discipline, status FROM drawings LIMIT 3;
SELECT contract_number, title, vendor_name, status FROM contracts LIMIT 3;
SELECT rfi_number, subject, priority, status FROM rfis LIMIT 3;
```

## Troubleshooting

**No data showing:**
- Check tenant_id matches in database
- Verify API returns data in browser network tab
- Check console for errors

**API errors:**
- Verify Supabase connection in .env.local
- Check service role key is set
- Verify tables exist in database

**Component errors:**
- Check browser console for errors
- Verify component is imported in EnhancedConstructionTiles.tsx
- Check API endpoint URLs are correct

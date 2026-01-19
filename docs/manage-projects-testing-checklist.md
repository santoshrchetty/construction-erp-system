# Manage Projects Tile - Testing Checklist

## ✅ Completed
- [x] Database migration: `companies.company_name` → `grpcompany_name`
- [x] SQL files updated to use `grpcompany_name`
- [x] UI updated: Projects List table shows "Project Code" and "Company Code"
- [x] Form labels: "Project Code" and "Company Code"
- [x] All changes committed and pushed to GitHub

## 🧪 Testing Required

### 1. Database Verification
Run in Supabase SQL Editor:
```sql
-- Verify companies table structure
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'companies';
-- Should show: grpcompany_name (not company_name)

-- Verify company relationships
SELECT 
    cc.company_code,
    cc.company_name,
    c.grpcompany_name as parent_company
FROM company_codes cc
LEFT JOIN companies c ON cc.company_id = c.company_id
WHERE cc.is_active = true
ORDER BY cc.company_code;
```

### 2. Application Testing

#### Test 1: View Projects List
- [ ] Navigate to `/erp-modules`
- [ ] Click "Manage Projects" tile
- [ ] Verify "Projects List" tab shows:
  - [ ] Project Code column
  - [ ] Company Code column (showing CC001, B001, etc.)
  - [ ] Name column
  - [ ] Type, Status, Budget columns
  - [ ] Actions (Edit/Delete buttons)

#### Test 2: Create New Project
- [ ] Click "Create Project" tab
- [ ] Verify form shows:
  - [ ] "Project Code *" field
  - [ ] "Company Code *" dropdown
  - [ ] Dropdown shows format: "CC001 - ABC Construction Ltd"
- [ ] Fill in all required fields
- [ ] Click "Create" button
- [ ] Verify success message
- [ ] Check project appears in Projects List

#### Test 3: Edit Project
- [ ] Click Edit button on a project
- [ ] Verify form pre-fills with project data
- [ ] Verify Company Code dropdown shows correct value
- [ ] Modify a field
- [ ] Click "Update" button
- [ ] Verify success message
- [ ] Check changes appear in Projects List

#### Test 4: Delete Project
- [ ] Click Delete button on a project
- [ ] Verify confirmation dialog
- [ ] Confirm deletion
- [ ] Verify project removed from list

### 3. API Testing

Test the API endpoints:
```bash
# List projects
POST /api/tiles
Body: { "category": "projects", "action": "list" }

# Create project
POST /api/tiles
Body: { 
  "category": "projects", 
  "action": "create",
  "payload": {
    "code": "TEST001",
    "name": "Test Project",
    "company_code": "C001",
    "project_type": "commercial",
    "status": "planning",
    "start_date": "2024-01-01",
    "planned_end_date": "2024-12-31",
    "budget": 100000
  }
}
```

## 🐛 Known Issues to Check
- [ ] Company Code column displays correctly (not empty)
- [ ] Company dropdown loads all active companies
- [ ] Foreign key relationship works (company_code_id)
- [ ] No console errors in browser
- [ ] No SQL errors in Supabase logs

## 📝 Next Features (Future)
- [ ] Add company name tooltip on hover
- [ ] Add filter by company code
- [ ] Add search functionality
- [ ] Add pagination for large project lists
- [ ] Add export to Excel functionality

---

**Status**: Ready for testing
**Last Updated**: After grpcompany_name migration

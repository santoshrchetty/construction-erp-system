# CEMENT-OPC-83 Material Test - Maintain Material Master Tile

## Pre-Test Setup
1. **Run Database Setup**: Execute `test_cement_opc_83.sql` to ensure CEMENT-OPC-83 exists
2. **Verify Material Exists**: Confirm the material is created with proper data
3. **Open Application**: Navigate to Construction Management System

## Test Steps for CEMENT-OPC-83

### Step 1: Access Maintain Material Master Tile
- [ ] Click on "Materials" category filter
- [ ] Locate "Maintain Material Master" tile
- [ ] Click the tile to open

### Step 2: Direct Material Code Search
- [ ] In "Direct Material Code Search" section
- [ ] Enter: `CEMENT-OPC-83`
- [ ] Click "Search & Load" button

### Expected Result:
```
✅ Material loads successfully with data:
- Material Code: CEMENT-OPC-83 (disabled/read-only)
- Material Name: Ordinary Portland Cement 53 Grade Premium
- Description: High strength premium cement for heavy construction projects
- Category: CEMENT
- Material Group: OPC (Ordinary Portland Cement)
- Base UOM: BAG
- Material Type: FERT
- Weight Unit: KG
- Gross Weight: 50.5
- Net Weight: 50.0
- Volume Unit: CUM
- Volume: 0.035
```

### Step 3: Verify Form Sections
- [ ] **Basic Information** section populated
- [ ] **Classification** section shows category and group
- [ ] **Units of Measure** section shows UOM, weight unit, volume unit
- [ ] **Physical Properties** section shows weights and volume
- [ ] Material Code field is **disabled** (cannot be modified)

### Step 4: Test Modification (MM02 Behavior)
- [ ] Modify Material Name to: `CEMENT-OPC-83 Modified Test`
- [ ] Update Description to: `Modified via MM02 maintenance - Test`
- [ ] Change Gross Weight to: `51.0`
- [ ] Change Net Weight to: `50.5`
- [ ] Click "Update Material"

### Expected Result:
```
✅ Success message: "Material updated successfully!"
✅ Form refreshes with updated data
✅ Changes are saved to database
✅ Material Code remains unchanged (CEMENT-OPC-83)
```

### Step 5: Verify Modifications Persisted
- [ ] Click "Clear Form"
- [ ] Search for `CEMENT-OPC-83` again
- [ ] Click "Search & Load"

### Expected Result:
```
✅ Material loads with modified data:
- Material Name: CEMENT-OPC-83 Modified Test
- Description: Modified via MM02 maintenance - Test
- Gross Weight: 51.0
- Net Weight: 50.5
- All other fields unchanged
```

### Step 6: Test Parameter-Based Search
- [ ] Click "Clear Form"
- [ ] In "Search by Parameters" section:
  - Material Name: `cement`
  - Category: Leave blank
  - Material Type: Leave blank
- [ ] Click "Find Materials"

### Expected Result:
```
✅ Search results modal opens
✅ Shows CEMENT-OPC-83 in results list
✅ Modal displays: Code, Name, Category, Type columns
✅ CEMENT-OPC-83 row shows "Select" button
```

### Step 7: Test Material Selection from Search
- [ ] In search results modal, find CEMENT-OPC-83 row
- [ ] Click "Select" button for CEMENT-OPC-83

### Expected Result:
```
✅ Modal closes automatically
✅ Form populates with CEMENT-OPC-83 data
✅ All sections filled with current material data
✅ Ready for modification
```

### Step 8: Test Category-Based Search
- [ ] Click "Clear Form"
- [ ] In "Search by Parameters":
  - Material Name: Leave blank
  - Category: Select "Cement Products"
  - Material Type: Leave blank
- [ ] Click "Find Materials"

### Expected Result:
```
✅ Search results show only cement materials
✅ CEMENT-OPC-83 appears in filtered results
✅ No steel or other category materials shown
```

### Step 9: Test Field Restrictions (MM02 Compliance)
- [ ] Load CEMENT-OPC-83 material
- [ ] Try to modify Material Code field

### Expected Result:
```
✅ Material Code field is disabled/read-only
✅ Cannot change CEMENT-OPC-83 to different code
✅ Other fields remain editable
```

### Step 10: Test Error Handling
- [ ] Click "Clear Form"
- [ ] Enter invalid code: `CEMENT-INVALID-999`
- [ ] Click "Search & Load"

### Expected Result:
```
✅ "Material not found" message appears
✅ Form remains empty
✅ No errors in browser console
```

## Test Results Summary

### ✅ PASSED Tests:
- [ ] Material loads successfully
- [ ] Form populates correctly
- [ ] Modifications save properly
- [ ] Search functionality works
- [ ] Field restrictions enforced
- [ ] Error handling works

### ❌ FAILED Tests:
- [ ] Issue 1: ________________
- [ ] Issue 2: ________________
- [ ] Issue 3: ________________

## Notes:
- Material Code: CEMENT-OPC-83
- Test Date: ________________
- Tester: ________________
- Browser: ________________
- Issues Found: ________________
# Quick Test: CEMENT-OPC-83 (Existing Material)

## Test Steps:

### 1. Open Maintain Material Master Tile
- Navigate to Materials category
- Click "Maintain Material Master" tile

### 2. Search for Existing Material
- Enter: `CEMENT-OPC-83` in Direct Material Code Search
- Click "Search & Load"

### Expected Result:
- [ ] ✅ Material loads successfully
- [ ] ✅ Form populates with existing data
- [ ] ✅ Material Code field is disabled
- [ ] ✅ Other fields are editable

### 3. Test Modification
- Modify Material Name (add "- Test Modified")
- Click "Update Material"

### Expected Result:
- [ ] ✅ Success message appears
- [ ] ✅ Changes are saved

### 4. Verify Changes Persist
- Clear form and search CEMENT-OPC-83 again
- Check if modifications were saved

### Result:
- [ ] ✅ PASSED - Material maintenance works
- [ ] ❌ FAILED - Issue: ________________
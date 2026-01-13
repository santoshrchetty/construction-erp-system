# Maintain Material Master Tile - Test Checklist (MM02 Style - Modification Only)

## Pre-Test Setup
- [ ] Run `test_maintain_material_master.sql` to ensure existing materials exist
- [ ] Verify user has MM_MAINTAIN authorization object
- [ ] Confirm materials exist for modification (not creation)

## Test 1: Direct Material Code Search (Existing Material)
### Steps:
1. Open Maintain Material Master tile
2. Enter existing material code "TEST-CEMENT-001" in Direct Material Code Search
3. Click "Search & Load"

### Expected Results:
- [ ] Existing material loads successfully
- [ ] Form populates with current material data
- [ ] Material Code field is **disabled** (cannot be changed)
- [ ] All other fields are **editable** for modification
- [ ] Category and other master data fields are populated

## Test 2: Parameter-Based Search (Find Existing Materials)
### Steps:
1. Clear form
2. In "Search by Parameters" section:
   - Material Name: "cement"
   - Category: Leave blank
   - Material Type: Leave blank
3. Click "Find Materials"

### Expected Results:
- [ ] Search results modal shows **existing materials only**
- [ ] Results contain materials that can be modified
- [ ] Modal shows: Code, Name, Category, Type columns
- [ ] Each row has "Select" button to load for modification

## Test 3: Material Selection for Modification
### Steps:
1. From search results modal, click "Select" on any existing material
2. Modal should close and form should populate for modification

### Expected Results:
- [ ] Modal closes automatically
- [ ] Form populates with **existing material data**
- [ ] Material Code is **read-only/disabled**
- [ ] All modification fields are enabled
- [ ] Form is in "modification mode" not "creation mode"

## Test 4: Modify Material Data (Core MM02 Functionality)
### Steps:
1. Load existing material TEST-CEMENT-001
2. Modify **editable fields only**:
   - Material Name: "Modified Test Cement Name"
   - Description: "Updated description via MM02"
   - Physical Properties: Update weights/volume
3. **DO NOT** modify:
   - Material Code (should be disabled)
   - Category (may be restricted in some implementations)
   - Base UOM (may be restricted)
4. Click "Update Material"

### Expected Results:
- [ ] Only **allowed modifications** are saved
- [ ] Success message: "Material updated successfully"
- [ ] Form refreshes with updated data
- [ ] **No new material created** - existing material modified
- [ ] Audit trail updated (updated_by, updated_at)

## Test 5: Field Modification Restrictions (MM02 Behavior)
### Steps:
1. Load existing material
2. Attempt to modify restricted fields:
   - Material Code (should be disabled)
   - Category (may be restricted if material has transactions)
   - Base UOM (may be restricted if material has stock)

### Expected Results:
- [ ] Material Code field is **completely disabled**
- [ ] Restricted fields show appropriate behavior (disabled/warning)
- [ ] Only **safe-to-modify** fields are editable
- [ ] System prevents dangerous modifications

## Test 6: Modification Validation
### Steps:
1. Load existing material
2. Clear required fields (Material Name)
3. Try to save modifications

### Expected Results:
- [ ] Validation prevents saving incomplete data
- [ ] Required field validation works
- [ ] **No partial updates** - maintains data integrity

## Test 7: Non-Existent Material Handling
### Steps:
1. Enter non-existent material code "INVALID-999"
2. Click "Search & Load"

### Expected Results:
- [ ] "Material not found" message
- [ ] Form remains empty
- [ ] **No option to create new material** (this is maintenance only)
- [ ] Clear guidance that material must exist first

## Test 8: Modification History/Audit
### Steps:
1. Load and modify existing material
2. Save changes
3. Reload same material

### Expected Results:
- [ ] Modified data is preserved
- [ ] Audit fields updated (updated_by, updated_at)
- [ ] **No duplicate materials created**
- [ ] Modification history maintained

## Test 9: Category-Dependent Field Updates
### Steps:
1. Load material with existing category
2. Change category (if allowed)
3. Observe dependent fields (material groups)

### Expected Results:
- [ ] Dependent dropdowns update based on new category
- [ ] Previous selections cleared appropriately
- [ ] **Existing material structure maintained**

## Test 10: Clear Form (Return to Search Mode)
### Steps:
1. Load material for modification
2. Click "Clear Form"

### Expected Results:
- [ ] Form returns to **search mode**
- [ ] All fields cleared
- [ ] Ready to search for another material to modify
- [ ] **No material creation options visible**

## MM02 Compliance Verification
- [ ] **Modification Only**: No material creation functionality
- [ ] **Existing Materials**: Only works with pre-existing materials
- [ ] **Field Restrictions**: Critical fields (code, category, UOM) properly restricted
- [ ] **Data Integrity**: Modifications don't break existing relationships
- [ ] **Audit Trail**: All changes tracked with user and timestamp
- [ ] **Search First**: Must find/select material before modification
- [ ] **Validation**: Prevents invalid modifications

## Notes Section
Record any issues found:
- Issue 1: 
- Issue 2:
- Issue 3:

## Test Completion
- [ ] All MM02-style modification tests passed
- [ ] No material creation functionality present
- [ ] Only existing materials can be modified
- [ ] Field restrictions work correctly
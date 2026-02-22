# Component Migration Checklist

## Purpose
Step-by-step guide to refactor existing large components into Fiori architecture pattern.

---

## Pre-Migration Analysis

### Step 1: Measure Current Component
```bash
# Count lines in current file
wc -l {Component}.tsx

# Target: Reduce to < 150 lines in main file
```

**Record:**
- Current lines: _______
- Target lines: 120-150
- Reduction needed: _______%

### Step 2: Identify Sections
Review the component and identify logical sections:

- [ ] Header/Overview section
- [ ] General information section
- [ ] Organizational data section
- [ ] Project/Assignment section
- [ ] Items/Line items section
- [ ] Additional sections: _________________

**Count:** _____ sections identified

### Step 3: Identify Business Logic
List all data loading and action functions:

**Data Loading:**
- [ ] Load master data (companies, plants, etc.)
- [ ] Load dependent data (based on selections)
- [ ] Search/lookup functions
- [ ] Other: _________________

**Actions:**
- [ ] Save/Save draft
- [ ] Submit/Approve
- [ ] Preview/Print
- [ ] Delete/Cancel
- [ ] Other: _________________

### Step 4: Identify Reusable Components
List components that could be reused elsewhere:

- [ ] Search/lookup dialogs
- [ ] Account assignment fields
- [ ] Address forms
- [ ] Date pickers
- [ ] Other: _________________

---

## Migration Steps

### Phase 1: Create Custom Hooks (Day 1 - 2 hours)

#### 1.1 Create Data Hook
```bash
# Create file
touch hooks/use{Entity}FormData.ts
```

**Tasks:**
- [ ] Copy all state declarations
- [ ] Copy all useEffect hooks
- [ ] Copy all data loading functions
- [ ] Create updateField function
- [ ] Create updateItem function
- [ ] Create addItem function
- [ ] Create removeItem function
- [ ] Return clean interface
- [ ] Test hook independently

**Target:** 150-250 lines

#### 1.2 Create Actions Hook
```bash
# Create file
touch hooks/use{Entity}Actions.ts
```

**Tasks:**
- [ ] Copy save function
- [ ] Copy submit function
- [ ] Copy preview function
- [ ] Copy delete function
- [ ] Add loading states
- [ ] Add error handling
- [ ] Return clean interface
- [ ] Test hook independently

**Target:** 60-100 lines

#### 1.3 Create Validation Hook (Optional)
```bash
# Create file
touch hooks/use{Entity}Validation.ts
```

**Tasks:**
- [ ] Copy validation logic
- [ ] Create validate function
- [ ] Return validation results
- [ ] Test hook independently

**Target:** 60-100 lines

---

### Phase 2: Create Section Components (Day 1 - 3 hours)

#### 2.1 Create sections/ Directory
```bash
mkdir sections
```

#### 2.2 Create Each Section Component

**For each section:**

```bash
# Create file
touch sections/{Entity}{Section}Section.tsx
```

**Tasks per section:**
- [ ] Define props interface
- [ ] Copy relevant JSX from main file
- [ ] Replace state with props
- [ ] Replace setState with onChange callback
- [ ] Add readOnly support
- [ ] Test section independently

**Target:** 60-100 lines per section

**Sections to create:**
1. [ ] HeaderSection (60-80 lines)
2. [ ] GeneralSection (60-100 lines)
3. [ ] OrganizationalSection (80-100 lines)
4. [ ] ProjectSection (80-100 lines)
5. [ ] ItemsSection (150-200 lines)

---

### Phase 3: Create Reusable Components (Day 2 - 2 hours)

#### 3.1 Create components/ Directory
```bash
mkdir components
```

#### 3.2 Create Reusable Components

**For each reusable component:**

```bash
# Create file
touch components/{Component}.tsx
```

**Tasks per component:**
- [ ] Define props interface
- [ ] Extract component logic
- [ ] Make it generic/reusable
- [ ] Add proper prop validation
- [ ] Test component independently

**Target:** 60-100 lines per component

**Components to create:**
1. [ ] ItemRow (80-120 lines)
2. [ ] SearchDialog (80-120 lines)
3. [ ] AccountAssignmentFields (80-120 lines)
4. [ ] Other: _________________ (60-100 lines)

---

### Phase 4: Create Dialogs (Day 2 - 1 hour)

#### 4.1 Create dialogs/ Directory
```bash
mkdir dialogs
```

#### 4.2 Create Dialog Components

```bash
# Create files
touch dialogs/{Entity}PreviewDialog.tsx
touch dialogs/{Search}ValueHelp.tsx
```

**Tasks per dialog:**
- [ ] Define props interface
- [ ] Extract dialog logic
- [ ] Add open/close handling
- [ ] Test dialog independently

**Target:** 80-120 lines per dialog

---

### Phase 5: Refactor Main Component (Day 2 - 2 hours)

#### 5.1 Update Main File

**Tasks:**
- [ ] Import custom hooks
- [ ] Import section components
- [ ] Remove all business logic
- [ ] Remove all data loading
- [ ] Remove all action handlers
- [ ] Keep only UI state (expanded sections, dialogs)
- [ ] Use hooks for data and actions
- [ ] Pass data to sections via props
- [ ] Implement ObjectPage layout
- [ ] Add collapsible sections
- [ ] Add sticky header
- [ ] Add sticky footer

**Target:** 120-150 lines

#### 5.2 Main Component Structure

```typescript
export default function {Entity}ObjectPage() {
  // 1. Hooks (5-10 lines)
  const { formData, masterData, updateField, updateItem } = use{Entity}FormData()
  const { save, submit, preview } = use{Entity}Actions(formData)
  
  // 2. UI State (5-10 lines)
  const [expandedSections, setExpandedSections] = useState({...})
  const [showPreview, setShowPreview] = useState(false)
  
  // 3. Render (80-100 lines)
  return (
    <ObjectPageLayout>
      <ObjectPageHeader />
      <ObjectPageContent>
        {/* Sections */}
      </ObjectPageContent>
      <ObjectPageFooter />
    </ObjectPageLayout>
  )
}
```

---

### Phase 6: Testing (Day 3 - 2 hours)

#### 6.1 Unit Tests

**Test each piece:**
- [ ] Test data hook
- [ ] Test actions hook
- [ ] Test each section component
- [ ] Test reusable components
- [ ] Test dialogs
- [ ] Test main component

#### 6.2 Integration Tests

**Test full flow:**
- [ ] Load form
- [ ] Fill all fields
- [ ] Add items
- [ ] Save draft
- [ ] Submit
- [ ] Preview
- [ ] Error handling

#### 6.3 Manual Testing

**Test UI:**
- [ ] All sections render correctly
- [ ] Collapsible sections work
- [ ] Data loads correctly
- [ ] Dependent dropdowns work
- [ ] Validation works
- [ ] Save works
- [ ] Submit works
- [ ] Preview works

---

### Phase 7: Cleanup (Day 3 - 1 hour)

#### 7.1 Remove Old Code

**Tasks:**
- [ ] Backup old component file
- [ ] Delete old component file (after verification)
- [ ] Update imports in parent components
- [ ] Update routes if needed
- [ ] Remove unused dependencies

#### 7.2 Documentation

**Tasks:**
- [ ] Update component documentation
- [ ] Add JSDoc comments
- [ ] Update README if needed
- [ ] Document any breaking changes

---

## Post-Migration Verification

### Quality Metrics

**Line Count:**
- [ ] Main file < 150 lines? ✅
- [ ] Sections < 100 lines? ✅
- [ ] Hooks < 250 lines? ✅
- [ ] Total files: 8-15? ✅

**Code Quality:**
- [ ] No business logic in UI components? ✅
- [ ] All data loading in hooks? ✅
- [ ] All actions in hooks? ✅
- [ ] Props interfaces defined? ✅
- [ ] Error handling in place? ✅

**Functionality:**
- [ ] All features working? ✅
- [ ] No regressions? ✅
- [ ] Performance same or better? ✅
- [ ] Tests passing? ✅

### Performance Check

**Before:**
- Component size: _______ lines
- Re-render count: _______
- Load time: _______ ms

**After:**
- Main file size: _______ lines (target: < 150)
- Re-render count: _______ (should be lower)
- Load time: _______ ms (should be same or better)

---

## Migration Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| Pre-Analysis | 30 min | Identify sections, logic, components |
| Phase 1: Hooks | 2 hours | Create custom hooks |
| Phase 2: Sections | 3 hours | Create section components |
| Phase 3: Components | 2 hours | Create reusable components |
| Phase 4: Dialogs | 1 hour | Create dialog components |
| Phase 5: Main File | 2 hours | Refactor main component |
| Phase 6: Testing | 2 hours | Test everything |
| Phase 7: Cleanup | 1 hour | Remove old code, document |
| **Total** | **13-14 hours** | **~2 days** |

---

## Rollback Plan

If migration fails or causes issues:

1. **Immediate Rollback:**
   ```bash
   # Restore backup
   git checkout HEAD -- {Component}.tsx
   ```

2. **Partial Rollback:**
   - Keep new hooks (they're independent)
   - Revert main component changes
   - Fix issues incrementally

3. **Prevention:**
   - Test thoroughly before deploying
   - Keep old file until fully verified
   - Deploy to staging first

---

## Success Criteria

Migration is successful when:

- ✅ Main file reduced to < 150 lines (90% reduction)
- ✅ All functionality works as before
- ✅ No performance degradation
- ✅ All tests passing
- ✅ Code is more maintainable
- ✅ Components are reusable
- ✅ Team approves changes

---

## Example: Material Request Migration

### Before
```
UnifiedMaterialRequestComponent.tsx (1,161 lines)
```

### After
```
MaterialRequestObjectPage.tsx (120 lines)
├── sections/
│   ├── MRTypeSection.tsx (60 lines)
│   ├── OrganizationalSection.tsx (100 lines)
│   ├── ProjectSection.tsx (90 lines)
│   └── ItemsSection.tsx (180 lines)
├── components/
│   ├── ItemRow.tsx (120 lines)
│   └── AccountAssignmentFields.tsx (100 lines)
├── hooks/
│   ├── useMRFormData.ts (200 lines)
│   └── useMRActions.ts (80 lines)
└── dialogs/
    └── MRPreviewDialog.tsx (80 lines)

Total: 1,130 lines (11 files)
Main file: 120 lines (90% reduction!)
```

---

## Next Components to Migrate

Priority list:

1. [ ] PurchaseRequisitionComponent (estimated: 800 lines → 120 lines)
2. [ ] PurchaseOrderComponent (estimated: 900 lines → 120 lines)
3. [ ] GoodsReceiptComponent (estimated: 700 lines → 120 lines)
4. [ ] InvoiceReceiptComponent (estimated: 600 lines → 120 lines)

---

## Support

If you need help during migration:

1. Review: `FIORI_COMPONENT_ARCHITECTURE_STANDARD.md`
2. Check: `FIORI_ARCHITECTURE_QUICK_REFERENCE.md`
3. Reference: `MaterialRequestObjectPage.tsx` (example)
4. Ask: Team lead or architect

---

**Remember:** Take it step by step. Don't rush. Test thoroughly. The goal is better code, not just fewer lines.

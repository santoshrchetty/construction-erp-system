# Two-Step Module Assignment Implementation Plan

## Current Flow
```
User clicks "Assign Modules" 
  → Selects modules (HR, Finance)
  → Clicks "Assign X Modules"
  → ALL objects in selected modules are assigned automatically
```

## New Flow (Two-Step Wizard)
```
STEP 1: Select Modules
  User selects which modules to assign
  ☑ HR Module (5 objects)
  ☑ Finance Module (21 objects)
  [Next: Select Objects →]

STEP 2: Select Objects
  User selects specific objects from chosen modules
  
  HR Module:
    ☑ HR_EMPLOYEE_READ
    ☑ HR_EMPLOYEE_CREATE
    ☐ HR_PAYROLL_VIEW
    ☐ HR_PAYROLL_PROCESS
    ☐ HR_BENEFITS_MANAGE
  
  Finance Module:
    ☑ FI_INVOICE_READ
    ☑ FI_INVOICE_CREATE
    ☐ FI_PAYMENT_APPROVE
    ...
  
  [← Back] [Assign Selected (7 objects)]
```

## Implementation Changes

### 1. Add New State Variables
```typescript
const [assignmentStep, setAssignmentStep] = useState<1 | 2>(1)
const [selectedObjectsForAssignment, setSelectedObjectsForAssignment] = useState<Set<string>>(new Set())
```

### 2. Modify Module Assignment Modal

**Step 1 View** (existing - select modules):
- Keep current module selection UI
- Change button from "Assign X Modules" to "Next: Select Objects →"
- On click: setAssignmentStep(2)

**Step 2 View** (new - select objects):
- Show objects grouped by selected modules
- Each object has checkbox
- "Select All" button per module
- Back button returns to step 1
- "Assign Selected" button calls API with selected object IDs

### 3. Update assignSelectedModules Function
```typescript
const proceedToObjectSelection = () => {
  // Move to step 2
  setAssignmentStep(2)
  
  // Pre-select all objects (user can deselect)
  const allObjectIds = new Set<string>()
  selectedModulesForAssignment.forEach(module => {
    const moduleObjects = objectsByModule[module] || []
    moduleObjects.forEach(obj => allObjectIds.add(obj.id))
  })
  setSelectedObjectsForAssignment(allObjectIds)
}

const assignSelectedObjects = async () => {
  // Call bulk-assign API with selected object IDs
  const response = await fetch('/api/authorization-objects/bulk-assign', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      roleId: selectedRoleForAssignment,
      objectIds: Array.from(selectedObjectsForAssignment),
      template: 'full_access',
      cascadeLevel: 'object'
    })
  })
  
  // Close modal and refresh
  setShowModuleAssignmentModal(false)
  setAssignmentStep(1)
  setSelectedObjectsForAssignment(new Set())
  loadData()
}
```

### 4. Modal UI Structure
```tsx
{showModuleAssignmentModal && (
  <div className="modal">
    {assignmentStep === 1 && (
      // Step 1: Module Selection (existing UI)
      <div>
        <h3>Step 1: Select Modules</h3>
        {/* Module checkboxes */}
        <button onClick={proceedToObjectSelection}>
          Next: Select Objects →
        </button>
      </div>
    )}
    
    {assignmentStep === 2 && (
      // Step 2: Object Selection (new UI)
      <div>
        <h3>Step 2: Select Objects</h3>
        <p>{selectedObjectsForAssignment.size} objects selected</p>
        
        {Array.from(selectedModulesForAssignment).map(module => (
          <div key={module}>
            <h4>{module} Module</h4>
            <button onClick={() => selectAllInModule(module)}>
              Select All
            </button>
            
            {objectsByModule[module].map(obj => (
              <label key={obj.id}>
                <input
                  type="checkbox"
                  checked={selectedObjectsForAssignment.has(obj.id)}
                  onChange={() => toggleObjectSelection(obj.id)}
                />
                {obj.object_name} - {obj.description}
              </label>
            ))}
          </div>
        ))}
        
        <button onClick={() => setAssignmentStep(1)}>
          ← Back
        </button>
        <button onClick={assignSelectedObjects}>
          Assign {selectedObjectsForAssignment.size} Objects
        </button>
      </div>
    )}
  </div>
)}
```

### 5. Helper Functions
```typescript
const toggleObjectSelection = (objectId: string) => {
  const newSelected = new Set(selectedObjectsForAssignment)
  if (newSelected.has(objectId)) {
    newSelected.delete(objectId)
  } else {
    newSelected.add(objectId)
  }
  setSelectedObjectsForAssignment(newSelected)
}

const selectAllInModule = (module: string) => {
  const newSelected = new Set(selectedObjectsForAssignment)
  const moduleObjects = objectsByModule[module] || []
  moduleObjects.forEach(obj => newSelected.add(obj.id))
  setSelectedObjectsForAssignment(newSelected)
}

const deselectAllInModule = (module: string) => {
  const newSelected = new Set(selectedObjectsForAssignment)
  const moduleObjects = objectsByModule[module] || []
  moduleObjects.forEach(obj => newSelected.delete(obj.id))
  setSelectedObjectsForAssignment(newSelected)
}
```

## Benefits

1. **User Control**: Select exactly which objects to assign
2. **Transparency**: See all objects before assigning
3. **Flexibility**: Different roles can have different objects from same module
4. **Better UX**: Clear two-step process with back button

## Next Steps

1. Add state variables for step and selected objects
2. Split modal into two views based on step
3. Add object selection UI with checkboxes
4. Update button handlers
5. Test the flow

Would you like me to implement this now?

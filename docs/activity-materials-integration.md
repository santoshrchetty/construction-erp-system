# Where Materials Attach to Activities

## UI Integration Points

### 1. Activity Form (Create/Edit Activity)
**Location**: `components/activities/ActivityForm.tsx`

Add a new tab or section called "Materials" where users can:
- Select materials from dropdown
- Enter required quantity
- Set unit cost
- Materials automatically inherit the activity's planned_start_date

### 2. Activity Detail View
**Location**: Create `components/activities/ActivityDetailView.tsx`

Show attached materials with:
- Material code and name
- Required quantity
- Planned consumption date (inherited from activity)
- Status (planned/reserved/issued/consumed)
- Total cost

### 3. Activity Manager
**Location**: `components/features/projects/ActivityManager.tsx`

Add "Materials" button/tab to:
- View materials attached to selected activity
- Add/remove materials
- Update quantities

## Implementation Steps

### Step 1: Run Schema
```sql
-- Run this in Supabase SQL Editor
-- File: database/activity-materials-schema.sql
```

### Step 2: Add Materials Tab to ActivityForm
```tsx
// In ActivityForm.tsx, add:
import ActivityMaterialsForm from './ActivityMaterialsForm'

// Add tab/section:
<ActivityMaterialsForm 
  activityId={activityId}
  onSave={handleSaveMaterials}
/>
```

### Step 3: Create API Handler
Since nested folders don't exist, add to existing activities route:

**File**: `app/api/activities/route.ts`

Add these functions:
```typescript
// GET materials for activity
export async function GET(request: NextRequest) {
  const activityId = request.nextUrl.searchParams.get('activityId')
  const action = request.nextUrl.searchParams.get('action')
  
  if (action === 'materials') {
    const { data } = await supabase
      .from('activity_materials')
      .select('*, materials(*)')
      .eq('activity_id', activityId)
    return NextResponse.json(data)
  }
}

// POST materials to activity
// Use action=attach-materials in query params
```

### Step 4: Usage Flow

1. **User creates activity** → Sets dates
2. **User clicks "Add Materials"** → Opens material selection
3. **User selects materials** → Quantities and costs
4. **System saves** → Materials get activity's start date automatically
5. **When activity date changes** → Material dates update

## Example Workflow

```
Activity: "Foundation Work"
├── Planned Start: 2024-03-01
├── Planned End: 2024-03-10
└── Materials:
    ├── Cement (100 BAG) → Consumption Date: 2024-03-01 (auto)
    ├── Steel (500 KG) → Consumption Date: 2024-03-01 (auto)
    └── Sand (10 TON) → Consumption Date: 2024-03-01 (auto)
```

## Files Created

1. ✅ `database/activity-materials-schema.sql` - Database schema
2. ✅ `database/activity-materials-examples.sql` - SQL examples
3. ✅ `components/activities/ActivityMaterialsForm.tsx` - UI component

## Next Steps

1. Run the schema file in Supabase
2. Integrate ActivityMaterialsForm into your existing ActivityForm
3. Add API endpoints to activities/route.ts
4. Test the date inheritance trigger

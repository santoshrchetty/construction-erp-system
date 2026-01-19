# Resource Planning - Setup Guide

## ✅ IMPLEMENTATION COMPLETE

All code, components, and architecture layers are implemented. Only database migration remains.

---

## 📋 Manual Steps Required

### Step 1: Run Database Migration

**File**: `database/00-resource-planning-complete.sql`

```bash
# In Supabase SQL Editor:
# 1. Open the file
# 2. Copy entire contents
# 3. Paste into SQL Editor
# 4. Click "Run"
```

**What it creates**:
- 5 resource tables (materials, equipment, manpower, services, subcontractors)
- Triggers for date inheritance
- Triggers for timestamp updates
- Indexes for performance
- Materialized view: mv_activities_resource_status

### Step 2: Verify Tables Created

```sql
-- Run this to verify:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name LIKE 'activity_%';

-- Expected results:
-- activity_materials
-- activity_equipment
-- activity_manpower
-- activity_services
-- activity_subcontractors
```

### Step 3: Verify Materialized View

```sql
-- Check materialized view:
SELECT * FROM mv_activities_resource_status LIMIT 5;

-- Refresh if needed:
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_activities_resource_status;
```

### Step 4: Access Resource Planning

1. Navigate to your application
2. Go to Projects module
3. Open Resource Planning page/tile
4. Select a project
5. View activities with resource status
6. Click an activity to assign resources
7. Use 5 tabs: Materials, Equipment, Manpower, Services, Subcontractors

---

## 📊 System Architecture

### File Structure
```
Construction_App/
├── database/
│   └── 00-resource-planning-complete.sql  ✅ Run this
│
├── types/repositories/
│   └── activities.repository.ts  ✅ Complete
│
├── lib/
│   ├── repositories.ts  ✅ Complete
│   └── services/
│       └── resourcePlanning.service.ts  ✅ Complete
│
├── app/api/
│   ├── planning/route.ts  ✅ Complete
│   └── activities/route.ts  ✅ Complete
│
└── components/
    ├── features/projects/
    │   └── ResourcePlanningManager.tsx  ✅ Complete
    ├── activities/
    │   ├── ActivityMaterialsForm.tsx  ✅ Complete
    │   ├── ActivityEquipmentForm.tsx  ✅ Complete
    │   ├── ActivityManpowerForm.tsx  ✅ Complete
    │   ├── ActivityServicesForm.tsx  ✅ Complete
    │   └── ActivitySubcontractorsForm.tsx  ✅ Complete
    └── ui/
        ├── textarea.tsx  ✅ Complete
        ├── label.tsx  ✅ Complete
        └── select.tsx  ✅ Complete
```

### 4-Layer Architecture
```
💻 UI Components (ResourcePlanningManager + 5 Forms)
    ↓ HTTP calls
🌐 API Routes (/api/planning, /api/activities)
    ↓ function calls
💼 Service Layer (resourcePlanning.service.ts)
    ↓ function calls
💾 Repository Layer (activities.repository.ts)
    ↓ SQL queries
📊 Database (PostgreSQL/Supabase)
```

---

## ✨ Features Implemented

### 1. Materials Tab
- Material selection and quantity
- Unit of measure
- Planned consumption date
- Cost tracking
- MRP integration (reservation_id, demand_line_id)
- Priority levels

### 2. Equipment Tab
- Equipment selection
- Required hours
- Hourly rate
- Date range (start/end)
- Status tracking
- Priority levels

### 3. Manpower Tab
- Employee selection (optional)
- Role definition
- Required hours
- Hourly rate
- Date range (start/end)
- Status tracking
- Priority levels

### 4. Services Tab
- Service type: testing, inspection, certification, survey, commissioning
- Service provider selection
- Scheduled date and duration
- Cost tracking
- Result tracking (passed/failed/conditional)
- Document attachment
- Priority levels

### 5. Subcontractors Tab
- Trade classification
- Scope of work
- Crew size
- Contract tracking (contract_id, contract_number)
- Date range (start/end, mobilization)
- Financial tracking (contract_value, paid_to_date, retention)
- Progress percentage
- Status: awarded, mobilized, in_progress, suspended, completed, terminated
- Priority levels

---

## 🚀 Performance Optimizations

### Materialized View
- Pre-aggregates resource counts for all activities
- Eliminates need for 5 JOIN queries per activity
- Optimized for 2000+ activities
- Refresh strategy: CONCURRENTLY (no table locks)

### Indexes
- activity_id (fast lookups by activity)
- project_id (fast project filtering)
- status (fast status filtering)
- Date fields (fast date range queries)

### Triggers
- Auto-inherit dates from parent activities
- Auto-update timestamps
- Maintains referential integrity

---

## 📝 Testing Checklist

### Database
- [ ] All 5 tables created
- [ ] Triggers working (date inheritance)
- [ ] Indexes created
- [ ] Materialized view populated

### API
- [ ] GET /api/planning returns activities
- [ ] GET /api/activities?action=services works
- [ ] POST /api/activities?action=attach-services works
- [ ] GET /api/activities?action=subcontractors works
- [ ] POST /api/activities?action=attach-subcontractors works

### UI
- [ ] ResourcePlanningManager loads
- [ ] All 5 tabs render
- [ ] Activity list shows resource counts
- [ ] Forms submit successfully
- [ ] Success/error messages display

### Integration
- [ ] Materials integrate with MRP
- [ ] Manpower integrates with HR
- [ ] Services integrate with vendor management
- [ ] Subcontractors integrate with vendor management
- [ ] Cost tracking integrates with finance

---

## 🔧 Troubleshooting

### Issue: Tables not created
**Solution**: Check SQL syntax errors in migration file. Look for reserved keywords.

### Issue: Triggers not firing
**Solution**: Verify trigger functions exist. Check function syntax.

### Issue: Materialized view empty
**Solution**: Run `REFRESH MATERIALIZED VIEW mv_activities_resource_status;`

### Issue: API returns 500 error
**Solution**: Check Supabase client initialization. Verify table permissions.

### Issue: Forms not submitting
**Solution**: Check network tab for API errors. Verify request payload format.

---

## 📚 Additional Resources

- **Architecture**: See `docs/RESOURCE_PLANNING_ARCHITECTURE.md`
- **4-Layer Standard**: See `docs/4-layer-architecture-standard.md`
- **Database Schema**: See `database/00-resource-planning-complete.sql`

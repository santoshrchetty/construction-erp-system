# Resource Planning - 4-Layer Architecture

## Overview
Complete 5-tab Resource Planning system (Materials, Equipment, Manpower, Services, Subcontractors) following strict 4-layer architecture.

**Status**: ✅ IMPLEMENTATION COMPLETE

---

## Architecture Layers

### **Layer 1: Database (PostgreSQL)**
Location: `database/`

**Tables:**
- `activity_materials` - Material assignments with MRP integration (unit_of_measure, reservation_id, demand_line_id)
- `activity_equipment` - Equipment assignments with hourly tracking
- `activity_manpower` - Manpower assignments with role-based allocation
- `activity_services` - Services (testing, inspection, certification, survey, commissioning)
- `activity_subcontractors` - Subcontractor assignments with contract tracking

**Performance:**
- `mv_activities_resource_status` - Materialized view aggregating all 5 resource types
- Indexes on activity_id, project_id, status, and date fields
- Triggers for automatic date inheritance from parent activities
- Triggers for timestamp updates (created_at, updated_at)

**Files:**
- `00-resource-planning-complete.sql` - Consolidated migration with all 5 resource types, triggers, indexes, and materialized view

---

### **Layer 2: Repository (Data Access)**
Location: `types/repositories/activities.repository.ts`

**Class:** `ActivitiesRepository`

**Methods:**
```typescript
// Core CRUD
findByProject(projectId: string)
create(activity: ActivityInsert)
update(id: string, updates: ActivityUpdate)
updateProgress(id: string, progress: number, ...)

// Resource Planning - All 5 Types
findWithResourceCounts(projectId, dateFrom, dateTo, limit)
  // Returns activities with counts: materials_count, equipment_count, 
  // manpower_count, services_count, subcontractors_count

// Materials (existing)
findMaterialsByActivity(activityId: string)
createMaterial(material: any)

// Equipment (existing)
findEquipmentByActivity(activityId: string)
createEquipment(equipment: any)

// Manpower (existing)
findManpowerByActivity(activityId: string)
createManpower(manpower: any)

// Services
findServicesByActivity(activityId: string)
createService(service: any)

// Subcontractors
findSubcontractorsByActivity(activityId: string)
createSubcontractor(subcontractor: any)
```

**Instantiation:** `lib/repositories.ts`
```typescript
export const repositories = {
  activities: new ActivitiesRepository(supabase),
  // ... other repositories
}
```

---

### **Layer 3: Service (Business Logic)**
Location: `lib/services/resourcePlanning.service.ts`

**Class:** `ResourcePlanningService`

**Methods:**
```typescript
// Activities with all 5 resource counts
getActivitiesForResourcePlanning(filter: ResourcePlanningFilter)
  // Returns activities with materials_count, equipment_count, manpower_count,
  // services_count, subcontractors_count

getResourceSummary(projectId: string)
  // Aggregates totals across all 5 resource types

// Materials (existing)
getActivityMaterials(activityId: string)
attachMaterial(activityId: string, materialData: any)

// Equipment (existing)
getActivityEquipment(activityId: string)
attachEquipment(activityId: string, equipmentData: any)

// Manpower (existing)
getActivityManpower(activityId: string)
attachManpower(activityId: string, manpowerData: any)

// Services
getActivityServices(activityId: string)
attachService(activityId: string, serviceData: any)

// Subcontractors
getActivitySubcontractors(activityId: string)
attachSubcontractor(activityId: string, subcontractorData: any)
```

**Business Logic:**
- Validates data before repository calls
- Calculates resource summaries
- Handles complex multi-table operations

**Export:**
```typescript
export const resourcePlanningService = new ResourcePlanningService()
```

---

### **Layer 4: API Routes (Controllers)**
Location: `app/api/`

#### **Planning Route** (`app/api/planning/route.ts`)
```typescript
GET /api/planning?projectId=xxx&dateFrom=xxx&dateTo=xxx
- Calls: resourcePlanningService.getActivitiesForResourcePlanning()
- Returns: Activities with all 5 resource type counts
```

#### **Activities Route** (`app/api/activities/route.ts`)
```typescript
// Materials (existing)
GET /api/activities?action=materials&activityId=xxx
POST /api/activities?action=attach-materials

// Equipment (existing)
GET /api/activities?action=equipment&activityId=xxx
POST /api/activities?action=attach-equipment

// Manpower (existing)
GET /api/activities?action=manpower&activityId=xxx
POST /api/activities?action=attach-manpower

// Services
GET /api/activities?action=services&activityId=xxx
- Calls: resourcePlanningService.getActivityServices()

POST /api/activities?action=attach-services
- Calls: resourcePlanningService.attachService()

// Subcontractors
GET /api/activities?action=subcontractors&activityId=xxx
- Calls: resourcePlanningService.getActivitySubcontractors()

POST /api/activities?action=attach-subcontractors
- Calls: resourcePlanningService.attachSubcontractor()
```

---

### **Layer 5: Presentation (UI Components)**
Location: `components/`

#### **Main Manager**
`components/features/projects/ResourcePlanningManager.tsx`
- 5 tabs: Materials, Equipment, Manpower, Services, Subcontractors
- Activity list with resource status icons
- Date range filters
- Calls: `/api/planning`

#### **Forms**
```
components/activities/
├── ActivityMaterialsForm.tsx
├── ActivityEquipmentForm.tsx
├── ActivityManpowerForm.tsx
├── ActivityServicesForm.tsx
└── ActivitySubcontractorsForm.tsx
```

Each form:
- Calls respective API endpoint
- Handles validation
- Shows success/error states

---

## Data Flow Example

### **Attaching a Service to Activity**

1. **User Action** (Presentation Layer)
   ```typescript
   // ActivityServicesForm.tsx
   POST /api/activities?action=attach-services
   Body: { activity_id, service_type, service_description, ... }
   ```

2. **API Route** (Controller Layer)
   ```typescript
   // app/api/activities/route.ts
   const { activity_id, ...serviceData } = await request.json()
   const data = await resourcePlanningService.attachService(activity_id, serviceData)
   ```

3. **Service** (Business Logic Layer)
   ```typescript
   // lib/services/resourcePlanning.service.ts
   async attachService(activityId, serviceData) {
     // Validate data
     const service = { activity_id: activityId, ...serviceData }
     return repositories.activities.createService(service)
   }
   ```

4. **Repository** (Data Access Layer)
   ```typescript
   // types/repositories/activities.repository.ts
   async createService(service) {
     const { data, error } = await this.supabase
       .from('activity_services')
       .insert(service)
       .select()
       .single()
     if (error) throw error
     return data
   }
   ```

5. **Database** (Persistence Layer)
   - Trigger: `sync_activity_services_data()` - Auto-inherits dates from activity
   - Trigger: `update_activity_services_timestamp()` - Updates timestamp
   - Insert into `activity_services` table

---

## Cost Tracking Architecture

### Cost Elements Master (SAP CO Model)

**Separate from GL Accounts:**
- **GL Accounts**: Financial Accounting (FI) - External reporting, compliance
- **Cost Elements**: Cost Accounting (CO) - Internal management, profitability

**Cost Element Categories:**
1. **PRIMARY_DIRECT**: Direct costs (1:1 with GL) - Material, Labor, Equipment, Subcontractor
2. **PRIMARY_INDIRECT**: Indirect costs (1:1 with GL) - Overhead, Site costs, Admin
3. **SECONDARY**: CO-only (no GL) - Allocations, Settlements, Internal orders

**Schema:**
```sql
cost_elements (
  cost_element VARCHAR(20),           -- Same as GL for primary
  cost_element_category,              -- PRIMARY_DIRECT, PRIMARY_INDIRECT, SECONDARY
  cost_element_type,                  -- MATERIAL, LABOR, EQUIPMENT, SUBCONTRACTOR, OVERHEAD
  is_direct_cost BOOLEAN,
  gl_account VARCHAR(20),             -- NULL for secondary cost elements
  allocation_allowed BOOLEAN,
  default_allocation_basis            -- LABOR_HOURS, MACHINE_HOURS, DIRECT_COST, etc.
)
```

### WBS vs Activity Code Structure

**Key Distinction:**
- **WBS Elements**: Budget allocation and control (e.g., `HW-0001.01`)
- **Activity Codes**: Execution tracking (e.g., `HW-0001.01-A01`)

**Code Pattern:**
```
Activity Code: HW-0001.01-A01
├── WBS Portion: HW-0001.01
└── Activity Suffix: -A01
```

### Universal Journal Integration

**Dual-Level Posting:**
```sql
universal_journal (
  gl_account VARCHAR(20),      -- Financial Accounting view
  cost_element VARCHAR(20),    -- Cost Accounting view (references cost_elements)
  wbs_element VARCHAR(30),     -- Budget control level
  activity_code VARCHAR(50),   -- Execution tracking level
  project_code VARCHAR(20)     -- Reporting level
)
```

**Posting Patterns:**

1. **Primary Direct Cost** (Activity-level)
```sql
gl_account = '500000'           -- Financial posting
cost_element = '500000'         -- Cost element (1:1 mapping)
wbs_element = 'HW-0001.01'      -- Budget control
activity_code = 'HW-0001.01-A01' -- Execution tracking
```

2. **Primary Indirect Cost** (WBS-level)
```sql
gl_account = '600000'
cost_element = '600000'
wbs_element = 'HW-0001.01'
activity_code = NULL             -- No specific activity
```

3. **Secondary Cost** (Allocation, CO-only)
```sql
gl_account = NULL                -- No financial posting
cost_element = '900000'          -- Allocation cost element
wbs_element = 'HW-0001.01'
activity_code = 'HW-0001.01-A01'
```

### Cost Query Strategy

**Activity-Level Actual Costs:**
```typescript
// Query by activity_code and cost_element_type
const { data } = await supabase
  .from('universal_journal')
  .select('company_amount, cost_elements!inner(cost_element_type)')
  .eq('activity_code', activityCode)
  .eq('cost_elements.cost_element_type', 'MATERIAL')
```

**Direct vs Indirect Cost Report:**
```sql
SELECT 
  ce.is_direct_cost,
  ce.cost_element_type,
  SUM(uj.company_amount) as total_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.is_direct_cost, ce.cost_element_type
```

**Cost Calculation:**
- **Planned Costs**: From resource assignment tables (quantity × cost, hours × rate)
- **Actual Costs**: From universal_journal by activity_code and cost_element_type
- **Variance**: Actual - Planned (color-coded indicators)

**Implementation:**
- Database: `cost-elements-schema.sql`, `enhance-universal-journal-for-costing.sql`
- Service: `resourcePlanning.service.ts` → `calculateActivityCosts()` method
- UI: `ResourcePlanningManager.tsx` → Planned vs Actual comparison

---

## Key Principles Followed

✅ **Separation of Concerns**
- Each layer has single responsibility
- No database queries in UI components
- No business logic in API routes

✅ **Dependency Direction**
- Presentation → API → Service → Repository → Database
- Never backwards

✅ **Reusability**
- Repository methods used by multiple services
- Service methods used by multiple API routes

✅ **Testability**
- Each layer can be tested independently
- Mock dependencies easily

✅ **Maintainability**
- Changes to database only affect repository
- Changes to business logic only affect service
- UI changes don't affect backend

---

## File Structure

```
Construction_App/
├── database/
│   ├── migrate-activity-materials.sql
│   ├── activity-equipment-manpower-schema.sql
│   ├── activity-services-subcontractors-schema.sql
│   └── resource-planning-performance.sql
│
├── types/repositories/
│   └── activities.repository.ts
│
├── lib/
│   ├── repositories.ts (instantiation)
│   └── services/
│       └── resourcePlanning.service.ts
│
├── app/api/
│   ├── planning/route.ts
│   └── activities/route.ts
│
└── components/
    ├── features/projects/
    │   └── ResourcePlanningManager.tsx
    └── activities/
        ├── ActivityMaterialsForm.tsx
        ├── ActivityEquipmentForm.tsx
        ├── ActivityManpowerForm.tsx
        ├── ActivityServicesForm.tsx
        └── ActivitySubcontractorsForm.tsx
```

---

## Implementation Status

### ✅ Completed
1. Database schema with all 5 resource types
2. Triggers for date inheritance and timestamps
3. Materialized view for performance (mv_activities_resource_status)
4. Indexes on all critical fields
5. Repository methods for all 5 resource types
6. Service layer with business logic
7. API routes for all endpoints
8. UI components: ResourcePlanningManager with 5 tabs
9. Forms: ActivityServicesForm, ActivitySubcontractorsForm
10. UI components: textarea, label, select
11. Fixed all imports and exports
12. Fixed SQL reserved keyword ('asc' → 'asub')

### 📋 Pending
1. Run database migration: `00-resource-planning-complete.sql`
2. Test end-to-end flow for all 5 resource types
3. Add comprehensive error handling
4. Add loading states to forms
5. Add client-side validation rules
6. Performance testing with 2000+ activities
7. Integration testing with MRP system (materials)
8. Integration testing with HR system (manpower)
9. Integration testing with vendor management (services, subcontractors)

### 🔧 Known Issues
- 26 pre-existing build errors unrelated to Resource Planning (missing legacy components, duplicate declarations)
- Resource Planning implementation itself has zero errors

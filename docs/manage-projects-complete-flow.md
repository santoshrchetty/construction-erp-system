# Manage Projects - Complete File Flow with Folders

## 📁 Complete Folder Structure

```
Construction_App/
│
├── app/
│   ├── erp-modules/
│   │   └── page.tsx                                    [ENTRY POINT]
│   │       └── Renders: EnhancedConstructionTiles
│   │
│   └── api/
│       ├── tiles/
│       │   └── route.ts                                [LAYER 2: API ROUTE]
│       │       └── POST handler routes to projects handler
│       │
│       └── projects/
│           ├── route.ts                                [OPTIONAL: Direct API]
│           └── handler.ts                              [LAYER 3: HANDLER]
│               └── Orchestrates CRUD operations
│
├── components/
│   ├── tiles/
│   │   ├── EnhancedConstructionTiles.tsx              [TILE DISPLAY]
│   │   │   └── Displays all tiles + handles clicks
│   │   │
│   │   └── ManageProjectsComponent.tsx                [LAYER 1: UI COMPONENT]
│   │       └── Tab interface (List/Create)
│   │
│   └── layout/
│       └── dashboards/
│           └── IndustrialDashboard.tsx                [ALTERNATIVE DISPLAY]
│               └── Also displays tiles with modal
│
├── domains/
│   └── projects/
│       └── projectCrudService.ts                      [LAYER 4: SERVICE]
│           └── Database operations via Supabase
│
└── database/
    └── setup-manage-projects-tile.sql                 [DATABASE SETUP]
        └── Creates/updates tile record
```

## 🔄 Complete User Flow with File Paths

```
┌─────────────────────────────────────────────────────────────────────┐
│ USER OPENS BROWSER                                                   │
│ URL: http://localhost:3000/erp-modules                             │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ FILE: app/erp-modules/page.tsx                                      │
│ RENDERS: <EnhancedConstructionTiles />                              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ FILE: components/tiles/EnhancedConstructionTiles.tsx                │
│                                                                      │
│ useEffect(() => {                                                   │
│   fetchTiles()  // Loads all tiles from database                   │
│ }, [])                                                              │
│                                                                      │
│ • Displays tiles in grid                                            │
│ • User sees "Manage Projects" tile                                  │
│ • User clicks tile                                                   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ handleTileClick(tile)
                             │ setActiveComponent('Manage Projects')
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ FILE: components/tiles/EnhancedConstructionTiles.tsx                │
│ FUNCTION: renderActiveComponent()                                   │
│                                                                      │
│ case 'Manage Projects':                                             │
│   const { ManageProjectsComponent } = require(                      │
│     './ManageProjectsComponent'                                     │
│   )                                                                  │
│   return <ManageProjectsComponent />                                │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 1: UI COMPONENT                                               │
│ FILE: components/tiles/ManageProjectsComponent.tsx                  │
│                                                                      │
│ • Shows tabs: [Projects List] [Create Project]                      │
│ • User clicks "Projects List" tab                                   │
│                                                                      │
│ const loadProjects = async () => {                                  │
│   const response = await fetch('/api/tiles', {                      │
│     method: 'POST',                                                  │
│     body: JSON.stringify({                                           │
│       category: 'projects',  ← Routes to projects handler           │
│       action: 'list'         ← Specifies operation                  │
│     })                                                               │
│   })                                                                 │
│ }                                                                    │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ HTTP POST /api/tiles
                             │ Body: { category: 'projects', action: 'list' }
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 2: API ROUTE                                                  │
│ FILE: app/api/tiles/route.ts                                        │
│                                                                      │
│ export const POST = async (request: NextRequest) => {               │
│   const body = await request.json()                                 │
│                                                                      │
│   // Route based on category                                        │
│   if (body.category === 'projects') {                               │
│     const { handleProjects } = await import(                        │
│       '@/app/api/projects/handler'  ← Import handler                │
│     )                                                                │
│                                                                      │
│     if (body.action === 'list') {                                   │
│       const data = await handleProjects(                            │
│         'list',              ← Action                               │
│         body.payload || {},  ← Data                                 │
│         'GET'                ← Method                               │
│       )                                                              │
│       return NextResponse.json({ success: true, data })             │
│     }                                                                │
│   }                                                                  │
│ }                                                                    │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ handleProjects('list', {}, 'GET')
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 3: HANDLER (Business Orchestration)                           │
│ FILE: app/api/projects/handler.ts                                   │
│                                                                      │
│ import * as projectCrudService from                                 │
│   '@/domains/projects/projectCrudService'                           │
│                                                                      │
│ export async function handleProjects(                               │
│   action: string,                                                   │
│   body: any,                                                        │
│   method: string                                                    │
│ ) {                                                                  │
│   switch (action) {                                                 │
│     case 'list':                                                    │
│       return await projectCrudService.getAllProjects(               │
│         body.companyId  ← Optional filter                           │
│       )                                                              │
│                                                                      │
│     case 'create':                                                  │
│       return await projectCrudService.createProject(                │
│         body, body.userId                                           │
│       )                                                              │
│                                                                      │
│     case 'update':                                                  │
│       return await projectCrudService.updateProject(                │
│         body.id, body, body.userId                                  │
│       )                                                              │
│                                                                      │
│     case 'delete':                                                  │
│       return await projectCrudService.deleteProject(                │
│         body.id                                                     │
│       )                                                              │
│   }                                                                  │
│ }                                                                    │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ projectCrudService.getAllProjects()
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 4: SERVICE (Business Logic & Data Access)                     │
│ FILE: domains/projects/projectCrudService.ts                        │
│                                                                      │
│ import { createServiceClient } from '@/lib/supabase/server'         │
│                                                                      │
│ export async function getAllProjects(companyId?: string) {          │
│   const supabase = await createServiceClient()                     │
│                                                                      │
│   let query = supabase                                              │
│     .from('projects')                                               │
│     .select(`                                                        │
│       *,                                                             │
│       company:company_code_id(company_code, company_name)           │
│     `)                                                               │
│     .order('created_at', { ascending: false })                      │
│                                                                      │
│   if (companyId) {                                                  │
│     query = query.eq('company_code_id', companyId)                 │
│   }                                                                  │
│                                                                      │
│   const { data, error } = await query                               │
│                                                                      │
│   if (error) throw error                                            │
│   return data || []                                                 │
│ }                                                                    │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ SQL Query to Database
                             ▼
                    ┌────────────────────┐
                    │   SUPABASE DB      │
                    │   projects table   │
                    │                    │
                    │ SELECT * FROM      │
                    │ projects           │
                    │ ORDER BY           │
                    │ created_at DESC    │
                    └────────┬───────────┘
                             │
                             │ Returns: [{ id, code, name, ... }]
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ RESPONSE FLOWS BACK UP THE LAYERS                                   │
│                                                                      │
│ Layer 4 (Service) → Returns data array                              │
│         ↓                                                            │
│ Layer 3 (Handler) → Returns data to API                             │
│         ↓                                                            │
│ Layer 2 (API Route) → Returns JSON response                         │
│         ↓                                                            │
│ Layer 1 (Component) → Updates state & displays                      │
│                                                                      │
│ setProjects(data.data)                                              │
│ // UI updates with project list                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 📊 File Interaction Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         USER BROWSER                              │
│                  http://localhost:3000/erp-modules               │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   Next.js App   │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ app/         │    │ components/  │    │ domains/     │
│ erp-modules/ │───▶│ tiles/       │    │ projects/    │
│ page.tsx     │    │              │    │              │
└──────────────┘    └──────┬───────┘    └──────┬───────┘
                           │                    │
                    ┌──────▼────────┐          │
                    │ Enhanced      │          │
                    │ Construction  │          │
                    │ Tiles.tsx     │          │
                    └──────┬────────┘          │
                           │                    │
                    ┌──────▼────────┐          │
                    │ Manage        │          │
                    │ Projects      │          │
                    │ Component.tsx │          │
                    └──────┬────────┘          │
                           │                    │
                           │ fetch('/api/tiles')│
                           │                    │
                    ┌──────▼────────┐          │
                    │ app/api/      │          │
                    │ tiles/        │          │
                    │ route.ts      │          │
                    └──────┬────────┘          │
                           │                    │
                    ┌──────▼────────┐          │
                    │ app/api/      │          │
                    │ projects/     │          │
                    │ handler.ts    │──────────┤
                    └──────┬────────┘          │
                           │                    │
                           └────────────────────▼
                                    ┌──────────────┐
                                    │ project      │
                                    │ CrudService  │
                                    │ .ts          │
                                    └──────┬───────┘
                                           │
                                    ┌──────▼───────┐
                                    │  Supabase    │
                                    │  Database    │
                                    │  (projects)  │
                                    └──────────────┘
```

## 🗂️ File Responsibilities

### **Entry Point**
```
app/erp-modules/page.tsx
└─ Renders EnhancedConstructionTiles component
```

### **Tile Display & Routing**
```
components/tiles/EnhancedConstructionTiles.tsx
├─ Fetches all tiles from database
├─ Displays tiles in grid layout
├─ Handles tile clicks
└─ Routes to appropriate component based on tile.title
```

### **Layer 1: UI Component**
```
components/tiles/ManageProjectsComponent.tsx
├─ Displays tab interface (List/Create)
├─ Handles form inputs
├─ Makes API calls to /api/tiles
└─ Updates UI with responses
```

### **Layer 2: API Route**
```
app/api/tiles/route.ts
├─ Receives HTTP POST requests
├─ Parses body.category and body.action
├─ Routes to appropriate handler
└─ Returns standardized JSON responses
```

### **Layer 3: Handler**
```
app/api/projects/handler.ts
├─ Imports service layer
├─ Orchestrates business operations
├─ Routes actions (list, create, update, delete)
└─ Returns results to API layer
```

### **Layer 4: Service**
```
domains/projects/projectCrudService.ts
├─ Implements business logic
├─ Direct Supabase database access
├─ Executes SQL queries
└─ Returns data to handler
```

### **Database Setup**
```
database/setup-manage-projects-tile.sql
├─ Creates/updates tile record
├─ Sets construction_action = 'manage-projects'
└─ Configures tile metadata
```

## 🎯 Key File Paths Summary

| Layer | File Path | Purpose |
|-------|-----------|---------|
| Entry | `app/erp-modules/page.tsx` | Page entry point |
| Display | `components/tiles/EnhancedConstructionTiles.tsx` | Tile grid & routing |
| Layer 1 | `components/tiles/ManageProjectsComponent.tsx` | UI Component |
| Layer 2 | `app/api/tiles/route.ts` | API Route |
| Layer 3 | `app/api/projects/handler.ts` | Handler |
| Layer 4 | `domains/projects/projectCrudService.ts` | Service |
| Database | `database/setup-manage-projects-tile.sql` | Setup Script |

## ✅ Complete Implementation Checklist

- ✅ `app/erp-modules/page.tsx` - Entry point exists
- ✅ `components/tiles/EnhancedConstructionTiles.tsx` - Updated with Manage Projects case
- ✅ `components/tiles/ManageProjectsComponent.tsx` - Created
- ✅ `app/api/tiles/route.ts` - Updated with projects category handler
- ✅ `app/api/projects/handler.ts` - Updated with CRUD actions
- ✅ `domains/projects/projectCrudService.ts` - Created
- ✅ `database/setup-manage-projects-tile.sql` - Ready to run

**Next Step:** Run the SQL script to create the tile in the database!


## 🗄️ Database Schema Reference

### Table: `companies` (Parent/Group Companies)
```sql
- company_id (UUID, PK)
- grpcompany_name (VARCHAR) ← Group name: "ABC Construction Group", "Bramen Group"
- industry (VARCHAR)
- country (VARCHAR)
- is_active (BOOLEAN)
- created_at (TIMESTAMP)
```

### Table: `company_codes` (Individual Companies)
```sql
- id (UUID, PK)
- company_code (VARCHAR) ← "C001", "C002", "B001", "N001"
- company_name (VARCHAR) ← "ABC Construction Ltd", "ABC Infrastructure"
- company_id (UUID, FK → companies.company_id)
- legal_entity_name (VARCHAR)
- currency (VARCHAR)
- country (VARCHAR)
- is_active (BOOLEAN)
```

### Table: `projects`
```sql
- id (UUID, PK)
- code (VARCHAR) ← Project code: "P001", "HW0001"
- name (VARCHAR)
- company_code_id (UUID, FK → company_codes.id)
- project_type (VARCHAR)
- status (VARCHAR)
- start_date (DATE)
- planned_end_date (DATE)
- budget (NUMERIC)
- created_at (TIMESTAMP)
```

### Key Relationships
```
companies (1) ──< (N) company_codes
  └─ grpcompany_name        └─ company_code, company_name

company_codes (1) ──< (N) projects
  └─ id                     └─ company_code_id
```

## 📊 Data Flow Example

**User creates a project:**
```
1. User selects: "C001 - ABC Construction Ltd" from dropdown
2. Frontend sends: { company_code: "C001", ... }
3. Backend queries company_codes to get id
4. Saves project with company_code_id = <uuid of C001>
5. When listing projects, joins:
   projects.company_code_id → company_codes.id
   to fetch company_code and company_name
```

**Display in UI:**
```
Projects List Table:
┌──────────────┬──────────────┬─────────────────────┐
│ Project Code │ Company Code │ Name                │
├──────────────┼──────────────┼─────────────────────┤
│ P001         │ C001         │ Highway Project     │
│ HW0001       │ C002         │ Bridge Construction │
└──────────────┴──────────────┴─────────────────────┘
```

## 🔑 Important Notes

### Column Naming Convention
- `companies.grpcompany_name` = Parent/Group company name
- `company_codes.company_name` = Individual company name
- `company_codes.company_code` = Company identifier code
- `projects.code` = Project identifier code

### Why grpcompany_name?
To avoid confusion with `company_codes.company_name`. The "grp" prefix clearly indicates this is the parent group company name.

### Foreign Key Strategy
- Projects reference `company_codes.id` (not company_code string)
- This ensures referential integrity
- Allows company_code changes without breaking project links

## 🎯 UI Labels (Final)

**Projects List Table Headers:**
- "Project Code" (displays `projects.code`)
- "Company Code" (displays `company_codes.company_code` via join)
- "Name" (displays `projects.name`)

**Create/Edit Form Labels:**
- "Project Code *" (input for `projects.code`)
- "Company Code *" (dropdown showing `company_code - company_name`)
- "Project Name *" (input for `projects.name`)

---

**Last Updated:** After grpcompany_name migration
**Status:** ✅ Production Ready

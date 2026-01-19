# Manage Projects - 4-Layer Architecture Flow

## Complete File Path Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 1: PRESENTATION (UI Component)                                │
│ File: components/tiles/ManageProjectsComponent.tsx                  │
│                                                                      │
│ • Renders UI (tabs, forms, tables)                                  │
│ • Handles user interactions                                         │
│ • Makes API calls to Layer 2                                        │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           │ fetch('/api/tiles', {
                           │   method: 'POST',
                           │   body: { category: 'projects', action: 'list' }
                           │ })
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 2: API ROUTE (HTTP Handler)                                   │
│ File: app/api/tiles/route.ts                                        │
│                                                                      │
│ • Receives HTTP POST request                                        │
│ • Extracts category='projects' and action                           │
│ • Routes to Handler Layer                                           │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           │ if (body.category === 'projects') {
                           │   const { handleProjects } = await import(
                           │     '@/app/api/projects/handler'
                           │   )
                           │   handleProjects(action, payload, 'POST')
                           │ }
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 3: HANDLER (Business Orchestration)                           │
│ File: app/api/projects/handler.ts                                   │
│                                                                      │
│ • Receives action: 'list', 'create', 'update', 'delete'            │
│ • Orchestrates business logic                                       │
│ • Calls Service Layer                                               │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           │ switch (action) {
                           │   case 'list':
                           │     return await projectCrudService.getAllProjects()
                           │   case 'create':
                           │     return await projectCrudService.createProject()
                           │   ...
                           │ }
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 4: SERVICE (Business Logic & Data Access)                     │
│ File: domains/projects/projectCrudService.ts                        │
│                                                                      │
│ • Implements business logic                                         │
│ • Direct database access via Supabase                               │
│ • Returns data to Handler                                           │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           │ const supabase = await createServiceClient()
                           │ const { data } = await supabase
                           │   .from('projects')
                           │   .select('*')
                           │
                           ▼
                    ┌──────────────┐
                    │   DATABASE   │
                    │   projects   │
                    └──────────────┘
```

## Detailed File-by-File Flow

### 1️⃣ LAYER 1: UI Component
**File:** `components/tiles/ManageProjectsComponent.tsx`

```typescript
// User clicks "Projects List" tab
const loadProjects = async () => {
  const response = await fetch('/api/tiles', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      category: 'projects',    // ← Routes to projects handler
      action: 'list'           // ← Specifies operation
    })
  })
  const data = await response.json()
  setProjects(data.data)
}
```

**Responsibilities:**
- Display UI elements
- Handle form inputs
- Call API endpoints
- Update state with responses

---

### 2️⃣ LAYER 2: API Route
**File:** `app/api/tiles/route.ts`

```typescript
export const POST = async (request: NextRequest) => {
  const body = await request.json()
  
  // Route based on category
  if (body.category === 'projects') {
    const { handleProjects } = await import('@/app/api/projects/handler')
    
    if (body.action === 'list') {
      const data = await handleProjects('list', body.payload || {}, 'GET')
      return NextResponse.json({ success: true, data })
    }
    
    if (body.action === 'create') {
      const data = await handleProjects('create', body.payload, 'POST')
      return NextResponse.json({ success: true, data })
    }
    
    if (body.action === 'update') {
      const data = await handleProjects('update', body.payload, 'POST')
      return NextResponse.json({ success: true, data })
    }
    
    if (body.action === 'delete') {
      const data = await handleProjects('delete', body.payload, 'POST')
      return NextResponse.json({ success: true, data })
    }
  }
}
```

**Responsibilities:**
- Receive HTTP requests
- Parse request body
- Route to appropriate handler
- Return standardized responses

---

### 3️⃣ LAYER 3: Handler
**File:** `app/api/projects/handler.ts`

```typescript
import * as projectCrudService from '@/domains/projects/projectCrudService'

export async function handleProjects(action: string, body: any, method: string) {
  switch (action) {
    case 'list':
      return await projectCrudService.getAllProjects(body.companyId)
    
    case 'get':
      return await projectCrudService.getProjectById(body.id)
    
    case 'create':
      return await projectCrudService.createProject(body, body.userId)
    
    case 'update':
      return await projectCrudService.updateProject(body.id, body, body.userId)
    
    case 'delete':
      return await projectCrudService.deleteProject(body.id)
    
    default:
      return { action, message: `${action} functionality available` }
  }
}
```

**Responsibilities:**
- Orchestrate business operations
- Route actions to service methods
- Handle errors
- Return results

---

### 4️⃣ LAYER 4: Service
**File:** `domains/projects/projectCrudService.ts`

```typescript
import { createServiceClient } from '@/lib/supabase/server'

export async function getAllProjects(companyId?: string) {
  const supabase = await createServiceClient()
  
  let query = supabase
    .from('projects')
    .select(`
      *,
      company:company_code_id(company_code, company_name)
    `)
    .order('created_at', { ascending: false })
  
  if (companyId) {
    query = query.eq('company_code_id', companyId)
  }
  
  const { data, error } = await query
  
  if (error) throw error
  return data || []
}

export async function createProject(payload: any, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .insert({
      ...payload,
      created_by: userId
    })
    .select()
    .single()
  
  if (error) throw error
  return data
}

export async function updateProject(id: string, payload: any, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .update({
      ...payload,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single()
  
  if (error) throw error
  return data
}

export async function deleteProject(id: string) {
  const supabase = await createServiceClient()
  
  const { error } = await supabase
    .from('projects')
    .delete()
    .eq('id', id)
  
  if (error) throw error
  return { success: true }
}
```

**Responsibilities:**
- Implement business logic
- Database queries via Supabase
- Data validation
- Error handling

---

## Request/Response Flow Example

### Example: Create New Project

```
USER ACTION: Clicks "Create" button and submits form
    ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: ManageProjectsComponent.tsx                        │
│ components/tiles/ManageProjectsComponent.tsx                │
├─────────────────────────────────────────────────────────────┤
│ const handleSubmit = async (e) => {                         │
│   const response = await fetch('/api/tiles', {              │
│     method: 'POST',                                          │
│     body: JSON.stringify({                                   │
│       category: 'projects',                                  │
│       action: 'create',                                      │
│       payload: {                                             │
│         code: 'PRJ-001',                                     │
│         name: 'New Building',                                │
│         budget: 1000000                                      │
│       }                                                      │
│     })                                                       │
│   })                                                         │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
    ↓ HTTP POST /api/tiles
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: API Route                                          │
│ app/api/tiles/route.ts                                      │
├─────────────────────────────────────────────────────────────┤
│ export const POST = async (request) => {                    │
│   const body = await request.json()                         │
│   // body.category = 'projects'                             │
│   // body.action = 'create'                                 │
│                                                              │
│   if (body.category === 'projects') {                       │
│     const { handleProjects } = await import(                │
│       '@/app/api/projects/handler'                          │
│     )                                                        │
│     const data = await handleProjects(                      │
│       'create',                                             │
│       body.payload,                                         │
│       'POST'                                                │
│     )                                                        │
│     return NextResponse.json({ success: true, data })       │
│   }                                                          │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
    ↓ handleProjects('create', payload, 'POST')
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Handler                                            │
│ app/api/projects/handler.ts                                 │
├─────────────────────────────────────────────────────────────┤
│ export async function handleProjects(action, body, method) {│
│   switch (action) {                                         │
│     case 'create':                                          │
│       return await projectCrudService.createProject(        │
│         body,                                               │
│         body.userId                                         │
│       )                                                      │
│   }                                                          │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
    ↓ projectCrudService.createProject(payload, userId)
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Service                                            │
│ domains/projects/projectCrudService.ts                      │
├─────────────────────────────────────────────────────────────┤
│ export async function createProject(payload, userId) {      │
│   const supabase = await createServiceClient()             │
│                                                              │
│   const { data, error } = await supabase                    │
│     .from('projects')                                       │
│     .insert({                                               │
│       code: 'PRJ-001',                                      │
│       name: 'New Building',                                 │
│       budget: 1000000,                                      │
│       created_by: userId                                    │
│     })                                                       │
│     .select()                                               │
│     .single()                                               │
│                                                              │
│   if (error) throw error                                    │
│   return data                                               │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
    ↓ Database INSERT
┌─────────────────────────────────────────────────────────────┐
│ DATABASE: projects table                                    │
├─────────────────────────────────────────────────────────────┤
│ INSERT INTO projects (code, name, budget, created_by)       │
│ VALUES ('PRJ-001', 'New Building', 1000000, 'user-123')    │
│                                                              │
│ RETURNING *                                                  │
└─────────────────────────────────────────────────────────────┘
    ↓ Returns created project
    ↓ Layer 4 returns to Layer 3
    ↓ Layer 3 returns to Layer 2
    ↓ Layer 2 returns JSON response
    ↓ Layer 1 receives response
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Component updates state                            │
├─────────────────────────────────────────────────────────────┤
│ const data = await response.json()                          │
│ if (data.success) {                                          │
│   alert('Project created successfully!')                    │
│   setActiveTab('list')                                      │
│   loadProjects() // Refresh list                            │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
```

## File Structure Summary

```
Construction_App/
├── components/
│   └── tiles/
│       └── ManageProjectsComponent.tsx          [LAYER 1]
│
├── app/
│   └── api/
│       ├── tiles/
│       │   └── route.ts                         [LAYER 2]
│       └── projects/
│           └── handler.ts                       [LAYER 3]
│
└── domains/
    └── projects/
        └── projectCrudService.ts                [LAYER 4]
```

## Key Points

✅ **No Direct DB Access in UI:** Layer 1 only calls APIs
✅ **Centralized Routing:** Layer 2 routes all tile requests
✅ **Business Orchestration:** Layer 3 coordinates operations
✅ **Data Access:** Layer 4 is the only layer touching database
✅ **Consistent Pattern:** Same flow as Material Request and other tiles

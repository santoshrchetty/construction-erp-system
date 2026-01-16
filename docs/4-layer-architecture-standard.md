# 4-Layer Architecture Standard Reference

## Overview
This document defines the standard 4-layer architecture pattern used in our Next.js application with Supabase.

## Layer Structure

### Layer 1: API Layer (`/app/api/*/route.ts`)
**Responsibility**: HTTP request/response handling only
```typescript
// ✅ Correct - Only HTTP concerns
export async function POST(request: NextRequest) {
  const body = await request.json()
  const action = new URL(request.url).searchParams.get('action')
  
  if (action) {
    const result = await handleProjects(action, body, 'POST')
    return NextResponse.json({ success: true, data: result })
  }
  
  return NextResponse.json({ error: 'Action required' }, { status: 400 })
}
```

### Layer 2: Handler Layer (`/app/api/*/handler.ts`)
**Responsibility**: Business orchestration - delegates to appropriate services
```typescript
// ✅ Correct - Pure orchestration
export async function handleProjects(action: string, body: any, method: string = 'GET') {
  switch (action) {
    case 'create':
      return await projectCreationServices.createProject(body)
    case 'dashboard':
      return await projectFinanceServices.getProjectDashboardData(body.companyCode)
    default:
      return { error: 'Unknown action' }
  }
}
```

**❌ Avoid**: Direct database access, business logic, or data transformation

### Layer 3: Service Layer (`/domains/*/services/*.ts`)
**Responsibility**: Domain-specific business logic and data transformation
```typescript
// ✅ Correct - Business logic with repository usage
export async function getProjectDashboardData(companyCode: string = 'C001') {
  const projects = await getProjectSummary(companyCode)
  
  const totalProjects = projects.length
  const totalCosts = projects.reduce((sum, p: any) => sum + p.total_costs, 0)
  const totalRevenue = projects.reduce((sum, p: any) => sum + p.total_revenue, 0)
  
  return {
    summary: { totalProjects, totalCosts, totalRevenue },
    projects
  }
}
```

**Domain Separation**: 
- `projectFinanceServices.ts` - Financial operations only
- `projectCreationService.ts` - Creation operations only
- Each service handles one domain

### Layer 4: Repository Layer (`/domains/*/repositories/*.ts`)
**Responsibility**: Data access abstraction
```typescript
// ✅ Correct - Pure data access
export class ProjectRepository {
  async getUniversalJournalData(companyCode: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('universal_journal')
      .select('*')
      .eq('company_code', companyCode)
    
    if (error) throw error
    return data
  }
}
```

## Client Usage Standards

### Server-Side (API Routes, Services, Repositories)
```typescript
import { createServiceClient } from '@/lib/supabase/server'
const supabase = await createServiceClient() // Uses SERVICE_ROLE_KEY
```

### Client-Side (Components, Hooks)
```typescript
import { createClient } from '@/lib/supabase/client'
const supabase = createClient() // Uses ANON_KEY with RLS
```

## Key Principles

1. **Single Responsibility**: Each layer has one clear purpose
2. **Dependency Direction**: Upper layers depend on lower layers only
3. **Domain Separation**: Services are organized by business domain
4. **No Layer Skipping**: Each layer only calls the layer directly below
5. **Proper Client Usage**: Server client for backend, browser client for frontend

## Common Anti-Patterns to Avoid

❌ **Handler with business logic**
```typescript
// Wrong - business logic in handler
export async function handleProjects(action: string, body: any) {
  const supabase = await createServiceClient()
  const projects = await supabase.from('projects').select('*')
  const totalCosts = projects.reduce((sum, p) => sum + p.cost, 0) // Business logic
  return { totalCosts }
}
```

❌ **Service with direct HTTP calls**
```typescript
// Wrong - HTTP calls in service layer
export async function createProject(data: any) {
  const response = await fetch('/api/projects', { method: 'POST', body: JSON.stringify(data) })
  return response.json()
}
```

❌ **Mixed domain services**
```typescript
// Wrong - mixing finance and creation in same service
export async function getProjectDashboard() { /* finance logic */ }
export async function createProject() { /* creation logic */ }
```

## File Structure
```
app/
├── api/
│   └── projects/
│       ├── route.ts          # Layer 1: API
│       └── handler.ts        # Layer 2: Handler
domains/
└── projects/
    ├── repositories/
    │   └── projectRepository.ts    # Layer 4: Repository
    ├── projectFinanceServices.ts   # Layer 3: Finance Service
    └── projectCreationService.ts   # Layer 3: Creation Service
```

This architecture ensures maintainability, testability, and clear separation of concerns across the application.
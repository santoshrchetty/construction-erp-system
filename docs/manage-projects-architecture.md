# Manage Projects - Aligned Tile Architecture

## Folder Structure (Aligned with Other Tiles)

```
Construction_App/
├── components/
│   └── tiles/
│       ├── ManageProjectsComponent.tsx          ✅ Tile component
│       ├── UnifiedMaterialRequestComponent.tsx  (reference)
│       └── PurchaseOrderManagement.tsx          (reference)
├── app/
│   └── api/
│       ├── tiles/
│       │   └── route.ts                         ✅ Handles category: 'projects'
│       └── projects/
│           ├── route.ts                         ✅ Direct API (optional)
│           └── handler.ts                       ✅ Business orchestration
├── domains/
│   └── projects/
│       └── projectCrudService.ts                ✅ Business logic
└── database/
    └── fix-manage-projects-tile.sql             ✅ Tile configuration
```

## How It Works (Same as Other Tiles)

### 1. Dashboard Display
- Tile appears in `/dashboard` via `IndustrialDashboard.tsx`
- Fetches from `/api/tiles` (GET)
- No dedicated page route needed

### 2. Tile Click Behavior
- Opens `ManageProjectsComponent` in modal/panel
- Component located in `components/tiles/`
- Same pattern as Material Request, PO Management

### 3. API Flow
```
Component → /api/tiles (POST) → Handler → Service → Database
```

### 4. API Calls
```typescript
// List projects
fetch('/api/tiles', {
  method: 'POST',
  body: JSON.stringify({
    category: 'projects',
    action: 'list'
  })
})

// Create project
fetch('/api/tiles', {
  method: 'POST',
  body: JSON.stringify({
    category: 'projects',
    action: 'create',
    payload: { ...projectData }
  })
})
```

## 4-Layer Architecture

### Layer 1: UI Component
**File:** `components/tiles/ManageProjectsComponent.tsx`
- Tab-based interface (List/Create)
- Calls `/api/tiles` with category: 'projects'
- No direct database access

### Layer 2: API Route
**File:** `app/api/tiles/route.ts`
- Handles POST requests
- Routes `category: 'projects'` to projects handler
- Returns standardized response

### Layer 3: Handler
**File:** `app/api/projects/handler.ts`
- Orchestrates business logic
- Routes actions: list, create, update, delete
- Calls service layer

### Layer 4: Service
**File:** `domains/projects/projectCrudService.ts`
- Business logic implementation
- Direct Supabase database access
- CRUD operations

## Database Configuration

```sql
UPDATE tiles 
SET 
  title = 'Manage Projects',
  subtitle = 'Create, view, edit, and manage construction projects',
  icon = 'folder-open',
  construction_action = 'manage-projects'
WHERE construction_action = 'create-project';
```

## Key Differences from Initial Implementation

❌ **Before (Incorrect):**
- Had dedicated page route: `/app/projects/manage/page.tsx`
- Used separate API: `/api/projects`
- Component in `components/features/projects/`

✅ **After (Correct - Aligned):**
- No dedicated page route
- Uses `/api/tiles` with category routing
- Component in `components/tiles/`
- Same pattern as all other tiles

## Comparison with Other Tiles

| Aspect | Material Request | Manage Projects | Aligned? |
|--------|-----------------|-----------------|----------|
| Component Location | `components/tiles/` | `components/tiles/` | ✅ |
| API Endpoint | `/api/tiles` | `/api/tiles` | ✅ |
| Category | `materials` | `projects` | ✅ |
| Has Page Route | ❌ No | ❌ No | ✅ |
| Tab Interface | ✅ Yes | ✅ Yes | ✅ |
| Handler Layer | ✅ Yes | ✅ Yes | ✅ |
| Service Layer | ✅ Yes | ✅ Yes | ✅ |

## Standards Compliance

✅ **Folder Structure:** Component in `components/tiles/`
✅ **API Pattern:** Uses `/api/tiles` with category routing
✅ **No Page Route:** Opens from dashboard, not standalone page
✅ **4-Layer Architecture:** UI → API → Handler → Service
✅ **Consistent Naming:** ManageProjectsComponent.tsx
✅ **Tab Interface:** List/Create tabs like other tiles

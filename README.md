# Construction Management SaaS

A comprehensive construction project management system built with TypeScript, Supabase, and modern web technologies.

## Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Set up Supabase
1. Create a new Supabase project at https://supabase.com
2. Run the database schema from `database/schema.sql` in your Supabase SQL editor
3. Copy your project URL and API keys

### 3. Environment Variables
```bash
cp .env.example .env.local
```

Fill in your Supabase credentials:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 4. Generate Types (Optional)
If you make schema changes, regenerate types:
```bash
npx supabase gen types typescript --project-id YOUR_PROJECT_ID > types/supabase/database.types.ts
```

## Usage

### Basic Repository Usage
```typescript
import { repositories } from './lib/repositories'

// Create a project
const project = await repositories.projects.create({
  name: 'New Project',
  code: 'PROJ-001',
  project_type: 'commercial',
  start_date: '2024-01-01',
  planned_end_date: '2024-12-31',
  budget: 1000000
})

// Find active projects
const activeProjects = await repositories.projects.findActiveProjects()

// Create WBS structure
const wbsNode = await repositories.wbs.create({
  project_id: project.id,
  code: 'WBS-01',
  name: 'Phase 1',
  node_type: 'phase',
  level: 1,
  sequence_order: 1
})
```

### Type-Safe Operations
All operations are fully type-safe with Zod validation:

```typescript
import { CreateProjectSchema } from './types'

// Validate input
const projectData = CreateProjectSchema.parse({
  name: 'Test Project',
  code: 'TEST-001',
  // ... other fields
})

// Create with validated data
const project = await repositories.projects.create(projectData)
```

## Architecture

### Database Schema
- **Projects**: Central project management
- **WBS Nodes**: Hierarchical work breakdown structure
- **Activities**: Work groupings under WBS nodes
- **Tasks**: Granular work items with dependencies
- **Vendors**: Supplier management
- **Purchase Orders**: Procurement tracking
- **Stores**: Inventory management
- **Timesheets**: Time tracking and approvals

### Type System
- **Supabase Types**: Auto-generated from database schema
- **Zod Schemas**: Runtime validation and type inference
- **Repository Pattern**: Business logic and data access layer

### Key Features
- Full TypeScript type safety
- Hierarchical WBS structure
- Task dependency management
- Purchase order lifecycle
- Inventory tracking
- Time tracking with approvals
- Cost management integration

## File Structure
```
├── database/
│   ├── schema.sql              # Complete database schema
│   ├── relationships.md        # ERD documentation
│   └── construction_erd.drawio # Visual ERD
├── types/
│   ├── supabase/              # Generated Supabase types
│   ├── schemas/               # Zod validation schemas
│   ├── repositories/          # Repository classes
│   └── index.ts               # Type exports
├── lib/
│   ├── supabase.ts            # Supabase client
│   └── repositories.ts       # Repository instances
└── examples/
    └── usage.ts               # Usage examples
```

## Next Steps
1. Set up your Supabase project
2. Run the database schema
3. Configure environment variables
4. Start building your application with type-safe repositories
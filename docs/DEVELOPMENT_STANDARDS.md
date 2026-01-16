# Development Standards & Guidelines

## 4-Layer Architecture Compliance

All new features MUST follow the established 4-layer architecture pattern.

### Layer 1: Presentation Layer
**Location**: `app/`, `components/`

**Rules**:
- Components only handle UI logic and user interactions
- NO direct database calls or business logic
- Use services through proper imports
- Handle loading states and error display

**Example**:
```typescript
// ✅ CORRECT
import { ProjectService } from '@/domains/projects'

export function ProjectForm() {
  const handleSubmit = async (data) => {
    await ProjectService.createProject(data) // Through business layer
  }
}

// ❌ WRONG
import { repositories } from '@/lib/repositories'

export function ProjectForm() {
  const handleSubmit = async (data) => {
    await repositories.projects.create(data) // Skipping business layer
  }
}
```

### Layer 2: Business Logic Layer
**Location**: `domains/`, `lib/services/`

**Rules**:
- All business rules and validation logic
- Coordinate between multiple repositories
- Handle complex calculations and workflows
- NO direct UI concerns

**Structure**:
```
domains/
├── [domain]/
│   ├── [Domain]Service.ts     # Main service class
│   ├── types.ts               # Domain-specific types
│   ├── validation.ts          # Business rules
│   └── index.ts               # Exports
```

**Example**:
```typescript
// domains/projects/ProjectService.ts
export class ProjectService {
  static async createProject(data: CreateProjectRequest): Promise<Project> {
    // 1. Validate business rules
    await this.validateProjectData(data)
    
    // 2. Generate project code
    const code = await this.generateProjectCode(data.company_code)
    
    // 3. Check budget authorization
    await this.checkBudgetAuthorization(data.budget)
    
    // 4. Create through repository
    return await repositories.projects.create({ ...data, code })
  }
}
```

### Layer 3: Data Access Layer
**Location**: `types/repositories/`

**Rules**:
- Extend BaseRepository for common operations
- Domain-specific query methods only
- NO business logic or validation
- Type-safe database operations

**Template**:
```typescript
// types/repositories/[entity].repository.ts
export class [Entity]Repository extends BaseRepository<'[table_name]'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, '[table_name]')
  }

  async findBySpecificCriteria(criteria: string): Promise<EntityRow[]> {
    const { data, error } = await this.supabase
      .from('[table_name]')
      .select('*')
      .eq('criteria_field', criteria)

    if (error) throw error
    return data || []
  }
}
```

### Layer 4: Database Layer
**Location**: `database/`

**Rules**:
- SQL migrations in proper sequence
- Database functions for complex operations
- RLS policies for security
- Triggers for data integrity

## Code Implementation Standards

### Minimal Code Principle

**CRITICAL RULE**: Write only the ABSOLUTE MINIMAL amount of code needed to address the requirement correctly.

**Implementation Guidelines**:
- Avoid verbose implementations that don't directly contribute to the solution
- Focus on the specific requirement without adding unnecessary features
- Eliminate redundant code, excessive comments, or over-engineering
- Prioritize clarity and directness over comprehensive coverage
- Only implement what is explicitly requested or essential for functionality

**Examples**:
```typescript
// ✅ CORRECT: Minimal, focused implementation
export function updateProjectStatus(id: string, status: string) {
  return repositories.projects.update(id, { status })
}

// ❌ WRONG: Over-engineered with unnecessary features
export function updateProjectStatus(
  id: string, 
  status: string, 
  options?: {
    validateStatus?: boolean,
    auditLog?: boolean,
    notifications?: boolean,
    rollback?: boolean
  }
) {
  // Extensive validation logic...
  // Audit logging system...
  // Notification system...
  // Rollback mechanism...
  return repositories.projects.update(id, { status })
}
```

**Enforcement**:
- Code reviews MUST check for unnecessary complexity
- Reject implementations that exceed requirement scope
- Prefer simple, direct solutions over comprehensive frameworks
- Only add features when explicitly requested by user

### Server-Side Code Generation

**CRITICAL RULE**: All code generation (project codes, activity codes, WBS codes, etc.) MUST happen server-side in the service layer.

**Why Server-Side Generation**:

**1. Security**
- Database credentials protected - client never has direct database access
- Business logic hidden - code generation rules not exposed to browser
- Prevents tampering - users can't manipulate code generation in DevTools

**2. Data Integrity**
- Single source of truth - server has authoritative view of existing codes
- Race condition prevention - server handles concurrent requests properly
- Atomic operations - code generation + insertion happens in one transaction
- No duplicate codes - server ensures uniqueness before committing

**3. Performance**
- Reduced client bundle - no database client library in browser
- Faster page loads - less JavaScript to parse and execute
- Better caching - API responses can be cached at CDN/proxy level

**4. Consistency**
- Centralized logic - one place to update code generation rules
- Uniform behavior - all clients (web, mobile, API) use same logic
- Easier testing - test once on server vs. multiple client platforms

**5. Reliability**
- No client-side failures - network issues don't break code generation
- Proper error handling - server can retry database queries
- Transaction support - rollback if code generation or insert fails

**Race Condition Example**:
```typescript
// ❌ CLIENT-SIDE PROBLEM:
// User A: Queries DB → Sees 3 activities → Generates "A04"
// User B: Queries DB → Sees 3 activities → Generates "A04" (same time)
// User A: Inserts "A04" → Success
// User B: Inserts "A04" → DUPLICATE ERROR ❌

// ✅ SERVER-SIDE SOLUTION:
// User A: Sends data → Server locks → Queries → Generates "A04" → Inserts → Unlocks
// User B: Sends data → Server locks → Queries → Generates "A05" → Inserts → Unlocks
// Both succeed ✅
```

**Implementation Pattern**:

```typescript
// ❌ WRONG: Client-side code generation
// components/ActivityForm.tsx
import { supabase } from '@/lib/supabase/client'

const handleSubmit = async () => {
  // Client queries database
  const { data: activities } = await supabase
    .from('activities')
    .select('code')
    .eq('wbs_node_id', wbsNodeId)
  
  // Client generates code
  const nextCode = `${wbsCode}-A${String(activities.length + 1).padStart(2, '0')}`
  
  // Client sends code to API
  await fetch('/api/activities', {
    method: 'POST',
    body: JSON.stringify({ ...data, code: nextCode })
  })
}

// ✅ CORRECT: Server-side code generation
// components/ActivityForm.tsx
const handleSubmit = async () => {
  // Client sends only business data (NO code)
  await fetch('/api/activities', {
    method: 'POST',
    body: JSON.stringify(data) // No code field
  })
}

// domains/wbs/wbsServices.ts
export class WBSService {
  async createActivity(data: Omit<Activity, 'id' | 'code'>): Promise<Activity> {
    // Server generates code atomically
    const code = await this.generateActivityCode(data.project_id, data.wbs_node_id)
    
    // Server inserts with generated code
    return this.repository.createActivity({ ...data, code })
  }
  
  private async generateActivityCode(projectId: string, wbsNodeId: string): Promise<string> {
    const wbsNode = await this.repository.getWBSNodeById(wbsNodeId)
    const activities = await this.repository.getActivitiesByWBSNode(wbsNodeId)
    return `${wbsNode.code}-A${String(activities.length + 1).padStart(2, '0')}`
  }
}
```

**Enforcement Rules**:
1. **Client components** MUST NOT generate codes - only send business data
2. **Service layer** MUST handle all code generation logic
3. **Code generation** MUST happen in same transaction as data insertion
4. **Repository layer** MUST provide helper methods for code generation queries
5. **API routes** MUST NOT accept codes from client - service generates them

**Migration Checklist**:
- [ ] Remove client-side code generation functions
- [ ] Remove code field from client forms
- [ ] Add code generation to service layer
- [ ] Update API to reject client-provided codes
- [ ] Test concurrent requests for race conditions

**This Prevents**:
- Duplicate codes from race conditions
- Security vulnerabilities from exposed database access
- Client-side failures breaking code generation
- Inconsistent code formats across different clients
- Performance issues from large client bundles

## Standardization Rules

### 1. Naming Conventions

**Files**:
- Components: `PascalCase.tsx` (e.g., `ProjectForm.tsx`)
- Services: `PascalCase.ts` (e.g., `ProjectService.ts`)
- Repositories: `camelCase.repository.ts` (e.g., `projects.repository.ts`)
- Types: `camelCase.ts` (e.g., `project.types.ts`)

**Folders**:
- Domain folders: `lowercase` (e.g., `projects/`, `procurement/`)
- Component folders: `lowercase` (e.g., `forms/`, `dashboards/`)

**Variables & Functions**:
- `camelCase` for variables and functions
- `PascalCase` for classes and interfaces
- `UPPER_SNAKE_CASE` for constants

### 2. File Organization

**Domain Service Structure**:
```
domains/[domain]/
├── [Domain]Service.ts         # Main service class
├── types.ts                   # Domain types
├── validation.ts              # Business rules
├── constants.ts               # Domain constants
└── index.ts                   # Clean exports
```

**Repository Structure**:
```
types/repositories/
├── base.repository.ts         # Base class
├── [entity].repository.ts     # Entity repositories
└── index.ts                   # Export all repositories
```

### 3. Import Standards

**Layer Communication Rules**:
```typescript
// ✅ ALLOWED: Higher layer importing lower layer
// Presentation → Business
import { ProjectService } from '@/domains/projects'

// Business → Data Access
import { repositories } from '@/lib/repositories'

// ❌ FORBIDDEN: Lower layer importing higher layer
// Repository importing Service (NEVER)
// Service importing Component (NEVER)
```

**Import Organization**:
```typescript
// 1. External libraries
import { NextRequest } from 'next/server'
import { z } from 'zod'

// 2. Internal types
import { Database } from '@/types/supabase/database.types'

// 3. Services/Repositories
import { ProjectService } from '@/domains/projects'

// 4. Components (presentation layer only)
import { Button } from '@/components/ui/button'
```

### 4. Error Handling Standards

**Service Layer**:
```typescript
export class ProjectService {
  static async createProject(data: CreateProjectRequest): Promise<Project> {
    try {
      // Business logic
      return await repositories.projects.create(data)
    } catch (error) {
      // Log error with context
      logger.error('Project creation failed', { data, error })
      
      // Throw business-friendly error
      throw new BusinessError('Failed to create project', 'PROJECT_CREATE_FAILED')
    }
  }
}
```

**Repository Layer**:
```typescript
export class ProjectRepository extends BaseRepository<'projects'> {
  async findByCode(code: string): Promise<ProjectRow | null> {
    const { data, error } = await this.supabase
      .from('projects')
      .select('*')
      .eq('code', code)
      .single()

    if (error) throw error // Let service layer handle business context
    return data
  }
}
```

### 5. Type Safety Standards

**Zod Schemas**:
```typescript
// types/schemas/project.schema.ts
export const CreateProjectSchema = z.object({
  name: z.string().min(1).max(255),
  code: z.string().regex(/^[A-Z]{3}-\d{4}-\d{3}$/),
  project_type: z.enum(['residential', 'commercial', 'infrastructure']),
  budget: z.number().positive(),
  start_date: z.string().datetime(),
  planned_end_date: z.string().datetime()
})

export type CreateProject = z.infer<typeof CreateProjectSchema>
```

**Service Validation**:
```typescript
export class ProjectService {
  static async createProject(data: unknown): Promise<Project> {
    // Always validate input
    const validatedData = CreateProjectSchema.parse(data)
    
    // Business logic with type safety
    return await repositories.projects.create(validatedData)
  }
}
```

## Development Workflow

### Change Management Best Practices

**CRITICAL RULE: Always Read Before Writing**

**Problem Prevention**: Avoid overwriting existing configurations, assuming tech stack, or creating unnecessary files.

**Mandatory Steps Before Any Changes**:
1. **Read existing files first** - Use `fsRead` to understand current setup
2. **Check project context** - Review imports, dependencies, existing patterns
3. **Ask clarifying questions** - "Which database?" instead of assuming
4. **Make minimal changes only** - Change what's directly needed for the specific issue

**Example - WRONG Approach**:
```
User: "remove mock and use database"
❌ Assume PostgreSQL → Create new connection → Overwrite .env → Create package.json
Result: 4 files changed, existing Supabase config lost
```

**Example - CORRECT Approach**:
```
User: "remove mock and use database"
✅ Read DatabaseConnection.ts → See mock data → Read .env → See Supabase → Replace mock only
Result: 1 file changed, existing config preserved
```

**Enforcement Rules**:
- **NEVER create new files** without reading existing setup first
- **NEVER overwrite .env files** without checking current values
- **NEVER assume tech stack** - always verify from existing code
- **ALWAYS make incremental changes** - one small change at a time
- **ALWAYS test each change** before proceeding to next

**Red Flags That Indicate Wrong Approach**:
- Creating multiple new files for simple request
- Changing environment variables without reading current ones
- Switching tech stack (PostgreSQL → Supabase) without user request
- Making assumptions about database, framework, or architecture

**Questions to Ask Before Major Changes**:
- "Should I check existing configuration first?"
- "What database/framework are you currently using?"
- "Do you want me to read the current setup before making changes?"

**This prevents**:
- Lost credentials and configuration
- Unnecessary file creation
- Tech stack confusion
- Breaking existing functionality
- Violating minimal code principle

### 1. New Feature Development

**Step 1: Define Types**
```typescript
// types/schemas/[feature].schema.ts
export const [Feature]Schema = z.object({...})
export type [Feature] = z.infer<typeof [Feature]Schema>
```

**Step 2: Create Repository**
```typescript
// types/repositories/[feature].repository.ts
export class [Feature]Repository extends BaseRepository<'[table]'> {
  // Domain-specific queries only
}
```

**Step 3: Implement Service**
```typescript
// domains/[domain]/[Feature]Service.ts
export class [Feature]Service {
  // Business logic and validation
}
```

**Step 4: Create Components**
```typescript
// components/[feature]/[Feature]Form.tsx
// Use services, not repositories
```

**Step 5: Add API Routes**
```typescript
// app/api/[feature]/route.ts
// Thin controllers calling services
```

### 2. Code Review Checklist

**Architecture Compliance**:
- [ ] No layer skipping (presentation → business → data → database)
- [ ] Business logic in service layer, not components
- [ ] Repository only contains data access logic
- [ ] Proper error handling at each layer

**Standardization**:
- [ ] Naming conventions followed
- [ ] File organization matches standards
- [ ] Import order and rules followed
- [ ] Type safety with Zod validation

**Quality**:
- [ ] No hardcoded values
- [ ] Proper error messages
- [ ] Logging for debugging
- [ ] Unit tests for business logic

## Examples to Follow

**✅ Excellent Implementation**:
- `domains/procurement/createPurchaseOrder.ts` - Full business logic
- `lib/services/ctc.service.ts` - Complex calculations
- `types/repositories/projects.repository.ts` - Clean data access

**⚠️ Needs Improvement**:
- `domains/projects/projectServices.ts` - Mock implementations
- `examples/usage.ts` - Direct repository usage

## Tile Component Standards

### Title Duplication Prevention

**CRITICAL RULE**: Components MUST NOT contain hardcoded titles that duplicate tile titles from the database.

**Standard Pattern**:
- **Tiles provide titles** from database (`tiles.title` field)
- **Components have NO hardcoded titles** in JSX
- **EnhancedConstructionTiles.tsx** displays tile title in header
- **Components focus on functionality only**

### Component File Naming Convention

**CRITICAL RULE**: Component files MUST match the exact `construction_action` value from the tiles table.

**Tile System Mapping**:
```
tiles.construction_action → components/tiles/{construction_action}.tsx
```

**Example**:
- **Database**: `construction_action: "approval-configuration"`
- **Required File**: `components/tiles/approval-configuration.tsx`
- **Component Export**: `ApprovalConfigurationComponent`

**Common Mistakes**:
```typescript
// ❌ WRONG: File name doesn't match construction_action
// File: ApprovalConfiguration.tsx
// Database: construction_action: "approval-configuration"

// ❌ WRONG: CamelCase instead of kebab-case
// File: approvalConfiguration.tsx
// Database: construction_action: "approval-configuration"

// ✅ CORRECT: Exact match
// File: approval-configuration.tsx
// Database: construction_action: "approval-configuration"
```

**Debugging Steps**:
1. **Check construction_action**: `SELECT construction_action FROM tiles WHERE title = 'Your Tile'`
2. **Create matching file**: `components/tiles/{construction_action}.tsx`
3. **Export component**: Use PascalCase for component name
4. **Test loading**: Click tile to verify component loads

**Root Cause Prevention**:
- Always check `construction_action` before creating components
- Use exact kebab-case file naming
- Avoid creating multiple component versions
- Test tile loading immediately after component creation

**✅ CORRECT Pattern** (Chart of Accounts style):
```typescript
export function ChartOfAccounts() {
  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        {/* NO hardcoded title here */}
        <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center">
            <Icons.FileText className="w-5 h-5 text-blue-600 mr-2" />
            <div>
              <p className="text-sm text-blue-600">Manage chart of accounts and GL structure</p>
            </div>
          </div>
        </div>
        {/* Component functionality */}
      </div>
    </div>
  )
}
```

**❌ WRONG Pattern** (Title Duplication):
```typescript
export function MaterialMaster() {
  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        {/* ❌ NEVER do this - duplicates database title */}
        <h2 className="text-xl font-semibold mb-4">Material Master</h2>
        <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center">
            <Icons.Package className="w-5 h-5 text-blue-600 mr-2" />
            <div>
              {/* ❌ NEVER do this either */}
              <h4 className="text-sm font-medium text-blue-800">Material Master</h4>
              <p className="text-sm text-blue-600">Manage materials</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
```

**Why This Matters**:
- **Prevents title duplication** (database title + component title)
- **Ensures consistency** between tiles and components
- **Reduces maintenance** - titles updated in one place only
- **Follows established pattern** used by all existing tiles

**Implementation**:
1. **Database tiles** contain the authoritative title in `tiles.title`
2. **EnhancedConstructionTiles.tsx** displays this title in the header when component loads
3. **Components** contain only description text, no titles
4. **All existing tiles** follow this pattern (Chart of Accounts, Cost Center Accounting, etc.)

**Enforcement**:
- All new tile components MUST follow this pattern
- Code reviews MUST check for hardcoded titles
- Any hardcoded titles in components are considered bugs

## UI/UX Standards

### Search and Modal Interface Standards

**CRITICAL RULE**: Search interfaces and modals MUST provide optimal user experience with proper sizing and functionality.

**Search Functionality Standards**:

**1. Dual Search Pattern** (SAP MM02 Style):
```typescript
// ✅ CORRECT: Provide both direct and parameter-based search
// Direct Code Search - for known material codes
<input 
  placeholder="Enter Material Code"
  value={searchCode}
  onChange={(e) => setSearchCode(e.target.value.toUpperCase())}
/>

// Parameter Search - for unknown codes
<input 
  placeholder="Enter material name..."
  value={searchParams.material_name}
  onChange={(e) => setSearchParams(prev => ({ ...prev, material_name: e.target.value }))}
/>
```

**2. Precise Search Logic**:
```typescript
// ✅ CORRECT: Search specific fields to avoid false matches
if (searchTerm) {
  query = query.ilike('material_name', `%${searchTerm}%`) // Only material name
}

// ❌ WRONG: OR condition across multiple fields causes false matches
query = query.or(`material_code.ilike.%${searchTerm}%,material_name.ilike.%${searchTerm}%,description.ilike.%${searchTerm}%`)
```

**3. Search Results Modal Sizing**:
```typescript
// ✅ CORRECT: Large modal for better visibility
<div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
  <div className="bg-white rounded-lg p-6 max-w-6xl w-full mx-4 max-h-[80vh] overflow-y-auto">
    {/* Search results table */}
  </div>
</div>

// ❌ WRONG: Small modal limits visibility
<div className="max-w-4xl max-h-96"> {/* Too small */}
```

**Modal Size Standards**:
- **Width**: `max-w-6xl` for search results, `max-w-4xl` for forms
- **Height**: `max-h-[80vh]` for data tables, `max-h-[70vh]` for forms
- **Margins**: Always include `mx-4` for mobile compatibility
- **Overflow**: Use `overflow-y-auto` for scrollable content

**Search Interface Layout**:
```typescript
// ✅ CORRECT: Organized search sections
<div className="mb-6 p-4 bg-gray-50 rounded-lg">
  <h3 className="text-md font-medium text-gray-900 mb-4">Search Material</h3>
  
  {/* Direct Code Search */}
  <div className="mb-4 p-3 bg-white rounded border">
    <label className="block text-sm font-medium text-gray-700 mb-2">Direct Material Code Search</label>
    {/* Direct search inputs */}
  </div>

  {/* Parameter-based Search */}
  <div className="p-3 bg-white rounded border">
    <label className="block text-sm font-medium text-gray-700 mb-2">Search by Parameters</label>
    {/* Parameter search inputs */}
  </div>
</div>
```

**Search Results Table**:
```typescript
// ✅ CORRECT: Professional table with selection
<table className="min-w-full divide-y divide-gray-200">
  <thead className="bg-gray-50">
    <tr>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Action</th>
    </tr>
  </thead>
  <tbody className="bg-white divide-y divide-gray-200">
    {searchResults.map((item, index) => (
      <tr key={index} className="hover:bg-gray-50">
        <td className="px-4 py-4 text-sm font-medium text-gray-900">{item.code}</td>
        <td className="px-4 py-4 text-sm text-gray-900">{item.name}</td>
        <td className="px-4 py-4 text-center">
          <button 
            onClick={() => selectItem(item.code)}
            className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-sm hover:bg-blue-200"
          >
            Select
          </button>
        </td>
      </tr>
    ))}
  </tbody>
</table>
```

**Dynamic Dropdown Population**:
```typescript
// ✅ CORRECT: Load dependent dropdowns based on selection
const handleCategoryChange = async (categoryCode) => {
  setFormData(prev => ({ ...prev, category: categoryCode, material_group: '' }))
  if (categoryCode) {
    await loadGroups(categoryCode) // Load dependent data
  } else {
    setGroups([]) // Clear dependent data
  }
}
```

**Form Population Pattern**:
```typescript
// ✅ CORRECT: Populate all fields and dependent dropdowns
const searchMaterial = async (code) => {
  const material = await fetchMaterial(code)
  
  // Populate form data
  setFormData({
    material_name: material.material_name || '',
    category: material.category || '',
    // ... all fields
  })
  
  // Load dependent dropdowns
  if (material.category) {
    await loadGroups(material.category)
  }
}
```

**Enforcement Rules**:
1. **Search interfaces** MUST provide both direct and parameter-based options
2. **Modals** MUST use appropriate sizing (6xl width, 80vh height for data)
3. **Search logic** MUST be precise to avoid false matches
4. **Dependent dropdowns** MUST populate automatically based on data
5. **Tables** MUST include hover effects and clear selection buttons

## Database Standards

### Tile Management Standards

**CRITICAL RULE**: All tile insertion scripts MUST prevent duplicates to avoid UI issues.

**Problem**: Multiple script executions create duplicate tiles, causing:
- **Duplicate tiles in UI** (same tile appears multiple times)
- **Authorization conflicts** (multiple tiles with same auth_object)
- **Database integrity issues** (redundant data)
- **User confusion** (identical functionality in multiple tiles)

**Standard Pattern**:
```sql
-- ✅ CORRECT: UPSERT Pattern with Duplicate Prevention
-- 1. Add unique constraint (run once)
ALTER TABLE tiles ADD CONSTRAINT unique_construction_action UNIQUE (construction_action);

-- 2. Use INSERT ... ON CONFLICT for all tile operations
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
('Tile Name', 'Description', 'icon', 'MODULE', 'unique-action', '/route', 'Category', 'AUTH_OBJECT')
ON CONFLICT (construction_action) 
DO UPDATE SET 
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  icon = EXCLUDED.icon,
  module_code = EXCLUDED.module_code,
  route = EXCLUDED.route,
  tile_category = EXCLUDED.tile_category,
  auth_object = EXCLUDED.auth_object;
```

**❌ WRONG Pattern** (Creates Duplicates):
```sql
-- ❌ NEVER do this - creates duplicates on multiple runs
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
('Tile Name', 'Description', 'icon', 'MODULE', 'action', '/route', 'Category', 'AUTH_OBJECT');
```

**Duplicate Detection Script**:
```sql
-- Check for duplicate tiles
SELECT title, COUNT(*) as count
FROM tiles 
GROUP BY title
HAVING COUNT(*) > 1;

-- Check for construction_action conflicts
SELECT construction_action, COUNT(*) as count, STRING_AGG(title, ', ') as titles
FROM tiles 
GROUP BY construction_action
HAVING COUNT(*) > 1;
```

**Cleanup Script Template**:
```sql
-- Remove duplicates (keep latest)
DELETE FROM tiles 
WHERE id NOT IN (
  SELECT MAX(id) 
  FROM tiles 
  GROUP BY construction_action
);
```

**Prevention Rules**:
1. **Always use UPSERT** pattern for tile insertion
2. **Add unique constraints** on critical fields (`construction_action`)
3. **Test scripts multiple times** to ensure no duplicates
4. **Validate before deployment** using duplicate detection queries

**Enforcement**:
- All tile scripts MUST use ON CONFLICT pattern
- Code reviews MUST check for duplicate prevention
- Database migrations MUST include constraint creation
- Any duplicate tiles in production are considered critical bugs

## Enforcement

All pull requests MUST:
1. Follow 4-layer architecture
2. Meet standardization requirements
3. Include proper error handling
4. Have type safety with validation
5. Pass architecture compliance review

**No exceptions** - maintaining architectural integrity is critical for long-term maintainability.
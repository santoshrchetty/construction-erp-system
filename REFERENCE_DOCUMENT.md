# Construction App Reference Document

## Conversation Summary
- **Dashboard Component Redundancy**: Identified that both `IndustrialDashboard.tsx` and `FioriDashboard.tsx` serve similar purposes, with IndustrialDashboard being more feature-rich. Successfully switched from FioriDashboard to IndustrialDashboard in the dashboard route.
- **4-Layer Architecture Migration**: Initiated migration from direct service calls to proper API routes to follow 4-layer architecture principles. Created API routes for projects, approvals, number-ranges, and purchase-orders.
- **Component Migration**: Successfully migrated NumberRangeMaintenance component from direct service imports to API calls, demonstrating the migration pattern.
- **Supabase Client Architecture Issues**: Discovered and fixed critical security and architectural issues with Supabase client usage, separating client-side and server-side implementations.
- **Next.js 15 Compatibility**: Resolved cookies API compatibility issues by making createServiceClient async to handle the new cookies() Promise API.

## Files and Code Summary
- **`/app/dashboard/page.tsx`**: Updated to use IndustrialDashboard instead of FioriDashboard
- **`/components/permissions/FioriDashboard.tsx`**: Commented out as redundant, simpler dashboard with basic tile grid
- **`/components/permissions/IndustrialDashboard.tsx`**: Modern dashboard with search, filtering, mobile-optimized design, and enhanced UX features
- **`/components/tiles/NumberRangeMaintenance.tsx`**: Migrated from direct service imports to API calls, demonstrating proper 4-layer architecture
- **`/lib/supabase/client.ts`**: Contains browser client for auth operations only
- **`/lib/supabase/server.ts`**: Contains async createServiceClient for server-side operations with proper cookies handling
- **`/app/api/projects/route.ts`**: Created API route for project management operations
- **`/app/api/approvals/route.ts`**: Created API route for approval workflows
- **`/app/api/number-ranges/route.ts`**: Created API route for number range maintenance
- **`/lib/services/authorizationRepository.ts`**: Updated to use async client initialization pattern
- **`/lib/authMiddleware.ts`**: Fixed to use proper async createServiceClient calls

## Key Insights
- **ARCHITECTURE**: The application was violating 4-layer architecture by having components directly import and use service files that contained database logic
- **SECURITY**: Original implementation exposed service role keys to browser clients, creating major security vulnerability
- **MIGRATION PATTERN**: Established pattern for migrating components: remove service imports, add local types, replace service calls with fetch to API routes
- **NEXT.JS 15**: cookies() API now returns Promise and must be awaited, requiring async createServiceClient function
- **DASHBOARD PREFERENCE**: IndustrialDashboard provides better UX with search, filtering, and modern design compared to basic FioriDashboard

## Development Guidelines

### Code Implementation Standards
- **MINIMAL CODE PRINCIPLE**: Write only the ABSOLUTE MINIMAL amount of code needed to address the requirement correctly
- **AVOID VERBOSITY**: Avoid verbose implementations and any code that doesn't directly contribute to the solution
- **FOCUSED SOLUTIONS**: Each implementation should directly address the specific requirement without unnecessary additions

### Architecture Patterns
- **4-Layer Architecture**: Components → API Routes → Services → Database
- **Security**: Never expose service role keys to browser clients
- **Async Patterns**: Use async/await for all Supabase operations due to Next.js 15 cookies API

### Migration Patterns
1. Remove direct service imports from components
2. Add local type definitions
3. Replace service calls with fetch to API routes
4. Ensure proper error handling

## Most Recent Topic
**Topic**: Database Relationship Fix & Codebase Cleanup

**Progress**: Fixed database relationship error in WorkflowRepository and cleaned up redundant files:

**Database Fix**:
- **Issue**: `workflow_instances` table trying to join with `org_hierarchy` using non-existent foreign key
- **Error**: "Could not find a relationship between 'workflow_instances' and 'org_hierarchy' in the schema cache"
- **Solution**: Removed problematic join `org_hierarchy!workflow_instances_requester_id_fkey (employee_name)` from `getActiveWorkflows` query
- **Impact**: Approval configuration components now load without database errors

**Codebase Cleanup**:
- ✅ Deleted `/components/permissions/FioriDashboard.tsx` (commented out, replaced by IndustrialDashboard)
- ✅ Deleted entire `/components/archive/` directory with 5 outdated approval configuration files
- ✅ Removed redundant components that were causing confusion
- **Result**: Cleaner codebase with clear component structure

**Tools Used**:
- **fsReplace**: Fixed WorkflowRepository.getActiveWorkflows() method to remove problematic database join
- **executeBash**: Deleted 6 redundant files and empty archive directory

## Design Changes & Database Schema Notes

### **Database Relationship Issues**
- **workflow_instances.requester_id** → **org_hierarchy.employee_id**: Foreign key relationship doesn't exist in current schema
- **Workaround**: Removed employee name display from workflow instances to avoid join errors
- **Future Fix**: Either create proper foreign key relationship or handle employee lookup separately

### **Component Architecture Decisions**
- **Dashboard Strategy**: IndustrialDashboard chosen over FioriDashboard for better UX (search, filtering, mobile-optimized)
- **Approval Components**: Migrated to API-based architecture, removed direct service imports
- **File Organization**: Removed archive directory, consolidated similar components
- **Permission System Clarity**: Renamed `/components/permissions/` → `/components/ui-permissions/` to distinguish from `/lib/permissions/` (business logic)

### **API Design Patterns**
- **Approval API**: Single `/api/approvals` endpoint with action-based routing
- **Error Handling**: Database errors caught and handled gracefully without breaking UI
- **Query Optimization**: Removed complex joins that cause schema cache issues
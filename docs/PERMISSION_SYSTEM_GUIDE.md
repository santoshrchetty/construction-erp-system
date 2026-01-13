# Construction Management SaaS - Permission System Usage Guide

## Integration Instructions

### 1. Wrap your app with PermissionProvider

```tsx
// app/layout.tsx
import { PermissionProvider } from '@/components/permissions/PermissionContext'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>
          <PermissionProvider>
            {children}
          </PermissionProvider>
        </AuthProvider>
      </body>
    </html>
  )
}
```

### 2. Run the RLS setup

```bash
# Execute the RLS policies in your Supabase project
psql -h your-host -d your-db -f database/permissions_rls.sql
```

## Usage Examples

### Check Permissions in Components

```tsx
import { usePermission } from '@/lib/permissions/hooks'
import { Module, Permission } from '@/lib/permissions/types'

function ProjectList() {
  const canCreate = usePermission(Module.PROJECTS, Permission.CREATE)
  const canEdit = usePermission(Module.PROJECTS, Permission.EDIT)
  
  return (
    <div>
      {canCreate && (
        <button>Create Project</button>
      )}
      {/* Project list */}
    </div>
  )
}
```

### Protect Routes/Pages

```tsx
import { PermissionGuard } from '@/components/permissions/PermissionGuard'
import { Module, Permission } from '@/lib/permissions/types'

function AdminPage() {
  return (
    <PermissionGuard 
      module={Module.USERS} 
      permission={Permission.VIEW}
      fallback={<div>Access Denied</div>}
    >
      <AdminPanel />
    </PermissionGuard>
  )
}
```

### Conditional UI Elements

```tsx
import { PermissionButton, TableActions } from '@/components/permissions/PermissionComponents'

function ProjectTable() {
  return (
    <table>
      <tbody>
        {projects.map(project => (
          <tr key={project.id}>
            <td>{project.name}</td>
            <td>
              <TableActions
                module={Module.PROJECTS}
                onEdit={() => editProject(project.id)}
                onDelete={() => deleteProject(project.id)}
                onView={() => viewProject(project.id)}
              />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
```

### Permission-Based Form Submissions

```tsx
import { usePermissions } from '@/lib/permissions/hooks'

function TimesheetForm({ timesheet }) {
  const { canEdit, canSubmit, canApprove } = usePermissions({ 
    module: Module.TIMESHEETS 
  })
  
  const handleSubmit = () => {
    if (timesheet.status === 'draft' && canEdit) {
      // Save changes
    } else if (timesheet.status === 'draft' && canSubmit) {
      // Submit for approval
    } else if (timesheet.status === 'submitted' && canApprove) {
      // Approve timesheet
    }
  }
  
  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
      <PermissionButton
        module={Module.TIMESHEETS}
        permission={timesheet.status === 'draft' ? Permission.EDIT : Permission.APPROVE}
      >
        {timesheet.status === 'draft' ? 'Save' : 'Approve'}
      </PermissionButton>
    </form>
  )
}
```

### Role-Specific Dashboards

```tsx
// The FioriDashboard component automatically shows role-appropriate tiles
import { FioriDashboard } from '@/components/permissions/FioriDashboard'

function HomePage() {
  return <FioriDashboard />
}
```

## Key Features Delivered

✅ **Fiori-Style Tiles**: Role-based dashboard with SAP Fiori-like tiles
✅ **Complete RBAC**: 8 roles × 16 modules × 6 permissions = comprehensive matrix
✅ **Database Security**: RLS policies with audit logging
✅ **React Components**: Permission-aware UI components
✅ **Type Safety**: Full TypeScript coverage
✅ **Performance**: Memoized permission checks
✅ **Business Rules**: Timesheet workflows, PO approvals, inventory controls

## Role-Specific Tile Examples

- **Admin**: Projects, Users, Reports, Settings
- **Manager**: My Projects, Approvals, Progress, Cost to Complete
- **Procurement**: Purchase Orders, Vendors, Procurement
- **Storekeeper**: Goods Receipt, Inventory, Purchase Orders
- **Engineer**: My Tasks, Progress Update, Projects
- **Finance**: Costing, Cost to Complete, Financial Reports
- **HR**: Timesheets, Employees
- **Employee**: My Timesheet, My Tasks
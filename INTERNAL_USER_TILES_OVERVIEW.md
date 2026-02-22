# Internal User Tiles & UI Overview

## 📊 Summary Statistics

**Total Tiles**: 104 tiles across 14 categories
**All tiles are role-protected** (except 3 public tiles)

---

## 🎯 Tile Categories Breakdown

### 1. **Configuration** (5 tiles)
- ERP Configuration
- SAP Configuration  
- Organization Configuration
- System Settings
- Number Range Configuration

### 2. **Administration** (9 tiles)
- User Management
- Role Management
- User Role Assignment
- Authorization Objects
- Authorization Management
- Approval Configuration
- Workflow Configuration
- Audit Log Viewer
- Data Integrity Monitor

### 3. **Finance** (15 tiles)
- Chart of Accounts
- GL Account Posting
- Cost Center Accounting
- Profit Center Accounting
- Trial Balance
- Profit & Loss Statement
- Balance Sheet
- Project Budget vs Actual
- Material Cost Variance
- Project Cost Consumption
- Cost Object Settlement
- Cost Object Hierarchy
- Financial Period Control
- Tax Code Management
- Currency Management

### 4. **Materials** (15 tiles)
- Create Material Master
- Maintain Material Master
- Display Material Master
- Material Master Maintenance
- Extend Material to Plant
- Material Plant Parameters
- Material Pricing
- Material Stock Overview
- Material Availability Check
- Material Requests
- Unified Material Request
- Material Request List
- Material Request Approvals
- Material Reservations
- Material Requirement Forecast

### 5. **Procurement** (10 tiles)
- Create Purchase Requisition
- PR Approval Workflow
- Convert PR to PO
- Purchase Orders
- PO Approvals
- PO Financial Approval
- Vendor Master
- Vendor Performance Monitor
- Procurement Performance KPIs
- Procurement Spend Analysis

### 6. **Inventory/Warehouse** (12 tiles combined)
**Inventory (6 tiles)**:
- Goods Receipt
- Goods Receipt Processing
- Goods Issue
- Goods Issue to Project
- Physical Inventory
- Inventory Adjustments

**Warehouse (6 tiles)**:
- Goods Transfer
- Stock Transfer Between Sites
- Stock Overview by Location
- Inventory Valuation Report
- Bin Management
- Cycle Counting

### 7. **Project Management** (10 tiles)
- Projects Dashboard
- Create Project
- Manage Projects
- Project Master
- WBS Management
- Activities Management
- Tasks Management
- Schedule Management
- Resource Planning
- Cost Management

### 8. **Quality** (6 tiles)
- Quality Inspection
- Quality Certificates
- Quality Notifications
- Quality Control Plans
- Inspection Lots
- Quality Analytics

### 9. **Safety** (6 tiles)
- Safety Incidents
- Safety Inspections
- Safety Training
- PPE Management
- Safety Compliance
- Safety Reports

### 10. **Human Resources** (8 tiles)
- Employee Master
- Attendance Management
- Leave Management
- Payroll Processing
- Training Records
- Performance Reviews
- Workforce Planning
- HR Analytics

### 11. **My Tasks** (4 tiles)
- My Approvals
- My Reservations
- My Material Requests
- My Activities

### 12. **Reports** (1 tile)
- Report Builder

### 13. **Workflow** (1 tile)
- Workflow Designer

### 14. **Uncategorized** (2 public tiles)
- Help & Documentation
- System Status

---

## 🎨 UI Design & User Experience

### **Main Dashboard Layout**
```
┌─────────────────────────────────────────────────────────────┐
│  Omega Build ERP                          [User Menu ▼]     │
│  ━━━━━━━━━━━━━━━━━━━━                                       │
│  Enterprise Resource Planning for Construction              │
├─────────────────────────────────────────────────────────────┤
│  Category Filters (Pills):                                  │
│  [🏗️ All] [🔧 Config] [⚙️ Admin] [💰 Finance] [📦 Materials]│
│  [🛒 Procurement] [🏪 Warehouse] [📋 Projects] ...          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ 📊 Chart │  │ 📝 GL    │  │ 💵 Cost  │  │ 📈 Trial │   │
│  │ of Accts │  │ Posting  │  │ Centers  │  │ Balance  │   │
│  │ Finance  │  │ Finance  │  │ Finance  │  │ Finance  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ 📦 Create│  │ ✏️ Maintain│ │ 👁️ Display│ │ 🏭 Extend│   │
│  │ Material │  │ Material │  │ Material │  │ to Plant │   │
│  │ Materials│  │ Materials│  │ Materials│  │ Materials│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ... (grid continues with all tiles)                       │
└─────────────────────────────────────────────────────────────┘
```

### **Tile Card Design**
Each tile displays:
- **Icon** (top-right corner with external link indicator)
- **Title** (bold, changes color on hover)
- **Subtitle** (description text)
- **Module Code** (badge at bottom-left)
- **Category** (text at bottom-right)

### **Interaction Flow**
1. User logs in → Sees authorized tiles based on role
2. Filter by category → Tiles update dynamically
3. Click tile → Component loads inline OR navigates to route
4. Back button → Returns to tile grid

### **Color Scheme**
- **Primary Blue**: `#0A6ED1` (buttons, active states)
- **Hover Blue**: `#0080FF`
- **Background**: `#F7F7F7` (light gray)
- **Text Primary**: `#32363A` (dark gray)
- **Text Secondary**: `#6A6D70` (medium gray)
- **Borders**: `#E5E5E5` (light gray)

---

## 🔐 Authorization Model

### **Role-Based Access Control (RBAC)**
- Each tile has an `auth_object` field
- Users assigned to roles
- Roles have authorization objects
- API endpoint `/api/tiles` uses RPC function `get_user_authorized_tiles(user_id)`
- Only authorized tiles are returned to frontend

### **Authorization Flow**
```
User Login
    ↓
Fetch User Role
    ↓
Call get_user_authorized_tiles(user_id)
    ↓
Returns tile IDs user can access
    ↓
Fetch tile details for authorized IDs
    ↓
Render tiles in UI
```

---

## 📱 Responsive Design

- **Desktop (xl)**: 4 tiles per row
- **Laptop (lg)**: 3 tiles per row
- **Tablet (md)**: 2 tiles per row
- **Mobile**: 1 tile per row (full width)

---

## 🚀 Key Features

### **Dynamic Module Loading**
- Lazy-loaded components for performance
- Suspense boundaries with loading states
- Error boundaries for failed module loads

### **Category Filtering**
- 14 categories + "All Modules" option
- Dynamic category generation from tile data
- Smooth filtering transitions

### **User Menu**
- User avatar with initials
- Email display
- Sign out functionality
- Dropdown menu with smooth animations

### **Inline Component Rendering**
- Tiles can render components inline (no page navigation)
- Back button to return to tile grid
- Maintains context (selected project, etc.)

### **Route-Based Navigation**
- Some tiles navigate to dedicated pages
- Uses Next.js router for navigation
- Preserves authentication state

---

## 🎯 Next Steps for External Access Integration

To integrate external access portal with internal tiles:

1. **Create External Access Category** (new tile category)
   - External Organizations
   - Resource Access Management
   - Drawing Approvals
   - Progress Updates
   - Field Service Tickets
   - External User Management

2. **Add External Access Tiles** (6-8 new tiles)
   ```sql
   INSERT INTO tiles (title, subtitle, tile_category, module_code, ...) VALUES
   ('External Organizations', 'Manage customer/vendor orgs', 'External Access', 'EXT-ORG', ...),
   ('Resource Access', 'Grant access to resources', 'External Access', 'EXT-RES', ...),
   ('Drawing Approvals', 'Customer approval workflow', 'External Access', 'EXT-DRW', ...),
   ('Progress Updates', 'Vendor progress tracking', 'External Access', 'EXT-PRG', ...),
   ('Field Service Tickets', 'Manage service tickets', 'External Access', 'EXT-FST', ...);
   ```

3. **Create React Components** for each tile
   - `ExternalOrganizationsManager.tsx`
   - `ResourceAccessManager.tsx`
   - `DrawingApprovalsManager.tsx`
   - `ProgressUpdatesManager.tsx`
   - `FieldServiceTicketsManager.tsx`

4. **Add to EnhancedConstructionTiles.tsx**
   ```typescript
   case 'External Organizations':
     return <ExternalOrganizationsManager />
   case 'Resource Access':
     return <ResourceAccessManager />
   // ... etc
   ```

5. **Authorization Setup**
   - Create auth objects for external access tiles
   - Assign to appropriate roles (Admin, Project Manager)
   - Test RLS policies work correctly

---

## 📊 Current Status

✅ **Backend API**: 100% complete (20+ endpoints)  
✅ **Database Schema**: 100% complete (9 tables)  
✅ **RLS Policies**: 100% complete (25+ policies)  
✅ **Internal User UI**: 100% complete (104 tiles)  
⏳ **External Access UI**: 0% complete (needs frontend components)

**Ready to build external access frontend components!**

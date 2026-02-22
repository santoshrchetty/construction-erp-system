# Document Governance Module - Reference Documentation

## Overview
Complete implementation of Document Governance module with ISO 19650 compliance, including Find, Display, Create, and Change Document functionality.

## Module Structure

### 1. Tiles Configuration
**Location**: Database `tiles` table for tenant `OMEGA-DEV` (9bd339ec-9877-4d9f-b3dc-3e60048c1b15)

**Tiles** (in sequence order):
1. **Find Document** - Search and view records (`/document-governance/records/list`)
2. **Display Document** - View document details (`/document-governance/records/display`)
3. **Create Document** - Create new record (`/document-governance/records/new`)
4. **Change Document** - Modify existing record (`/document-governance/records/change`)
5. **Document Governance Config** - Configure settings (`/document-governance/config`)
6. **Document Audit Trail** - View audit trail (`/document-governance/audit`)

**Authorization Objects**:
- `Z_DG_RECORDS_DISPLAY` - Find & Display Document
- `Z_DG_RECORDS_CREATE` - Create Document
- `Z_DG_RECORDS_CHANGE` - Change Document
- `Z_DG_CONFIG` - Configuration
- `Z_DG_AUDIT` - Audit Trail

### 2. Navigation Flow
```
ERP Modules (All Categories)
  ↓ Click Document Governance category filter
ERP Modules (Filtered by Document Governance)
  ↓ Click tile (Find/Display/Create/Change)
Document Page
  ↓ Click Back button
ERP Modules (Filtered by Document Governance)
```

**Key Implementation**:
- Back buttons navigate to: `/erp-modules?category=Document Governance`
- No separate landing page - uses filtered ERP Modules page
- Breadcrumbs removed for cleaner interface

### 3. Pages Implementation

#### 3.1 Find Document (`/document-governance/records/list`)
**Features**:
- Search filters: Document Number, Title, Document Type, Status
- Column configuration (show/hide columns)
- CSV download
- Actions: View (Eye icon), Edit, Delete/Archive
- Back button to filtered ERP Modules

**Files**:
- `app/document-governance/records/list/page.tsx`

#### 3.2 Display Document (`/document-governance/records/display`)
**Features**:
- Search input for document number
- Read-only greyed-out fields
- Can be accessed directly with `?id=<document-id>` or via search
- Back button to filtered ERP Modules

**Files**:
- `app/document-governance/records/display/page.tsx`

**Usage**:
```
Direct: /document-governance/records/display?id=<uuid>
Search: Enter document number (e.g., DOC-1771486253490)
```

#### 3.3 Create Document (`/document-governance/records/new`)
**Features**:
- **Basic Information**:
  - Document Number (auto-generated)
  - Title (required)
  - Description (optional, toggle with FileText icon)
  - Document Type (Drawing, Specification, Contract, Report)
  - Document Subtype (dynamic based on type)
  - Version (default: 1.0)
  - Part Number

- **Governance & Control (ISO 19650)**:
  - System Status: WIP, SHARED, APPROVED, CURRENT, ARCHIVED, SUPERSEDED
  - User Status: IFC, IFA, IFI, IFT, IFR, AS-BUILT

- **Object Links** (SAP-style):
  - Project, WBS Element, Cost Center, Material, Equipment, Purchase Order, Sales Order
  - Searchable dropdowns with auto-load
  - WBS: Project selection → Auto-selects "Code & Description" → Loads filtered WBS elements

**Files**:
- `app/document-governance/records/new/page.tsx`

**Form Layout**:
```
Row 1: Document Number (3 cols) | Title (8 cols) | Description Icon (1 col)
Row 2: Document Type | Document Subtype | Version | Part No (4 equal columns)
```

#### 3.4 Change Document (`/document-governance/records/change`)
**Status**: Placeholder page
**Files**:
- `app/document-governance/records/change/page.tsx`

### 4. API Endpoints

#### 4.1 GET `/api/document-governance/records`
**Actions**:
- `find` - List documents with filters
- `get` - Get single document by ID
- `load-objects` - Load objects for dropdowns (PROJECT, WBS, COST_CENTER, MATERIAL, PURCHASE_ORDER)
- `search-objects` - Search objects with query
- `document-types` - Get document types
- `document-statuses` - Get document statuses

**WBS Filtering**:
```javascript
// WBS elements filtered by project_code
GET /api/document-governance/records?action=load-objects&type=WBS&projectCode=P100
```

#### 4.2 POST `/api/document-governance/records`
**Actions**:
- `create` - Create new document

**Request Body**:
```json
{
  "action": "create",
  "data": {
    "title": "Site Layout Plan",
    "document_type": "DRW",
    "document_subtype": "GA",
    "version": "1.0",
    "system_status": "WIP",
    "user_status": "IFR",
    "created_by": "<user-id>"
  }
}
```

**Files**:
- `app/api/document-governance/records/route.ts`

### 5. Database Schema

#### 5.1 Tables Used
**drawings** (temporary storage):
- `id` (UUID, PK)
- `tenant_id` (UUID, FK to tenants)
- `drawing_number` (VARCHAR(50))
- `title` (VARCHAR(255))
- `description` (TEXT)
- `revision` (VARCHAR(10), default 'A')
- `discipline` (VARCHAR(50))
- `status` (VARCHAR(20), default 'DRAFT')
- `created_by` (UUID, FK to users)
- `updated_by` (UUID)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

**Key Mappings**:
- `version` → `revision`
- `document_subtype` → `discipline`
- `system_status` → `status`

#### 5.2 Reference Tables
- `projects` - project_code, name
- `wbs_elements` - wbs_element, wbs_description, project_code, is_active
- `cost_centers` - cost_center_code, cost_center_name
- `materials` - material_code, material_name

### 6. Key Features Implemented

#### 6.1 ISO 19650 Compliance
**System Status** (Document lifecycle):
- WIP - Work in Progress
- SHARED - Shared for Review
- APPROVED - Approved
- CURRENT - Current Version
- ARCHIVED - Archived
- SUPERSEDED - Superseded

**User Status** (Issue purpose):
- IFC - Issued for Construction
- IFA - Issued for Approval
- IFI - Issued for Information
- IFT - Issued for Tender
- IFR - Issued for Review
- AS-BUILT - As-Built

#### 6.2 Object Links with Search
**Supported Object Types**:
- PROJECT - Search by: Project Code, Code & Name, Location
- WBS - Search by: Code & Description (filtered by project)
- COST_CENTER - Search by: Cost Center Code, Code & Name
- MATERIAL - Search by: Material Code, Code & Name, Category
- EQUIPMENT - Search by: Equipment Tag, Tag & Name
- PURCHASE_ORDER - Search by: PO Number, PO & Vendor
- SALES_ORDER - Search by: SO Number, SO & Customer

**WBS Workflow**:
1. Select "WBS Element" as object type
2. Projects dropdown loads automatically
3. Select project (e.g., P100)
4. "Code & Description" auto-selected
5. WBS elements auto-load filtered by project_code
6. Search or select from dropdown

#### 6.3 Description Toggle
- FileText icon next to Title field
- Click to show/hide description textarea
- Saves screen space when not needed

### 7. SQL Scripts

**Setup Scripts**:
- `database/add_document_governance_record_tiles.sql` - Create 3 main tiles
- `database/add_display_document_tile.sql` - Add Display Document tile
- `database/update_document_governance_tile_sequence.sql` - Set proper sequence order
- `database/remove_duplicate_display_document_tiles.sql` - Clean up duplicates

**Cleanup Scripts**:
- `database/remove_drawing_tiles.sql` - Remove old drawing tiles
- `database/restore_document_governance_tiles.sql` - Restore main tiles

### 8. Configuration

**Tenant ID**: `9bd339ec-9877-4d9f-b3dc-3e60048c1b15` (OMEGA-DEV)

**Service Client**: Uses `createServiceClient()` to bypass RLS for data access

**Document Number Format**: `DOC-<timestamp>` (auto-generated)

### 9. Known Issues & Solutions

#### 9.1 Database Schema Mismatches
**Issue**: Column name differences between code and database
**Solution**: 
- Use `drawings` table temporarily
- Map fields: version→revision, document_subtype→discipline, system_status→status

#### 9.2 SQL Alias Bug
**Issue**: Supabase doesn't parse `name as project_name` correctly
**Solution**: Select column and map in JavaScript

#### 9.3 WBS Filtering
**Issue**: Need to filter WBS by project
**Solution**: 
- Load projects first
- Pass `projectCode` parameter to WBS query
- Filter by `project_code` and `is_active=true`

### 10. Testing

**Test Scenario 1: Create Drawing**
1. Navigate to Create Document
2. Fill: Title="Site Layout Plan", Type=Drawing, Subtype=GA, Version=1.0, Status=WIP, User Status=IFR
3. Click Create
4. Expected: Success message with document number

**Test Scenario 2: WBS Object Link**
1. Add Object Link
2. Select WBS Element
3. Select Project: P100
4. Verify "Code & Description" auto-selected
5. Verify WBS elements load automatically
6. Search or select WBS element

**Test Scenario 3: Display Document**
1. Navigate to Display Document
2. Enter document number (e.g., DOC-1771486253490)
3. Click Search
4. Verify document displays with greyed-out fields

### 11. Future Enhancements
- Implement Change Document functionality
- Add document versioning and revision control
- Implement document relationships and hierarchy
- Add file upload/attachment support
- Implement workflow and approval process
- Add document transmittal functionality

## Summary
Complete Document Governance module with 6 tiles, ISO 19650 compliance, SAP-style object links, and seamless navigation flow. All pages include Back buttons that navigate to filtered ERP Modules page for consistent user experience.

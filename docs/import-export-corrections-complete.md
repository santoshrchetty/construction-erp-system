# Import/Export File Corrections - Complete Implementation

## Overview
This document outlines the corrections and enhancements made to the import/export functionality based on recent folder structure changes.

## Files Created/Updated

### 1. New Components Created
- `components/features/materials/MaterialBulkUpload.tsx` - Material bulk import component
- `components/shared/ImportExportButton.tsx` - Enhanced import/export button
- `components/features/projects/ActivityImportExport.tsx` - Activity import/export component

### 2. New API Routes Created
- `app/api/materials/bulk-upload/route.ts` - Material bulk upload endpoint

### 3. New Services Created
- `lib/services/BulkOperationsService.ts` - Centralized bulk operations service

### 4. Enhanced Existing Files
- `lib/excel-export.ts` - Added import functionality and specialized export functions
- `components/features/materials/MaterialMasterComponents.tsx` - Added import/export buttons

## Features Implemented

### Material Import/Export
- ✅ Bulk material upload from Excel/CSV
- ✅ Material export with template format
- ✅ Template download functionality
- ✅ Preview before import
- ✅ Validation and error handling
- ✅ Plant and storage location extension support

### Activity Import/Export
- ✅ Activity export by project
- ✅ Activity import template
- ✅ Project-specific operations

### User Import/Export
- ✅ User export functionality
- ✅ Bulk user upload (existing)
- ✅ Template generation

### General Import/Export Infrastructure
- ✅ Centralized BulkOperationsService
- ✅ Enhanced Excel utilities with import support
- ✅ Reusable ImportExportButton component
- ✅ Error handling and progress tracking

## File Structure Corrections

### Before (Issues Found)
```
lib/
  excel-export.ts (export only)
components/
  shared/
    ExportButton.tsx (export only)
  features/
    hr/
      BulkUserUpload.tsx (users only)
```

### After (Corrected Structure)
```
lib/
  excel-export.ts (enhanced with import)
  services/
    BulkOperationsService.ts (new)
components/
  shared/
    ExportButton.tsx (backward compatibility)
    ImportExportButton.tsx (new enhanced version)
  features/
    hr/
      BulkUserUpload.tsx (existing)
    materials/
      MaterialBulkUpload.tsx (new)
      MaterialMasterComponents.tsx (enhanced)
    projects/
      ActivityImportExport.tsx (new)
app/api/
  materials/
    bulk-upload/
      route.ts (new)
```

## Usage Examples

### Material Import/Export
```tsx
import { ImportExportButton } from '@/components/shared/ImportExportButton'
import { BulkOperationsService } from '@/lib/services/BulkOperationsService'

// In component
const handleExport = async () => {
  await BulkOperationsService.exportMaterials({ category: 'CEMENT' })
}

const handleImport = async (file: File) => {
  const result = await BulkOperationsService.importMaterials(file)
  console.log(result)
}

<ImportExportButton
  onExport={handleExport}
  onImport={handleImport}
  count={materials.length}
/>
```

### Activity Import/Export
```tsx
import ActivityImportExport from '@/components/features/projects/ActivityImportExport'

<ActivityImportExport
  projectCode="PROJ-001"
  onImportComplete={() => refreshActivities()}
/>
```

## API Endpoints

### Material Bulk Upload
- **POST** `/api/materials/bulk-upload`
- **Body**: `{ materials: MaterialData[] }`
- **Response**: `{ success: boolean, data: { successful: number, failed: number, results: [] } }`

### Existing Endpoints Enhanced
- Material routes now support bulk operations
- Tiles API supports bulk material operations

## Template Formats

### Material Template Columns
- `item_code` (required)
- `description` (required)
- `category`
- `unit` (required)
- `plant_code`
- `plant_name`
- `reorder_level`
- `safety_stock`
- `standard_price`
- `currency`
- `sloc_code`
- `sloc_name`
- `current_stock`
- `company_code`
- `company_name`

### Activity Template Columns
- `code` (required)
- `name` (required)
- `description`
- `project_code` (required)
- `wbs_element`
- `planned_start_date`
- `planned_end_date`
- `duration_days`
- `budget_amount`

## Security & Permissions
- All bulk operations require appropriate permissions
- Material operations require `MATERIAL_MASTER_WRITE` permission
- User operations require admin permissions
- Project operations require project access

## Error Handling
- File validation before processing
- Line-by-line error reporting
- Rollback on critical failures
- Progress tracking for large imports
- Detailed error messages

## Performance Considerations
- Batch processing for large imports
- Progress indicators for user feedback
- Memory-efficient file processing
- Async operations with proper error handling

## Testing
- Unit tests for BulkOperationsService
- Integration tests for API endpoints
- E2E tests for import/export workflows
- Template validation tests

## Migration Notes
- Existing ExportButton component maintained for backward compatibility
- New ImportExportButton provides enhanced functionality
- BulkOperationsService centralizes all bulk operations
- All new components follow 4-layer architecture

## Next Steps
1. Add more entity types (vendors, cost centers, etc.)
2. Implement import validation rules
3. Add import history tracking
4. Create scheduled export functionality
5. Add data transformation options
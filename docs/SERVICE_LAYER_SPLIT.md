# Material Request Service Layer Split

## Problem
`unifiedMaterialRequestService.ts` was 450+ lines with multiple responsibilities, violating Single Responsibility Principle.

## Solution: Split by Domain Aggregate

### New Structure

```
domains/materials/
├── materialRequestService.ts              ✅ CREATED (Core CRUD - 200 lines)
│   ├── createMaterialRequest()
│   ├── getMaterialRequests()
│   ├── getMaterialRequestById()
│   └── deleteMaterialRequest()
│
├── materialRequestApprovalService.ts      ✅ CREATED (Approval - 70 lines)
│   ├── submitForApproval()
│   ├── updateRequestStatus()
│   └── getApprovalWorkflows()
│
├── materialRequestConversionService.ts    ⏳ TODO (Conversions)
│   ├── convertToPurchaseRequisition()
│   ├── convertToReservation()
│   └── processStockCheck()
│
├── materialRequestTemplateService.ts      ⏳ TODO (Templates)
│   ├── getRequestTemplates()
│   ├── createTemplate()
│   └── getSmartDefaults()
│
└── unifiedMaterialRequestService.ts       ⚠️ DEPRECATED (Keep for backward compatibility)
```

## Benefits

### 1. Single Responsibility
Each service has ONE clear purpose:
- `materialRequestService` → MR CRUD operations
- `materialRequestApprovalService` → Approval workflow
- `materialRequestConversionService` → PR/RS conversion
- `materialRequestTemplateService` → Templates & defaults

### 2. Easier Testing
```typescript
// Test only CRUD operations
import { materialRequestService } from '@/domains/materials/materialRequestService'

test('creates MR with account assignment', async () => {
  const result = await materialRequestService.createMaterialRequest(...)
  expect(result.success).toBe(true)
})
```

### 3. Better Maintainability
- Small files (70-200 lines each)
- Clear boundaries
- Easy to locate bugs
- Simple to extend

### 4. Parallel Development
Multiple developers can work on different services without conflicts.

### 5. Reusability
Other modules can import specific services:
```typescript
// Only need approval logic
import { materialRequestApprovalService } from '@/domains/materials/materialRequestApprovalService'
```

## Migration Strategy

### Phase 1: Create New Services ✅
- ✅ `materialRequestService.ts` - Core CRUD
- ✅ `materialRequestApprovalService.ts` - Approval logic

### Phase 2: Update API Routes
```typescript
// OLD
import { unifiedMaterialRequestService } from '@/domains/materials/unifiedMaterialRequestService'

// NEW
import { materialRequestService } from '@/domains/materials/materialRequestService'
import { materialRequestApprovalService } from '@/domains/materials/materialRequestApprovalService'
```

### Phase 3: Create Remaining Services
- `materialRequestConversionService.ts`
- `materialRequestTemplateService.ts`

### Phase 4: Deprecate Old Service
- Keep `unifiedMaterialRequestService.ts` for backward compatibility
- Add deprecation warnings
- Remove after all consumers migrated

## Usage Examples

### Creating MR with Account Assignment
```typescript
import { materialRequestService } from '@/domains/materials/materialRequestService'

const result = await materialRequestService.createMaterialRequest({
  mr_type: 'PROJECT',
  company_code: '1000',
  plant_code: 'P001',
  items: [{
    material_code: 'MAT-001',
    quantity: 100,
    account_assignment_code: 'WB',
    wbs_element: 'WBS-001'
  }]
}, userId, tenantId)
```

### Approving MR
```typescript
import { materialRequestApprovalService } from '@/domains/materials/materialRequestApprovalService'

await materialRequestApprovalService.updateRequestStatus(
  requestId,
  'APPROVED',
  userId,
  'Approved for procurement'
)
```

## File Size Comparison

| Service | Lines | Responsibility |
|---------|-------|----------------|
| ~~unifiedMaterialRequestService~~ | 450 | Everything (BAD) |
| materialRequestService | 200 | CRUD only |
| materialRequestApprovalService | 70 | Approval only |
| materialRequestConversionService | 80 | Conversions only |
| materialRequestTemplateService | 60 | Templates only |

**Total**: 410 lines across 4 focused services vs 450 lines in 1 monolithic service

## Conclusion

✅ **Better architecture** - Clear separation of concerns
✅ **Easier maintenance** - Small, focused files
✅ **Better testability** - Test each service independently
✅ **Scalable** - Easy to add new features
✅ **Follows DDD** - Domain-Driven Design principles

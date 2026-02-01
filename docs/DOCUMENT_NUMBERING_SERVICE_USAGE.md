# Document Numbering Service Usage Examples

## Import the Service
```typescript
import { documentNumberingService, DocumentNumberingService } from '@/lib/services/documentNumberingService'
```

## Generate Document Numbers

### Material Request
```typescript
const mrNumber = await documentNumberingService.generateDocumentNumber(
  'MATERIAL_REQ',
  'C001',
  tenantId
)
// Result: MR-01-2024-000001
```

### Purchase Order
```typescript
const poNumber = await documentNumberingService.generateDocumentNumber(
  'PURCHASE_ORDER',
  'C001',
  tenantId
)
// Result: PO-01-2024-000001
```

### Goods Receipt
```typescript
const grNumber = await documentNumberingService.generateDocumentNumber(
  'GOODS_RECEIPT',
  'C001',
  tenantId
)
// Result: GR-01-2024-00000001
```

### Customer Invoice
```typescript
const ciNumber = await documentNumberingService.generateDocumentNumber(
  'CUSTOMER_INVOICE',
  'C001',
  tenantId
)
// Result: CI-01-2024-00000001
```

### Payment Document
```typescript
const pdNumber = await documentNumberingService.generateDocumentNumber(
  'PAYMENT_DOCUMENT',
  'C001',
  tenantId
)
// Result: PD-01-2024-00000001
```

## Custom Subtypes
```typescript
// Emergency Material Request
const emergencyMR = await documentNumberingService.generateDocumentNumber(
  'MATERIAL_REQ',
  'C001',
  tenantId,
  '02' // Emergency subtype
)
// Result: MR-02-2024-000001
```

## Utility Functions

### Parse Document Number
```typescript
const parsed = DocumentNumberingService.parseDocumentNumber('MR-01-2024-000123')
console.log(parsed)
// {
//   documentType: 'MR',
//   subtype: '01',
//   year: '2024',
//   sequence: '000123'
// }
```

### Validate Document Number
```typescript
const isValid = DocumentNumberingService.isValidDocumentNumber('MR-01-2024-000123')
console.log(isValid) // true

const isInvalid = DocumentNumberingService.isValidDocumentNumber('MR-01-24-123')
console.log(isInvalid) // false (wrong year format and sequence length)
```

### Get Available Document Types
```typescript
const documentTypes = DocumentNumberingService.getDocumentTypes()
console.log(documentTypes)
// Returns all configured document types with their configurations
```

## Integration Examples

### In a Service Class
```typescript
export class PurchaseOrderService {
  async createPurchaseOrder(orderData: any, userId: string, tenantId: string) {
    // Generate PO number
    const poNumber = await documentNumberingService.generateDocumentNumber(
      'PURCHASE_ORDER',
      orderData.company_code,
      tenantId
    )

    const purchaseOrder = {
      ...orderData,
      po_number: poNumber,
      created_by: userId,
      tenant_id: tenantId
    }

    // Save to database...
  }
}
```

### In an API Route
```typescript
export async function POST(request: NextRequest) {
  const body = await request.json()
  const { tenantId, userId } = await getAuthContext(request)

  // Generate invoice number
  const invoiceNumber = await documentNumberingService.generateDocumentNumber(
    'CUSTOMER_INVOICE',
    body.company_code,
    tenantId
  )

  const invoice = {
    ...body,
    invoice_number: invoiceNumber,
    created_by: userId,
    tenant_id: tenantId
  }

  // Process invoice...
}
```

## All Available Document Types

| Key | Format | Example | Description |
|-----|--------|---------|-------------|
| MATERIAL_REQ | MR-01-YYYY-000000 | MR-01-2024-000001 | Material Request - Standard |
| MATERIAL_REQ_EMERGENCY | MR-02-YYYY-000000 | MR-02-2024-000001 | Material Request - Emergency |
| PURCHASE_REQ | PR-01-YYYY-000000 | PR-01-2024-000001 | Purchase Requisition - Standard |
| PURCHASE_ORDER | PO-01-YYYY-000000 | PO-01-2024-000001 | Purchase Order - Standard |
| GOODS_RECEIPT | GR-01-YYYY-00000000 | GR-01-2024-00000001 | Goods Receipt - From PO |
| GOODS_ISSUE | GI-01-YYYY-00000000 | GI-01-2024-00000001 | Goods Issue - To Cost Center |
| TRANSFER | TR-01-YYYY-00000000 | TR-01-2024-00000001 | Transfer - Plant to Plant |
| MATERIAL_ISSUE | MI-01-YYYY-00000000 | MI-01-2024-00000001 | Material Issue - To Production |
| REVERSAL | RV-01-YYYY-00000000 | RV-01-2024-00000001 | Reversal - Goods Receipt |
| CUSTOMER_INVOICE | CI-01-YYYY-00000000 | CI-01-2024-00000001 | Customer Invoice - Standard |
| VENDOR_INVOICE | VI-01-YYYY-00000000 | VI-01-2024-00000001 | Vendor Invoice - Standard |
| CUSTOMER_CREDIT | CC-01-YYYY-00000000 | CC-01-2024-00000001 | Customer Credit Memo |
| VENDOR_CREDIT | VC-01-YYYY-00000000 | VC-01-2024-00000001 | Vendor Credit Memo |
| PAYMENT_DOCUMENT | PD-01-YYYY-00000000 | PD-01-2024-00000001 | Payment - Outgoing |
| JOURNAL_ENTRY | JE-01-YYYY-00000000 | JE-01-2024-00000001 | Journal Entry - Standard |
| GENERAL_DOCUMENT | GD-01-YYYY-00000000 | GD-01-2024-00000001 | G/L Document - Standard |
| DOWN_PAYMENT | DP-01-YYYY-00000000 | DP-01-2024-00000001 | Down Payment - Customer |
| RECEIPT_CONFIRMATION | RC-01-YYYY-00000000 | RC-01-2024-00000001 | Receipt - Invoice Receipt |
| CLEARING_DOCUMENT | CL-01-YYYY-00000000 | CL-01-2024-00000001 | Clearing - AR |
| ADJUSTMENT_DOCUMENT | AD-01-YYYY-000000 | AD-01-2024-000001 | Adjustment - Period End |

## Notes

- **6-digit sequences** (000000): Used for low-volume documents (MR, PR, PO, AD)
- **8-digit sequences** (00000000): Used for high-volume documents (GR, GI, CI, VI, PD, JE, etc.)
- **4-digit year** (YYYY): Always uses full year format (2024, 2025, etc.)
- **Tenant isolation**: Each tenant can have the same document numbers independently
- **Fallback numbering**: If RPC functions aren't available, uses timestamp-based sequential numbering
# SAP S/4HANA to Construction App - Number Range Mapping

## Complete Document Type Mapping Reference

### Materials Management (MM)

| SAP Object | SAP Table | SAP Field | Construction App Type | Range | Prefix | Year Dependent | Transaction Codes |
|------------|-----------|-----------|----------------------|-------|--------|----------------|-------------------|
| MATL | MARA | MATNR | MATERIAL | 5600000000-5699999999 | MAT | No | MM01, MM02, MM03 |
| Custom | - | - | MR | 5300000000-5399999999 | MR | No | Custom MR form |
| BANFN | EBAN | BANFN | PR | 5100000000-5199999999 | PR | No | ME51N, ME52N, ME53N |
| EBELN | EKKO | EBELN | PO | 5400000000-5499999999 | PO | No | ME21N, ME22N, ME23N |
| MBLNR | MKPF | MBLNR | GR | 5700000000-5799999999 | GR | Yes | MIGO (101, 103) |
| MBLNR | MKPF | MBLNR | GI | 5900000000-5999999999 | GI | Yes | MIGO (201, 261) |
| MBLNR | MKPF | MBLNR | TR | 6000000000-6099999999 | TR | Yes | MIGO (311, 313) |
| MBLNR | MKPF | MBLNR | MI | 6100000000-6199999999 | MI | Yes | MI01, MI02, MI04 |
| MBLNR | MKPF | MBLNR | RV | 6200000000-6299999999 | RV | Yes | MIGO (122, 162) |
| BELNR_INV | RBKP | BELNR | INVOICE | 5800000000-5899999999 | INV | Yes | MIRO |

### Finance (FI)

| SAP Object | SAP Table | SAP Field | Construction App Type | Range | Prefix | Year Dependent | Transaction Codes |
|------------|-----------|-----------|----------------------|-------|--------|----------------|-------------------|
| BELNR | BKPF/ACDOCA | BELNR | FI_DOC | 1000000000-1099999999 | FI | Yes | FB01, FB50, FB60 |
| BELNR | BKPF/ACDOCA | BELNR | AP_DOC | 1100000000-1199999999 | AP | Yes | F-43, FB60 |
| BELNR | BKPF/ACDOCA | BELNR | AR_DOC | 1200000000-1299999999 | AR | Yes | F-22, FB70 |
| BELNR | BKPF/ACDOCA | BELNR | PAYMENT | 1300000000-1399999999 | PAY | Yes | F-53, F-58, F110 |
| BELNR | BKPF/ACDOCA | BELNR | JOURNAL | 1400000000-1499999999 | JE | Yes | FB50, F-02 |
| BELNR | BKPF/ACDOCA | BELNR | CLEARING | 1500000000-1599999999 | CLR | Yes | F-04, F-44, F-32 |

### Master Data (MD)

| SAP Object | SAP Table | SAP Field | Construction App Type | Range | Prefix | Year Dependent | Transaction Codes |
|------------|-----------|-----------|----------------------|-------|--------|----------------|-------------------|
| PARTNER | BUT000 | PARTNER | BP | 0010000000-0019999999 | BP | No | BP, BP_GEN |
| KUNNR | KNA1 | KUNNR | CUSTOMER | 0020000000-0029999999 | CU | No | XD01, FD01, VD01 |
| LIFNR | LFA1 | LIFNR | VENDOR | 0030000000-0039999999 | VE | No | XK01, FK01, MK01 |
| PERNR | PA0000 | PERNR | EMPLOYEE | 0040000000-0049999999 | EM | No | PA30, PA40 |
| Custom | KNVK | PARNR | CONTACT | 0050000000-0059999999 | CP | No | Custom |

## SAP Document Type Codes

### FI Document Types (BLART)
- **SA** - G/L Account Document → FI_DOC, JOURNAL
- **AB** - Accounting Document → FI_DOC, CLEARING
- **KR** - Vendor Invoice → AP_DOC
- **DR** - Customer Invoice → AR_DOC
- **ZP** - Payment Document → PAYMENT
- **RE** - Invoice → INVOICE
- **WE** - Goods Receipt → GR

### MM Movement Types (BWART)
- **101** - GR for Purchase Order → GR
- **103** - GR for Purchase Order into GR Blocked Stock → GR
- **122** - Return Delivery to Vendor → RV
- **161** - Return Delivery from Customer → RV
- **201** - Goods Issue for Cost Center → GI
- **261** - Goods Issue for Order → GI
- **311** - Transfer Posting Storage Location to Storage Location → TR
- **313** - Transfer Posting Storage Location to Storage Location (Removal from Storage) → TR

## Number Range Configuration Rules

### Year Dependency
**Year Dependent (Resets Each Fiscal Year):**
- All FI documents (FI_DOC, AP_DOC, AR_DOC, PAYMENT, JOURNAL, CLEARING)
- All MM movement documents (GR, GI, TR, MI, RV)
- Invoice documents (INVOICE)

**Not Year Dependent (Continuous):**
- Master data (MATERIAL, BP, CUSTOMER, VENDOR, EMPLOYEE, CONTACT)
- Procurement documents (MR, PR, PO)

### External vs Internal Numbering
**Internal (System Generated):**
- All transactional documents
- Most master data

**External (User Entered):**
- Can be configured per range using `is_external` flag
- Typically used for legacy data migration

## Range Allocation Strategy

### Range Blocks
- **0000000000-0999999999**: Master Data
- **1000000000-1999999999**: Finance Documents
- **2000000000-4999999999**: Reserved for future use
- **5000000000-6999999999**: Materials Management
- **7000000000-9999999999**: Reserved for future use

### Company Code Specific
Each company code can have separate ranges:
- Company 1000: Uses ranges as documented
- Company 2000: Can use different ranges (e.g., 7000000000+)

## Implementation Notes

### Database Fields
```sql
company_code          VARCHAR(4)   -- Company code
document_type         VARCHAR(10)  -- Document type (MR, PR, PO, etc.)
number_range_object   VARCHAR(10)  -- SAP object name
fiscal_year           INTEGER      -- Fiscal year
range_from            VARCHAR(20)  -- Start of range
range_to              VARCHAR(20)  -- End of range
from_number           BIGINT       -- Numeric start
to_number             BIGINT       -- Numeric end
current_number        VARCHAR(20)  -- Last used number
prefix                VARCHAR(10)  -- Number prefix
year_dependent        BOOLEAN      -- Reset yearly?
is_external           BOOLEAN      -- External numbering?
```

### API Usage
```typescript
// Get next number
const { data } = await supabase.rpc('get_next_number', {
  p_company_code: '1000',
  p_document_type: 'PO',
  p_fiscal_year: '2024'
});
// Returns: PO5400000001
```

## SAP Transaction Code Reference

### MM Transactions
- **MM01/MM02/MM03** - Material Master
- **ME51N/ME52N/ME53N** - Purchase Requisition
- **ME21N/ME22N/ME23N** - Purchase Order
- **MIGO** - Goods Movement
- **MIRO** - Invoice Verification
- **MI01/MI02/MI04** - Physical Inventory

### FI Transactions
- **FB01/FB50/FB60/FB70** - Document Entry
- **F-43** - Vendor Invoice
- **F-22** - Customer Invoice
- **F-53/F-58** - Payment Posting
- **F110** - Automatic Payment
- **F-04/F-44/F-32** - Clearing

### MD Transactions
- **BP/BP_GEN** - Business Partner
- **XD01/FD01/VD01** - Customer Master
- **XK01/FK01/MK01** - Vendor Master
- **PA30/PA40** - Personnel Administration

## Maintenance

### Adding New Document Types
1. Copy existing range configuration
2. Assign new range block
3. Set appropriate prefix
4. Configure year dependency
5. Update application code to use new type

### Year-End Processing
For year-dependent ranges:
1. System automatically uses fiscal_year parameter
2. New year = new range or continues in same range
3. Configure separate ranges per year if needed

### Monitoring
- Check `number_range_alerts` for exhaustion warnings
- Review `number_range_usage_history` for audit trail
- Monitor `current_number` vs `to_number` for capacity

## Alignment Status

✅ **Fully Aligned with SAP S/4HANA**
- TNRO (Number Range Objects) → document_type
- NRIV (Number Range Intervals) → document_number_ranges table
- Year dependency support
- Company code specific ranges
- External numbering support
- Multiple ranges per object (range_number)
- Fiscal year variant support

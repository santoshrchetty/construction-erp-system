# Document Numbering - Quick Reference

## Format
```
[BASE]-[SUBTYPE]-[YYYY]-[NUMBER]
Example: MR-01-2024-000123
```

## Common Document Types

| Code | Name | Digits | Example |
|------|------|--------|---------|
| MR | Material Request | 6 | MR-01-2024-000123 |
| PR | Purchase Requisition | 6 | PR-01-2024-000456 |
| PO | Purchase Order | 6 | PO-01-2024-000789 |
| GR | Goods Receipt | 8 | GR-01-2024-00000001 |
| GI | Goods Issue | 8 | GI-01-2024-00000001 |
| CI | Customer Invoice | 8 | CI-01-2024-00000001 |
| VI | Vendor Invoice | 8 | VI-01-2024-00000001 |
| PD | Payment Document | 8 | PD-01-2024-00000001 |
| JE | Journal Entry | 8 | JE-01-2024-00000001 |

## API Usage

### Get Next Number
```typescript
const { data } = await supabase.rpc('get_next_number_by_group', {
  p_company_code: 'C001',
  p_document_type: 'MR',
  p_number_range_group: '01',
  p_fiscal_year: '2024'
});

// Returns: "MR-01-2024-000123"
```

### Create Document
```typescript
const requestData = {
  document_number: await getNextNumber('C001', 'MR', '01', '2024'),
  company_code: 'C001',
  // ... other fields
};
```

## Database Queries

### Check Range Status
```sql
SELECT 
  document_type,
  number_range_group,
  current_number,
  to_number,
  ROUND((current_number::NUMERIC / to_number) * 100, 2) as pct_used
FROM document_number_ranges
WHERE company_code = 'C001' AND status = 'ACTIVE';
```

### Parse Document Number
```sql
SELECT 
  SPLIT_PART(document_number, '-', 1) as doc_type,
  SPLIT_PART(document_number, '-', 2) as subtype,
  SPLIT_PART(document_number, '-', 3) as year,
  SPLIT_PART(document_number, '-', 4) as sequence
FROM material_requests;
```

## Subtypes (01-99)

### Material Request (MR)
- 01: Standard
- 02: Emergency
- 03: Stock Transfer
- 04: Subcontractor

### Purchase Order (PO)
- 01: Standard
- 02: Framework
- 03: Subcontract
- 04: Emergency
- 05: Rental

### Goods Receipt (GR)
- 01: From PO (SAP 101)
- 02: Without PO (SAP 501)
- 03: From Production (SAP 131)

### Customer Invoice (CI)
- 01: Standard
- 02: Proforma
- 03: Tax Invoice
- 04: Export

### Payment (PD)
- 01: Outgoing
- 02: Incoming
- 03: Bank Transfer
- 04: Cash

## Capacity

| Digits | Capacity | Use Case |
|--------|----------|----------|
| 6 | 1M/year | Low volume (MR, PR, PO) |
| 8 | 100M/year | High volume (GR, GI, CI, VI) |

## Multi-Tenancy

```typescript
// Always include company_code
const { data } = await supabase
  .from('material_requests')
  .select('*')
  .eq('company_code', userCompanyCode);  // ← Required!
```

## SAP Mapping

| Our Code | SAP Code | SAP Name |
|----------|----------|----------|
| MR | BANF | Purchase Requisition |
| PO | BELNR | Purchasing Document |
| GR | MBLNR | Material Document |
| CI | DR | Customer Invoice |
| VI | KR | Vendor Invoice |
| PD | DZ | Payment Document |
| JE | SA | G/L Account Document |

## Troubleshooting

### Range Exhausted
```sql
-- Check status
SELECT * FROM document_number_ranges 
WHERE current_number >= to_number;

-- Auto-extension will handle, or manually extend:
UPDATE document_number_ranges 
SET to_number = to_number + 1000000
WHERE id = 'range-uuid';
```

### Duplicate Numbers
- PostgreSQL row-level locking prevents this
- If occurs, check concurrent transaction handling

### Wrong Tenant Data
```sql
-- Enable RLS
ALTER TABLE material_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON material_requests
FOR ALL USING (company_code = current_setting('app.current_company')::VARCHAR);
```

## Best Practices

✅ **DO:**
- Include company_code in all queries
- Use get_next_number_by_group RPC
- Monitor range utilization
- Enable auto-extension

❌ **DON'T:**
- Manually assign numbers
- Share ranges across tenants
- Change format mid-year
- Reuse subtype codes

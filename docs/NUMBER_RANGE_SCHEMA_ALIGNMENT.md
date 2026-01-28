# Number Range Schema Alignment Checklist

## Current Implementation Status

### ✅ Existing Fields (Confirmed from Repository)
- `id` (UUID) - Primary key
- `company_code` (VARCHAR)
- `document_type` (VARCHAR)
- `from_number` (VARCHAR)
- `to_number` (VARCHAR)
- `current_number` (VARCHAR)
- `prefix` (VARCHAR)
- `suffix` (VARCHAR)
- `padding_length` (INTEGER)
- `warning_threshold` (INTEGER)
- `is_active` (BOOLEAN)
- `created_at` (TIMESTAMP)
- `modified_at` (TIMESTAMP)

### 🔧 Fields to Add (SAP Alignment)

#### document_number_ranges table
```sql
ALTER TABLE document_number_ranges ADD COLUMN IF NOT EXISTS description VARCHAR(500);
ALTER TABLE document_number_ranges ADD COLUMN IF NOT EXISTS fiscal_year VARCHAR(4);
ALTER TABLE document_number_ranges ADD COLUMN IF NOT EXISTS range_number VARCHAR(2) DEFAULT '01';
ALTER TABLE document_number_ranges ADD COLUMN IF NOT EXISTS is_external BOOLEAN DEFAULT false;
```

#### number_range_alerts table (Already exists)
- Verify all fields from mapping are present

#### number_range_usage_history table (Already exists)
- Verify all fields from mapping are present

## Document Type Standardization

### Current vs SAP-Aligned Values
Update existing document_type values to match SAP conventions:

| Current | SAP-Aligned | SAP Object |
|---------|-------------|------------|
| MATERIAL | MATERIAL | MATL |
| FI_DOCUMENT | FI_DOCUMENT | BELNR |
| PR | PR | BANFN |
| PO | PO | EBELN |
| GR | GR | MBLNR |
| INVOICE | INVOICE | BELNR_INV |
| PROJECT | PROJECT | PSPNR |
| ORDER | ORDER | AUFNR |

## Implementation Priority

1. **High Priority** - Add missing columns to document_number_ranges
2. **Medium Priority** - Standardize document_type values
3. **Low Priority** - Add description field population in UI

## Testing Checklist

- [ ] Verify backward compatibility with existing number assignments
- [ ] Test multi-range support (range_number field)
- [ ] Test fiscal year-based numbering
- [ ] Verify external numbering flag functionality
- [ ] Test alert generation with new schema
- [ ] Verify usage history tracking

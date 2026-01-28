# Document Numbering System - Implementation Summary

## ✅ COMPLETED

### 1. **Schema Design**
- ✅ Codes-only approach (dropped UUID foreign keys from material_requests)
- ✅ Added activity_code, storage_location columns
- ✅ Projects table migrated from `code` to `project_code`
- ✅ Updated current_schema.sql

### 2. **Documentation**
- ✅ Created DOCUMENT_NUMBERING_SYSTEM.md (comprehensive reference)
- ✅ Updated SAP_S4HANA_Field_Mapping_Final.csv with 61+ new mappings
- ✅ Defined all document types (MR, PR, PO, GR, GI, CI, VI, PD, JE, etc.)

### 3. **Design Decisions**
- ✅ Format: [BASE]-[SUBTYPE]-[YY]-[NUMBER]
- ✅ 6 digits for low volume (MR, PR, PO)
- ✅ 8 digits for high volume (GR, GI, CI, VI, PD, JE)
- ✅ Year-dependent numbering for transactional docs
- ✅ Multi-tenant SaaS compatible (company_code isolation)
- ✅ SAP integration ready (dual format storage)

### 4. **Migrations Executed**
- ✅ migrate_projects_to_project_code.sql (renamed code → project_code)
- ✅ add_activity_code_to_mr.sql (added activity_code column)
- ✅ add_storage_location_to_mr.sql (added storage_location column)
- ✅ migrate_to_codes_only.sql (dropped UUID FKs, added code FKs)
- ✅ fix_mr_company_code.sql (updated MR range from 1000 → C001)

### 5. **API Updates**
- ✅ Fixed projects API to use project_code
- ✅ Fixed wbsRepository to use project_code
- ✅ Fixed material-requests API to show project_display
- ✅ Fixed materials API to support plantCode filtering
- ✅ Updated UnifiedMaterialRequestComponent to use project_code

---

## 🚧 PENDING IMPLEMENTATION

### Phase 1: Database Infrastructure (CRITICAL)

#### A. Create New Tables
```sql
-- Run these in order:
1. CREATE TABLE document_type_config
2. CREATE TABLE sap_document_type_mapping
3. CREATE TABLE number_range_audit_log
4. ALTER TABLE document_number_ranges (add auto_extend, extend_by, last_used_date)
```

#### B. Create RPC Function
```sql
CREATE OR REPLACE FUNCTION get_next_number_by_group(
    p_company_code VARCHAR,
    p_document_type VARCHAR,
    p_number_range_group VARCHAR,
    p_fiscal_year VARCHAR
) RETURNS VARCHAR
-- With auto-extension logic
```

#### C. Create Monitoring View
```sql
CREATE VIEW v_number_range_health
-- Shows utilization, health status
```

---

### Phase 2: Seed Data (REQUIRED)

#### A. Document Type Configuration
```sql
-- Insert for company C001:
- MR subtypes (01-06): Standard, Emergency, Stock Transfer, Subcontractor, Project, Maintenance
- PR subtypes (01-05): Standard, Capital, Service, Import, Consignment
- PO subtypes (01-08): Standard, Framework, Subcontract, Emergency, Rental, Service, Consignment, Import
- GR subtypes (01-06): From PO, Without PO, From Production, Return, Transfer, Initial Stock
- GI subtypes (01-05): To Cost Center, To Project, To Production, Scrapping, Sampling
- TR subtypes (01-03): Plant Transfer, Storage Transfer, One-Step
- CI subtypes (01-05): Standard, Proforma, Tax, Export, Intercompany
- VI subtypes (01-05): Standard, Import, Service, Intercompany, Subcontractor
- PD subtypes (01-10): Outgoing, Incoming, Bank, Cash, Check, Credit Card, Wire, Online, NEFT, LC
- JE subtypes (01-10): Standard, Recurring, Reversing, Accrual, Depreciation, Revaluation, Consolidation, Correction, Opening, Closing
```

#### B. Number Ranges
```sql
-- Create ranges for C001:
- MR-01 to MR-06 (6 digits, 1M capacity)
- PR-01 to PR-05 (6 digits, 1M capacity)
- PO-01 to PO-08 (6 digits, 1M capacity)
- GR-01 to GR-06 (8 digits, 100M capacity)
- GI-01 to GI-05 (8 digits, 100M capacity)
- TR-01 to TR-03 (8 digits, 100M capacity)
- CI-01 to CI-05 (8 digits, 100M capacity)
- VI-01 to VI-05 (8 digits, 100M capacity)
- PD-01 to PD-10 (8 digits, 100M capacity)
- JE-01 to JE-10 (8 digits, 100M capacity)
```

#### C. SAP Mappings
```sql
-- Insert SAP document type mappings:
- MR → BANF
- GR → MBLNR + BWART (101, 501, etc.)
- CI → DR
- VI → KR
- PD → DZ
- JE → SA
```

---

### Phase 3: API Layer (REQUIRED)

#### A. Create Number Generation API
```typescript
// app/api/document-numbers/route.ts
POST /api/document-numbers
{
  "company_code": "C001",
  "document_type": "MR",
  "subtype_code": "01",
  "fiscal_year": "2024"
}
→ Returns: "MR-01-24-000123"
```

#### B. Update Existing APIs
```typescript
// Material Requests
- Use get_next_number_by_group instead of get_next_number
- Pass subtype_code from form

// Purchase Orders
- Implement number generation
- Add subtype selection

// Material Movements (future)
- GR, GI, TR APIs with number generation
```

---

### Phase 4: UI Components (REQUIRED)

#### A. Document Type Selector
```typescript
// components/DocumentTypeSelector.tsx
- Fetch document types for company
- Show subtype dropdown
- Display format preview
```

#### B. Update Forms
```typescript
// Material Request Form
- Add subtype selector (01-06)
- Remove manual number entry
- Show generated number after save

// Purchase Order Form
- Add subtype selector
- Implement number generation
```

---

### Phase 5: Monitoring & Admin (RECOMMENDED)

#### A. Number Range Dashboard
```typescript
// app/admin/number-ranges/page.tsx
- Show all ranges with utilization
- Health status indicators
- Extension history
- Manual extension option
```

#### B. Audit Log Viewer
```typescript
// app/admin/number-range-audit/page.tsx
- Show generation history
- Extension events
- Exhaustion alerts
```

---

## 📋 IMPLEMENTATION CHECKLIST

### Immediate (This Week)
- [ ] Run Phase 1 migrations (infrastructure)
- [ ] Run Phase 2 seed data (C001 configuration)
- [ ] Update material-requests API to use new function
- [ ] Test MR creation with new numbering

### Short Term (Next Week)
- [ ] Implement document-numbers API
- [ ] Update all document creation forms
- [ ] Add subtype selectors to UI
- [ ] Create number range health dashboard

### Medium Term (Next Month)
- [ ] Implement GR/GI/TR document types
- [ ] Implement FI document types (CI, VI, PD, JE)
- [ ] Add SAP integration fields
- [ ] Create audit log viewer

### Long Term (Future)
- [ ] Multi-company rollout (C002, C003, etc.)
- [ ] SAP bidirectional sync
- [ ] Advanced analytics on document volumes
- [ ] Automated range extension alerts

---

## 🎯 PRIORITY ORDER

1. **CRITICAL** - Phase 1 (Infrastructure) - Without this, nothing works
2. **CRITICAL** - Phase 2 (Seed Data) - Need at least MR-01 configured
3. **HIGH** - Phase 3A (Number Generation API) - Core functionality
4. **HIGH** - Phase 3B (Update MR API) - Make it work end-to-end
5. **MEDIUM** - Phase 4 (UI Updates) - Better UX
6. **LOW** - Phase 5 (Monitoring) - Nice to have

---

## 🚀 QUICK START (Minimum Viable)

To get Material Requests working with new numbering:

```sql
-- 1. Create tables (5 min)
-- Run infrastructure script

-- 2. Insert MR-01 config (1 min)
INSERT INTO document_type_config VALUES
('uuid', 'C001', 'MR', '01', 'Standard MR', 'Regular material requests', 
 'BANF', '01', 'MR-01-{year:02d}-{number:06d}', 6, 'LOW', true, 1, NOW(), NOW());

-- 3. Update MR range (1 min)
UPDATE document_number_ranges 
SET prefix = 'MR-01-24-',
    number_range_group = '01',
    auto_extend = true,
    extend_by = 1000000
WHERE company_code = 'C001' AND document_type = 'MR';

-- 4. Update API (5 min)
-- Change get_next_number to get_next_number_by_group

-- 5. Test (2 min)
-- Create a new MR, should get MR-01-24-000015
```

**Total Time: ~15 minutes for MVP!**

---

## 📞 SUPPORT

- Reference: DOCUMENT_NUMBERING_SYSTEM.md
- SAP Mapping: SAP_S4HANA_Field_Mapping_Final.csv
- Questions: Check conversation history for detailed discussions

---

**Status**: Ready for Phase 1 implementation
**Last Updated**: 2024-01-26

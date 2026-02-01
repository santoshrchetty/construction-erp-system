# Document Numbering System - Complete Reference Guide

## Overview

This document defines the complete document numbering system for the Construction Management SaaS application, aligned with SAP S/4HANA standards while optimized for multi-tenant SaaS architecture.

---

## Format Standard

### **Universal Format**
```
[BASE]-[SUBTYPE]-[YYYY]-[NUMBER]

Components:
- BASE: 2-letter document type code (MR, PR, PO, GR, GI, CI, VI, etc.)
- SUBTYPE: 2-digit subtype code (01-99)
- YYYY: 4-digit fiscal year (2024, 2025, 2026...)
- NUMBER: 6 or 8 digit sequential number

Examples:
MR-01-2024-000123    (Material Request - Standard)
GR-01-2024-00000001  (Goods Receipt - From PO)
CI-01-2024-00000001  (Customer Invoice - Standard)
```

---

## Number Length by Volume

### **6 Digits (1M capacity/year) - LOW VOLUME**
```
Documents: MR, PR, PO, AD
Capacity: 1,000,000 per subtype per year
Format: XXX-XX-YYYY-000000
```

### **8 Digits (100M capacity/year) - HIGH VOLUME**
```
Documents: GR, GI, TR, MI, RV, CI, VI, CC, VC, PD, JE, GD, DP, RC, CL
Capacity: 100,000,000 per subtype per year
Format: XXX-XX-YYYY-00000000
```

---

## Document Type Codes

### **📦 PROCUREMENT (MM Module)**

#### Material Request (MR)
```
MR-01  Material Request - Standard
MR-02  Material Request - Emergency
MR-03  Material Request - Stock Transfer
MR-04  Material Request - Subcontractor
MR-05  Material Request - Project
MR-06  Material Request - Maintenance

SAP Mapping: BANF (Purchase Requisition)
Number Length: 6 digits
Year Dependent: Yes
```

#### Purchase Requisition (PR)
```
PR-01  Purchase Requisition - Standard
PR-02  Purchase Requisition - Capital Equipment
PR-03  Purchase Requisition - Service
PR-04  Purchase Requisition - Import
PR-05  Purchase Requisition - Consignment

SAP Mapping: BANF
Number Length: 6 digits
Year Dependent: Yes
```

#### Purchase Order (PO)
```
PO-01  Purchase Order - Standard
PO-02  Purchase Order - Framework/Blanket
PO-03  Purchase Order - Subcontract
PO-04  Purchase Order - Emergency
PO-05  Purchase Order - Rental
PO-06  Purchase Order - Service
PO-07  Purchase Order - Consignment
PO-08  Purchase Order - Import

SAP Mapping: BELNR (Purchasing Document)
Number Length: 6 digits
Year Dependent: Yes
```

---

### **📊 MATERIAL MOVEMENTS (MM-IM Module)**

#### Goods Receipt (GR)
```
GR-01  Goods Receipt - From PO (SAP: 101)
GR-02  Goods Receipt - Without PO (SAP: 501)
GR-03  Goods Receipt - From Production (SAP: 131)
GR-04  Goods Receipt - Return from Customer (SAP: 161)
GR-05  Goods Receipt - Transfer Receipt (SAP: 311)
GR-06  Goods Receipt - Initial Stock (SAP: 561)

SAP Mapping: MBLNR (Material Document) + BWART (Movement Type)
Number Length: 8 digits
Year Dependent: Yes
```

#### Goods Issue (GI)
```
GI-01  Goods Issue - To Cost Center (SAP: 201)
GI-02  Goods Issue - To Project/WBS (SAP: 261)
GI-03  Goods Issue - To Production Order (SAP: 261)
GI-04  Goods Issue - Scrapping (SAP: 551)
GI-05  Goods Issue - Sampling (SAP: 221)

SAP Mapping: MBLNR + BWART
Number Length: 8 digits
Year Dependent: Yes
```

#### Transfer (TR)
```
TR-01  Transfer - Plant to Plant (SAP: 301)
TR-02  Transfer - Storage Location (SAP: 311)
TR-03  Transfer - One-Step (SAP: 309)

SAP Mapping: MBLNR + BWART
Number Length: 8 digits
Year Dependent: Yes
```

#### Material Issue (MI)
```
MI-01  Material Issue - To Production
MI-02  Material Issue - To Project
MI-03  Material Issue - To Maintenance

SAP Mapping: MBLNR + BWART 261/201
Number Length: 8 digits
Year Dependent: Yes
```

#### Reversal (RV)
```
RV-01  Reversal - Goods Receipt (SAP: 102)
RV-02  Reversal - Goods Issue (SAP: 202)
RV-03  Reversal - Transfer (SAP: 302)

SAP Mapping: MBLNR + BWART
Number Length: 8 digits
Year Dependent: Yes
```

---

### **💰 FINANCIAL DOCUMENTS (FI Module)**

#### Customer Invoice (CI)
```
CI-01  Customer Invoice - Standard
CI-02  Customer Invoice - Proforma
CI-03  Customer Invoice - Tax Invoice
CI-04  Customer Invoice - Export
CI-05  Customer Invoice - Intercompany

SAP Mapping: DR (Customer Invoice)
Number Length: 8 digits
Year Dependent: Yes
```

#### Vendor Invoice (VI)
```
VI-01  Vendor Invoice - Standard
VI-02  Vendor Invoice - Import
VI-03  Vendor Invoice - Service
VI-04  Vendor Invoice - Intercompany
VI-05  Vendor Invoice - Subcontractor

SAP Mapping: KR (Vendor Invoice)
Number Length: 8 digits
Year Dependent: Yes
```

#### Customer Credit (CC)
```
CC-01  Customer Credit Memo - Return
CC-02  Customer Credit Memo - Discount
CC-03  Customer Credit Memo - Price Adjustment
CC-04  Customer Credit Memo - Damage
CC-05  Customer Credit Memo - Cancellation

SAP Mapping: DG (Customer Credit Memo)
Number Length: 8 digits
Year Dependent: Yes
```

#### Vendor Credit (VC)
```
VC-01  Vendor Credit Memo - Return
VC-02  Vendor Credit Memo - Discount
VC-03  Vendor Credit Memo - Price Adjustment
VC-04  Vendor Credit Memo - Quality Issue
VC-05  Vendor Credit Memo - Cancellation

SAP Mapping: KG (Vendor Credit Memo)
Number Length: 8 digits
Year Dependent: Yes
```

#### Payment Document (PD)
```
PD-01  Payment - Outgoing (Vendor)
PD-02  Payment - Incoming (Customer)
PD-03  Payment - Bank Transfer
PD-04  Payment - Cash
PD-05  Payment - Check
PD-06  Payment - Credit Card
PD-07  Payment - Wire Transfer
PD-08  Payment - Online/UPI
PD-09  Payment - NEFT/RTGS
PD-10  Payment - LC (Letter of Credit)

SAP Mapping: DZ (Payment Document)
Number Length: 8 digits
Year Dependent: Yes
```

#### Journal Entry (JE)
```
JE-01  Journal Entry - Standard
JE-02  Journal Entry - Recurring
JE-03  Journal Entry - Reversing
JE-04  Journal Entry - Accrual
JE-05  Journal Entry - Depreciation
JE-06  Journal Entry - Revaluation
JE-07  Journal Entry - Consolidation
JE-08  Journal Entry - Correction
JE-09  Journal Entry - Opening Balance
JE-10  Journal Entry - Closing

SAP Mapping: SA (G/L Account Document)
Number Length: 8 digits
Year Dependent: Yes
```

#### General Document (GD)
```
GD-01  G/L Document - Standard
GD-02  G/L Document - Bank Posting
GD-03  G/L Document - Tax Posting
GD-04  G/L Document - Asset Posting
GD-05  G/L Document - Inventory Posting

SAP Mapping: AB (Accounting Document)
Number Length: 8 digits
Year Dependent: Yes
```

#### Down Payment (DP)
```
DP-01  Down Payment - Customer
DP-02  Down Payment - Vendor
DP-03  Down Payment - Clearing
DP-04  Down Payment - Request
DP-05  Down Payment - Refund

SAP Mapping: ZP (Down Payment)
Number Length: 8 digits
Year Dependent: Yes
```

#### Receipt Confirmation (RC)
```
RC-01  Receipt - Invoice Receipt
RC-02  Receipt - Payment Receipt
RC-03  Receipt - Goods Receipt
RC-04  Receipt - Service Receipt

SAP Mapping: RE (Invoice Receipt)
Number Length: 8 digits
Year Dependent: Yes
```

#### Clearing Document (CL)
```
CL-01  Clearing - AR (Customer)
CL-02  Clearing - AP (Vendor)
CL-03  Clearing - Bank Reconciliation
CL-04  Clearing - Intercompany
CL-05  Clearing - Advance

SAP Mapping: AB (Accounting Document)
Number Length: 8 digits
Year Dependent: Yes
```

#### Adjustment Document (AD)
```
AD-01  Adjustment - Period End
AD-02  Adjustment - Currency Revaluation
AD-03  Adjustment - Error Correction
AD-04  Adjustment - Rounding
AD-05  Adjustment - Provision

SAP Mapping: SA (G/L Account Document)
Number Length: 6 digits
Year Dependent: Yes
```

---

## SaaS Multi-Tenancy

### **Tenant Isolation**
```
Each company_code represents a separate tenant:
- C001: Construction Company A
- C002: Manufacturing Company B
- C003: Retail Company C

Same document numbers across tenants:
C001: MR-01-2024-000001
C002: MR-01-2024-000001  ← Different tenant, same number OK
C003: MR-01-2024-000001
```

### **Tenant Configuration**
```sql
-- Each tenant can customize document types
document_type_config:
  - company_code (Tenant ID)
  - base_document_type
  - subtype_code
  - subtype_name (Tenant-specific)
  - description
```

---

## Number Range Management

### **Range Configuration**
```sql
document_number_ranges:
  - company_code: Tenant ID
  - document_type: Base type (MR, GR, CI, etc.)
  - fiscal_year: Year (2024, 2025, etc.)
  - number_range_group: Subtype (01, 02, 03...)
  - prefix: Display prefix (MR-01-2024-)
  - from_number: Start (1)
  - to_number: End (999999 or 99999999)
  - current_number: Last used
  - year_dependent: Reset each year (true/false)
  - status: ACTIVE/INACTIVE/EXHAUSTED
  - auto_extend: Auto-extend when exhausted
  - extend_by: Extension amount
```

### **Auto-Extension**
```
When range exhausted:
1. Check auto_extend = true
2. Extend: to_number += extend_by
3. Continue numbering
4. Log extension event

Example:
Range: 1 to 999,999
Exhausted at: 999,999
Extended to: 1,999,999
Next number: 1,000,000
```

### **Monitoring Thresholds**
```
warning_threshold: 90%  → Alert at 900,000
critical_threshold: 95% → Critical at 950,000
```

---

## SAP Integration

### **Dual Format Storage**
```sql
material_movements:
  - document_number: "GR-01-2024-00000001" (Display)
  - sap_mblnr: "5300000001" (SAP MBLNR)
  - sap_mjahr: "2024" (SAP Year)
  - sap_bwart: "101" (SAP Movement Type)
  - sap_blart: "WE" (SAP Document Type)
```

### **Mapping Table**
```sql
sap_document_type_mapping:
  - our_doc_type: "GR"
  - our_subtype: "01"
  - sap_blart: "WE"
  - sap_bwart: "101"
  - description: "Goods Receipt from PO"
```

---

## Best Practices

### **DO:**
- ✅ Always include company_code in queries
- ✅ Use year-dependent ranges for transactional docs
- ✅ Monitor range utilization regularly
- ✅ Enable auto-extension for high-volume types
- ✅ Store both display and SAP formats
- ✅ Use 8 digits for high-volume documents
- ✅ Never reuse subtype codes

### **DON'T:**
- ❌ Change number format mid-year
- ❌ Share number ranges across tenants
- ❌ Manually assign document numbers
- ❌ Delete number range records
- ❌ Reuse subtype codes with different meanings

---

## Capacity Planning

### **Volume Guidelines**
```
6-digit (1M/year):
- 250 days × 4,000 docs/day = 1M
- Use for: MR, PR, PO, AD

8-digit (100M/year):
- 250 days × 400,000 docs/day = 100M
- Use for: GR, GI, CI, VI, PD, JE
```

---

## Migration Guide

### **From Legacy System**
```sql
-- Backup old numbers
ALTER TABLE material_requests ADD COLUMN old_document_number VARCHAR;

-- Assign new numbers
UPDATE material_requests
SET document_number = 'MR-01-2024-' || LPAD(ROW_NUMBER() OVER (ORDER BY created_at)::TEXT, 6, '0'),
    old_document_number = document_number;
```

---

## Troubleshooting

### **Issue: Range Exhausted**
```
Solution: Auto-extension will handle automatically
Manual: UPDATE document_number_ranges SET to_number = to_number + 1000000
```

### **Issue: Duplicate Numbers**
```
Cause: Concurrent requests
Solution: PostgreSQL row-level locking prevents this
Verify: Check current_number increments correctly
```

### **Issue: Wrong Tenant Data**
```
Cause: Missing company_code filter
Solution: Always include WHERE company_code = ?
Enable: Row-Level Security (RLS) policies
```

---

## Version History

- **v1.0** (2024-01-26): Initial document numbering system
- **v2.0** (2024-01-26): Added SAP alignment and SaaS multi-tenancy

---

## References

- SAP S/4HANA NRIV Table (Number Range Intervals)
- SAP S/4HANA TNRO Table (Number Range Objects)
- SAP Material Document (MBLNR/BWART)
- SAP Financial Document (BELNR/BLART)

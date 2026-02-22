================================================================================
PROCUREMENT CYCLE REFERENCE DOCUMENT
Material Request → Reservation/Purchase Requisition → Purchase Order → 
Goods Receipt → Invoice Receipt
================================================================================

TABLE OF CONTENTS
1. Overview & Business Process Flow
2. Document Types & Numbering
3. Account Assignment (Cost Booked To)
4. Stock Availability Check Logic
5. Database Schema
6. Document Status Flow
7. Field Mapping Across Documents
8. User Roles & Responsibilities
9. Approval Workflows
10. Implementation Roadmap

================================================================================
1. OVERVIEW & BUSINESS PROCESS FLOW
================================================================================

COMPLETE PROCUREMENT CYCLE:

┌─────────────────────────────────────────────────────────────────────┐
│                    PROCUREMENT PROCESS FLOW                          │
└─────────────────────────────────────────────────────────────────────┘

PHASE 1: MATERIAL REQUEST (MR)
├─ User creates MR with line items
├─ Selects MR Type: Project/Maintenance/General/Asset/Office/Safety/Equipment
├─ Each line has "Cost Booked To" (account assignment)
├─ Submits for approval
├─ 2-Step Approval: Manager → Department Head
└─ Status: DRAFT → SUBMITTED → IN_APPROVAL → APPROVED/REJECTED

PHASE 2: STOCK AVAILABILITY CHECK (Automatic after approval)
├─ System checks stock for each MR line item
├─ Compares: available_stock vs requested_quantity
└─ Decision per line:
    ├─ STOCK AVAILABLE → Create RESERVATION (RS)
    ├─ PARTIAL STOCK → Create RS (partial) + PR (shortage)
    └─ NO STOCK → Create PURCHASE REQUISITION (PR)

PHASE 3A: RESERVATION PATH (Stock Available)
├─ System creates Reservation (RS)
├─ Updates: material_storage_data.reserved_stock
├─ Storekeeper issues material (Goods Issue - GI)
├─ Posts to Project/Cost Center
└─ Status: RESERVED → GOODS_ISSUED → CLOSED

PHASE 3B: PROCUREMENT PATH (Stock Not Available)
├─ System creates Purchase Requisition (PR)
├─ Procurement reviews and creates Purchase Order (PO)
├─ PO sent to Vendor
├─ Goods Receipt (GR) when materials arrive
├─ Invoice Receipt (IR) when vendor invoice received
└─ Status: PR → PO → GR → IR → CLOSED

PHASE 4: GOODS RECEIPT (GR)
├─ Materials arrive at site/warehouse
├─ Storekeeper records GR against PO
├─ Updates: material_storage_data.current_stock
├─ Links to PO and PR
└─ Status: GR_POSTED

PHASE 5: INVOICE RECEIPT (IR)
├─ Vendor invoice received
├─ 3-way match: PO ↔ GR ↔ Invoice
├─ Post to Finance (FI)
├─ Create payment obligation
└─ Status: IR_POSTED → PAYMENT_PENDING → PAID

================================================================================
2. DOCUMENT TYPES & NUMBERING
================================================================================

DOCUMENT NUMBERING SCHEME:

┌──────────────────────────────────────────────────────────────┐
│ Document Type │ Prefix │ Format              │ Example       │
├──────────────────────────────────────────────────────────────┤
│ Material Req  │ MR     │ MR-CC-YYYY-NNNNNN   │ MR-01-2026-000001 │
│ Reservation   │ RES    │ RES-PP-NNNNNN       │ RES-P001-000123   │
│ Purchase Req  │ PR     │ PR-CC-YYYY-NNNNNN   │ PR-01-2026-000045 │
│ Purchase Order│ PO     │ PO-CC-YYYY-NNNNNN   │ PO-01-2026-000789 │
│ Goods Receipt │ GR     │ GR-PP-YYYY-NNNNNN   │ GR-P001-2026-0012 │
│ Invoice       │ IR     │ IR-CC-YYYY-NNNNNN   │ IR-01-2026-000456 │
└──────────────────────────────────────────────────────────────┘

CC = Company Code (2 digits)
PP = Plant Code (4 characters)
YYYY = Year
NNNNNN = Sequential number

================================================================================
3. ACCOUNT ASSIGNMENT (COST BOOKED TO)
================================================================================

CUSTOM 2-LETTER CODES:

┌────────────────────────────────────────────────────────────────────┐
│ Code │ Name                  │ Required Fields              │ Use   │
├────────────────────────────────────────────────────────────────────┤
│ CC   │ Cost Center           │ cost_center                  │ Overhead │
│ WB   │ Project (WBS)         │ wbs_element                  │ Project  │
│ AS   │ Asset                 │ asset_number                 │ CapEx    │
│ WA   │ Project with Activity │ wbs_element, activity_code   │ Project  │
│ OP   │ Production Order      │ order_number                 │ Mfg      │
│ OM   │ Maintenance Order     │ order_number                 │ Maint    │
│ OQ   │ Quality Order         │ order_number                 │ Quality  │
└────────────────────────────────────────────────────────────────────┘

MR TYPE → DEFAULT COST BOOKED TO MAPPING:

┌──────────────────────────────────────────────────────────────┐
│ MR Type       │ Default Code │ Allowed Codes              │
├──────────────────────────────────────────────────────────────┤
│ PROJECT       │ WB           │ WB, WA                     │
│ MAINTENANCE   │ OM           │ OM, CC                     │
│ GENERAL       │ CC           │ CC                         │
│ ASSET         │ AS           │ AS                         │
│ OFFICE        │ CC           │ CC                         │
│ SAFETY        │ CC           │ CC, WB                     │
│ EQUIPMENT     │ AS           │ AS, OM                     │
└──────────────────────────────────────────────────────────────┘

ACCOUNT ASSIGNMENT FLOW:
MR Line Item → PR Line Item → PO Line Item → GR → FI Posting
(All documents maintain same account assignment)

================================================================================
4. STOCK AVAILABILITY CHECK LOGIC
================================================================================

TRIGGERED: Immediately after MR final approval

LOGIC PER LINE ITEM:

1. GET STOCK DATA:
   SELECT current_stock, reserved_stock
   FROM material_storage_data
   WHERE material_id = :material_id
   AND storage_location_id = :storage_location_id
   
   available_stock = current_stock - reserved_stock

2. COMPARE:
   IF available_stock >= requested_quantity THEN
      → FULLY AVAILABLE
   ELSIF available_stock > 0 AND available_stock < requested_quantity THEN
      → PARTIALLY AVAILABLE
   ELSE
      → NOT AVAILABLE
   END IF

3. ACTION:

   FULLY AVAILABLE:
   ├─ Create Reservation (RS) for full quantity
   ├─ Update: reserved_stock += requested_quantity
   ├─ Update MR item: fulfillment_type = 'STOCK'
   └─ Status: RESERVED

   PARTIALLY AVAILABLE:
   ├─ Create Reservation (RS) for available quantity
   ├─ Update: reserved_stock += available_quantity
   ├─ Create PR for shortage (requested - available)
   ├─ Update MR item: fulfillment_type = 'PARTIAL_STOCK'
   │   stock_reserved_qty = available_quantity
   │   purchase_qty = shortage_quantity
   └─ Status: PARTIALLY_FULFILLED

   NOT AVAILABLE:
   ├─ Create PR for full quantity
   ├─ Update MR item: fulfillment_type = 'PURCHASE'
   │   purchase_qty = requested_quantity
   └─ Status: TO_BE_PROCURED

EXAMPLE:
MR Line: 100 EA Cement requested
Stock Check: 60 EA available
Result:
├─ Reservation: 60 EA (from stock)
└─ PR: 40 EA (to be purchased)

================================================================================
5. DATABASE SCHEMA
================================================================================

5.1 MATERIAL REQUESTS
─────────────────────────────────────────────────────────────────
material_requests (Header)
├─ id UUID PRIMARY KEY
├─ request_number VARCHAR(20) UNIQUE
├─ mr_type VARCHAR(20) -- PROJECT, MAINTENANCE, GENERAL, ASSET, etc.
├─ status VARCHAR(20) -- DRAFT, SUBMITTED, IN_APPROVAL, APPROVED, REJECTED
├─ priority VARCHAR(10) -- LOW, MEDIUM, HIGH, URGENT
├─ company_code VARCHAR(4)
├─ plant_code VARCHAR(4)
├─ required_date DATE
├─ purpose TEXT
├─ justification TEXT
├─ total_amount NUMERIC(15,2)
├─ currency_code VARCHAR(3)
├─ created_by UUID
└─ created_at TIMESTAMP

material_request_items (Line Items)
├─ id UUID PRIMARY KEY
├─ request_id UUID → material_requests(id)
├─ line_number INTEGER
├─ material_id UUID → materials(id)
├─ material_code VARCHAR(18)
├─ material_name VARCHAR(100)
├─ description TEXT
├─ requested_quantity NUMERIC(13,3)
├─ base_uom VARCHAR(3)
├─ estimated_price NUMERIC(13,2)
├─ storage_location_id UUID
├─ plant_code VARCHAR(4)
│
├─ COST BOOKED TO (Account Assignment)
├─ account_assignment_code VARCHAR(2) -- CC, WB, AS, WA, OM, OP, OQ
├─ cost_center VARCHAR(10)
├─ wbs_element VARCHAR(24)
├─ activity_code VARCHAR(12)
├─ asset_number VARCHAR(12)
├─ order_number VARCHAR(12)
│
├─ FULFILLMENT TRACKING
├─ fulfillment_type VARCHAR(20) -- STOCK, PURCHASE, PARTIAL_STOCK
├─ stock_available_qty NUMERIC(13,3)
├─ stock_reserved_qty NUMERIC(13,3)
├─ purchase_qty NUMERIC(13,3)
├─ reservation_id UUID → reservations(id)
└─ pr_id UUID → purchase_requisitions(id)

5.2 RESERVATIONS
─────────────────────────────────────────────────────────────────
reservations (Header)
├─ id UUID PRIMARY KEY
├─ reservation_number VARCHAR(20) UNIQUE
├─ mr_id UUID → material_requests(id)
├─ plant_code VARCHAR(4)
├─ status VARCHAR(20) -- ACTIVE, GOODS_ISSUED, CANCELLED
├─ created_by UUID
└─ created_at TIMESTAMP

reservation_items (Line Items)
├─ id UUID PRIMARY KEY
├─ reservation_id UUID → reservations(id)
├─ mr_item_id UUID → material_request_items(id)
├─ line_number INTEGER
├─ material_id UUID → materials(id)
├─ storage_location_id UUID
├─ reserved_quantity NUMERIC(13,3)
├─ issued_quantity NUMERIC(13,3) DEFAULT 0
├─ base_uom VARCHAR(3)
├─ account_assignment_code VARCHAR(2)
├─ cost_center VARCHAR(10)
├─ wbs_element VARCHAR(24)
├─ activity_code VARCHAR(12)
└─ created_at TIMESTAMP

5.3 PURCHASE REQUISITIONS
─────────────────────────────────────────────────────────────────
purchase_requisitions (Header)
├─ id UUID PRIMARY KEY
├─ pr_number VARCHAR(20) UNIQUE
├─ mr_id UUID → material_requests(id)
├─ status VARCHAR(20) -- DRAFT, SUBMITTED, APPROVED, CONVERTED_TO_PO
├─ company_code VARCHAR(4)
├─ plant_code VARCHAR(4)
├─ total_amount NUMERIC(15,2)
├─ currency_code VARCHAR(3)
├─ created_by UUID
└─ created_at TIMESTAMP

purchase_requisition_items (Line Items)
├─ id UUID PRIMARY KEY
├─ pr_id UUID → purchase_requisitions(id)
├─ mr_item_id UUID → material_request_items(id)
├─ line_number INTEGER
├─ material_id UUID → materials(id)
├─ material_code VARCHAR(18)
├─ quantity NUMERIC(13,3) -- SHORTAGE QUANTITY ONLY
├─ base_uom VARCHAR(3)
├─ unit_price NUMERIC(13,2)
├─ total_price NUMERIC(15,2)
├─ delivery_date DATE
├─ plant_code VARCHAR(4)
├─ storage_location_id UUID
├─ vendor_code VARCHAR(10)
├─ account_assignment_code VARCHAR(2)
├─ cost_center VARCHAR(10)
├─ wbs_element VARCHAR(24)
├─ activity_code VARCHAR(12)
├─ item_status VARCHAR(20) -- OPEN, ORDERED, CLOSED
└─ created_at TIMESTAMP

5.4 PURCHASE ORDERS
─────────────────────────────────────────────────────────────────
purchase_orders (Header)
├─ id UUID PRIMARY KEY
├─ po_number VARCHAR(20) UNIQUE
├─ pr_id UUID → purchase_requisitions(id)
├─ vendor_code VARCHAR(10)
├─ vendor_name VARCHAR(100)
├─ po_date DATE
├─ delivery_date DATE
├─ total_amount NUMERIC(15,2)
├─ currency_code VARCHAR(3)
├─ status VARCHAR(20) -- DRAFT, RELEASED, GOODS_RECEIVED, INVOICED
├─ created_by UUID
└─ created_at TIMESTAMP

purchase_order_items (Line Items)
├─ id UUID PRIMARY KEY
├─ po_id UUID → purchase_orders(id)
├─ pr_item_id UUID → purchase_requisition_items(id)
├─ line_number INTEGER
├─ material_id UUID → materials(id)
├─ quantity NUMERIC(13,3)
├─ unit_price NUMERIC(13,2)
├─ tax_code VARCHAR(2)
├─ delivery_date DATE
├─ account_assignment_code VARCHAR(2)
├─ cost_center VARCHAR(10)
├─ wbs_element VARCHAR(24)
└─ gr_quantity NUMERIC(13,3) DEFAULT 0 -- Goods received so far

5.5 GOODS RECEIPTS
─────────────────────────────────────────────────────────────────
goods_receipts (Header)
├─ id UUID PRIMARY KEY
├─ gr_number VARCHAR(20) UNIQUE
├─ po_id UUID → purchase_orders(id)
├─ gr_date DATE
├─ plant_code VARCHAR(4)
├─ storage_location_id UUID
├─ posted_by UUID
└─ posted_at TIMESTAMP

goods_receipt_items (Line Items)
├─ id UUID PRIMARY KEY
├─ gr_id UUID → goods_receipts(id)
├─ po_item_id UUID → purchase_order_items(id)
├─ material_id UUID → materials(id)
├─ quantity_received NUMERIC(13,3)
├─ quantity_accepted NUMERIC(13,3)
├─ quantity_rejected NUMERIC(13,3)
├─ batch_number VARCHAR(10)
├─ account_assignment_code VARCHAR(2)
├─ cost_center VARCHAR(10)
└─ wbs_element VARCHAR(24)

5.6 STOCK TABLE
─────────────────────────────────────────────────────────────────
material_storage_data
├─ id UUID PRIMARY KEY
├─ material_id UUID → materials(id)
├─ storage_location_id UUID → storage_locations(id)
├─ current_stock NUMERIC(15,4) -- Total physical stock
├─ reserved_stock NUMERIC(15,4) -- Reserved for MRs
├─ available_stock NUMERIC(15,4) GENERATED -- current - reserved
├─ last_movement_date DATE
└─ bin_location VARCHAR(20)

5.7 ACCOUNT ASSIGNMENT MASTER
─────────────────────────────────────────────────────────────────
account_assignment_types
├─ code VARCHAR(2) PRIMARY KEY
├─ name VARCHAR(50) -- Display name
├─ description TEXT
├─ requires_cost_center BOOLEAN
├─ requires_wbs_element BOOLEAN
├─ requires_activity_code BOOLEAN
├─ requires_asset_number BOOLEAN
├─ requires_order_number BOOLEAN
└─ is_active BOOLEAN

mr_type_account_assignment_mapping
├─ mr_type VARCHAR(20)
├─ account_assignment_code VARCHAR(2)
├─ is_default BOOLEAN
├─ is_allowed BOOLEAN
└─ display_order INTEGER

================================================================================
6. DOCUMENT STATUS FLOW
================================================================================

MATERIAL REQUEST STATUS:
DRAFT → SUBMITTED → IN_APPROVAL → APPROVED → FULFILLED
                                 ↓
                              REJECTED

RESERVATION STATUS:
ACTIVE → PARTIALLY_ISSUED → FULLY_ISSUED → CLOSED
       ↓
    CANCELLED

PURCHASE REQUISITION STATUS:
DRAFT → SUBMITTED → APPROVED → CONVERTED_TO_PO → CLOSED
                   ↓
                REJECTED

PURCHASE ORDER STATUS:
DRAFT → RELEASED → PARTIALLY_RECEIVED → FULLY_RECEIVED → INVOICED → CLOSED
                  ↓
               CANCELLED

GOODS RECEIPT STATUS:
POSTED → QUALITY_CHECK → ACCEPTED → CLOSED
                        ↓
                     REJECTED

INVOICE RECEIPT STATUS:
RECEIVED → MATCHED → POSTED → PAYMENT_PENDING → PAID
          ↓
       BLOCKED

================================================================================
7. FIELD MAPPING ACROSS DOCUMENTS
================================================================================

ORGANIZATIONAL DATA (Header Level):
┌────────────────────────────────────────────────────────────────┐
│ Field         │ MR    │ RS    │ PR    │ PO    │ GR    │ IR    │
├────────────────────────────────────────────────────────────────┤
│ company_code  │ ✓     │ -     │ ✓     │ ✓     │ -     │ ✓     │
│ plant_code    │ ✓     │ ✓     │ ✓     │ ✓     │ ✓     │ -     │
│ currency_code │ ✓     │ -     │ ✓     │ ✓     │ -     │ ✓     │
└────────────────────────────────────────────────────────────────┘

MATERIAL DATA (Line Item Level):
┌────────────────────────────────────────────────────────────────┐
│ Field            │ MR  │ RS  │ PR  │ PO  │ GR  │ IR  │
├────────────────────────────────────────────────────────────────┤
│ material_id      │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │
│ material_code    │ ✓   │ -   │ ✓   │ ✓   │ -   │ ✓   │
│ quantity         │ ✓   │ ✓   │ ✓*  │ ✓   │ ✓   │ -   │
│ base_uom         │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ -   │
│ unit_price       │ ✓   │ -   │ ✓   │ ✓   │ -   │ ✓   │
│ storage_location │ ✓   │ ✓   │ ✓   │ -   │ ✓   │ -   │
└────────────────────────────────────────────────────────────────┘
* PR quantity = MR quantity - available stock (shortage only)

ACCOUNT ASSIGNMENT (Line Item Level):
┌────────────────────────────────────────────────────────────────┐
│ Field                    │ MR  │ RS  │ PR  │ PO  │ GR  │ FI  │
├────────────────────────────────────────────────────────────────┤
│ account_assignment_code  │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │
│ cost_center              │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │
│ wbs_element              │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │
│ activity_code            │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │
│ asset_number             │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │
│ order_number             │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │ ✓   │
└────────────────────────────────────────────────────────────────┘
All account assignment fields flow through entire cycle unchanged

TRACEABILITY (Foreign Keys):
┌────────────────────────────────────────────────────────────────┐
│ Document │ Links To                                            │
├────────────────────────────────────────────────────────────────┤
│ RS       │ mr_id, mr_item_id                                   │
│ PR       │ mr_id, mr_item_id                                   │
│ PO       │ pr_id, pr_item_id                                   │
│ GR       │ po_id, po_item_id                                   │
│ IR       │ po_id, gr_id                                        │
└────────────────────────────────────────────────────────────────┘

================================================================================
8. USER ROLES & RESPONSIBILITIES
================================================================================

REQUESTER (Engineer/Site Manager):
├─ Create Material Request
├─ Select materials and quantities
├─ Specify "Cost Booked To" per line
├─ Submit for approval
└─ Track MR status

MANAGER:
├─ Review MR (Step 1 approval)
├─ Approve/Reject with comments
└─ View team's MRs

DEPARTMENT HEAD:
├─ Review MR (Step 2 approval)
├─ Approve/Reject with comments
└─ View department MRs

STOREKEEPER:
├─ View approved MRs
├─ Check stock availability (system-assisted)
├─ Issue materials (Goods Issue from Reservation)
├─ Receive materials (Goods Receipt from PO)
└─ Update stock levels

PROCUREMENT OFFICER:
├─ View PRs generated from MRs
├─ Review and approve PRs
├─ Create Purchase Orders
├─ Send POs to vendors
├─ Track deliveries
└─ Match invoices

FINANCE:
├─ View Invoice Receipts
├─ Perform 3-way match (PO-GR-IR)
├─ Post to GL accounts
├─ Process payments
└─ Cost reporting

================================================================================
9. APPROVAL WORKFLOWS
================================================================================

MATERIAL REQUEST APPROVAL (2-Step):
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Manager Approval                                    │
│ ├─ Agent Rule: MANAGER (from org_hierarchy)                │
│ ├─ Completion Rule: ANY (1 approval required)              │
│ └─ Timeout: 48 hours                                        │
│                                                             │
│ Step 2: Department Head Approval                           │
│ ├─ Agent Rule: DEPT_HEAD (from role_assignments)          │
│ ├─ Completion Rule: ANY (1 approval required)              │
│ └─ Timeout: 48 hours                                        │
└─────────────────────────────────────────────────────────────┘

PURCHASE REQUISITION APPROVAL (1-Step):
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Procurement Manager Approval                       │
│ ├─ Agent Rule: PROCUREMENT_MGR                             │
│ ├─ Completion Rule: ANY (1 approval required)              │
│ └─ Timeout: 24 hours                                        │
└─────────────────────────────────────────────────────────────┘

PURCHASE ORDER APPROVAL (Value-Based):
┌─────────────────────────────────────────────────────────────┐
│ IF PO Value < $10,000:                                      │
│ └─ Step 1: Procurement Manager                             │
│                                                             │
│ IF PO Value >= $10,000 AND < $50,000:                      │
│ ├─ Step 1: Procurement Manager                             │
│ └─ Step 2: Finance Manager                                 │
│                                                             │
│ IF PO Value >= $50,000:                                     │
│ ├─ Step 1: Procurement Manager                             │
│ ├─ Step 2: Finance Manager                                 │
│ └─ Step 3: CFO                                              │
└─────────────────────────────────────────────────────────────┘

================================================================================
10. IMPLEMENTATION ROADMAP
================================================================================

PHASE 1: MATERIAL REQUEST (✓ COMPLETED)
├─ MR Create UI with line items
├─ Account assignment (Cost Booked To) per line
├─ MR List with filters and Excel export
├─ 2-Step approval workflow
├─ Approval modal with MR details
└─ Status tracking

PHASE 2: STOCK CHECK & RESERVATION (NEXT - IN PROGRESS)
├─ Stock availability check function
├─ Reservation creation (auto)
├─ Update material_storage_data.reserved_stock
├─ MR fulfillment tracking
└─ Reservation list UI

PHASE 3: PURCHASE REQUISITION
├─ PR auto-creation from MR (shortage)
├─ PR List UI
├─ PR approval workflow
├─ PR to PO conversion
└─ Vendor selection

PHASE 4: PURCHASE ORDER
├─ PO Create from PR
├─ PO approval workflow (value-based)
├─ PO List UI
├─ PO release to vendor
└─ PO tracking

PHASE 5: GOODS RECEIPT
├─ GR Create against PO
├─ Update stock (current_stock)
├─ Quality inspection
├─ GR List UI
└─ GR posting to FI

PHASE 6: INVOICE RECEIPT
├─ IR Create
├─ 3-way match (PO-GR-IR)
├─ IR posting to FI
├─ Payment processing
└─ Vendor payment

PHASE 7: REPORTING & ANALYTICS
├─ MR to GR tracking report
├─ Procurement cycle time
├─ Cost analysis by project/WBS
├─ Vendor performance
└─ Stock movement report

================================================================================
KEY BUSINESS RULES
================================================================================

1. ACCOUNT ASSIGNMENT:
   - Defined at MR line item level
   - Flows unchanged through entire cycle (MR→RS/PR→PO→GR→IR→FI)
   - Required for all documents
   - Validated against master data

2. STOCK CHECK:
   - Triggered automatically after MR final approval
   - Checks available_stock = current_stock - reserved_stock
   - Creates RS for available stock, PR for shortage
   - Updates fulfillment_type on MR item

3. RESERVATION:
   - Valid for 30 days (configurable)
   - Can be partially issued
   - Updates reserved_stock on creation
   - Updates current_stock on goods issue

4. PURCHASE REQUISITION:
   - Contains only shortage quantity (not full MR quantity)
   - Maintains traceability to MR via mr_item_id
   - Requires procurement approval
   - Can be converted to PO

5. PURCHASE ORDER:
   - Created from approved PR
   - Requires vendor selection
   - Approval based on value thresholds
   - Can have partial goods receipts

6. GOODS RECEIPT:
   - Posted against PO
   - Updates current_stock
   - Can have quality inspection
   - Required for invoice verification

7. INVOICE RECEIPT:
   - Requires 3-way match (PO-GR-IR)
   - Posts to FI with account assignment
   - Creates payment obligation
   - Closes procurement cycle

================================================================================
END OF REFERENCE DOCUMENT
================================================================================

This document serves as the master reference for implementing the complete
procurement cycle from Material Request through Invoice Receipt.

All implementations should follow the schemas, flows, and business rules
defined in this document to ensure consistency and traceability.

Last Updated: 2024
Version: 1.0

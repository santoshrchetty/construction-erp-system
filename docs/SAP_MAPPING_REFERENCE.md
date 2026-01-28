# SAP to Construction App - Field Mapping Reference

## Overview
This document maps SAP ERP fields/concepts to our Construction App implementation for reference and future integration.

---

## Material Master (MM01/MM02/MM03)

### Basic Data

| SAP Field | SAP T-Code | Construction App Field | Table | Notes |
|-----------|------------|------------------------|-------|-------|
| Material Number | MARA-MATNR | material_code | materials | Max 31 chars (SAP: 18/40) |
| Material Description | MAKT-MAKTX | material_name | materials | Max 240 chars (SAP: 40) |
| Material Type | MARA-MTART | material_type | materials | FG/RM/SFG/TG/SER vs FERT/ROH/HALB |
| Base Unit of Measure | MARA-MEINS | base_uom | materials | BAG/TON/CUM/KG/LTR/PCS/MTR/EA |
| Material Group | MARA-MATKL | material_group | materials | Custom groups vs SAP MATKL |
| Gross Weight | MARA-BRGEW | gross_weight | materials | Decimal(15,3) |
| Net Weight | MARA-NTGEW | net_weight | materials | Decimal(15,3) |
| Weight Unit | MARA-GEWEI | weight_unit | materials | KG/TON/G/LB |
| Volume | MARA-VOLUM | volume | materials | Decimal(15,3) |
| Volume Unit | MARA-VOLEH | volume_unit | materials | CUM/LTR/ML/GAL |

### Material Type Mapping

| SAP Code | SAP Description | Construction App Code | App Description |
|----------|-----------------|----------------------|-----------------|
| FERT | Finished Product | FG | Finished Goods |
| ROH | Raw Material | RM | Raw Materials |
| HALB | Semi-Finished Product | SFG | Semi-Finished |
| HAWA | Trading Goods | TG | Trading Goods |
| DIEN | Services | SER | Services |
| HIBE | Operating Supplies | RM | Raw Materials |
| VERP | Packaging Material | RM | Raw Materials |
| NLAG | Non-Stock Material | - | Not implemented |

### Plant Data (MM02 - Plant View)

| SAP Field | SAP Table | Construction App Field | Table | Notes |
|-----------|-----------|------------------------|-------|-------|
| Plant | MARC-WERKS | plant_code | material_plant_data | 4-char code |
| Procurement Type | MARC-BESKZ | procurement_type | material_plant_data | E/F (In-house/External) |
| MRP Type | MARC-DISMM | mrp_type | material_plant_data | MRP controller |
| Reorder Point | MARC-MINBE | reorder_point | material_plant_data | Decimal(15,3) |
| Safety Stock | MARC-EISBE | safety_stock | material_plant_data | Decimal(15,3) |
| Minimum Lot Size | MARC-BSTMI | minimum_lot_size | material_plant_data | Decimal(15,3) |
| Planned Delivery Time | MARC-PLIFZ | planned_delivery_time | material_plant_data | Days (integer) |
| Plant-Specific Status | MARC-MMSTA | plant_status | material_plant_data | ACTIVE/INACTIVE/BLOCKED |

### Accounting/Valuation Data

| SAP Field | SAP Table | Construction App Field | Table | Notes |
|-----------|-----------|------------------------|-------|-------|
| Valuation Class | MBEW-BKLAS | - | - | Not implemented yet |
| Price Control | MBEW-VPRSV | price_type | material_pricing | STANDARD/MOVING_AVG |
| Standard Price | MBEW-STPRS | price | material_pricing | Decimal(15,2) |
| Moving Average Price | MBEW-VERPR | price | material_pricing | Decimal(15,2) |
| Price Unit | MBEW-PEINH | - | - | Not implemented |
| Currency | MBEW-WAERS | currency | material_pricing | 3-char code |
| Valuation Area | MBEW-BWKEY | plant_code | material_pricing | Plant level valuation |

---

## Organization Structure

### Company Code

| SAP Field | SAP Table | Construction App Field | Table | Notes |
|-----------|-----------|------------------------|-------|-------|
| Company Code | T001-BUKRS | company_code | company_codes | 4-char code |
| Company Name | T001-BUTXT | company_name | company_codes | Varchar(500) |
| Currency | T001-WAERS | currency | company_codes | 3-char code |
| Country | T001-LAND1 | country_code | company_codes | 2-char code |

### Plant

| SAP Field | SAP Table | Construction App Field | Table | Notes |
|-----------|-----------|------------------------|-------|-------|
| Plant | T001W-WERKS | plant_code | plants | 4-char code |
| Plant Name | T001W-NAME1 | plant_name | plants | Varchar(500) |
| Company Code | T001W-BWKEY | company_code | plants | FK to company_codes |
| Address | T001W-ADRNR | address | plants | Text field |

### Storage Location

| SAP Field | SAP Table | Construction App Field | Table | Notes |
|-----------|-----------|------------------------|-------|-------|
| Storage Location | T001L-LGORT | sloc_code | storage_locations | 4-char code |
| Storage Location Name | T001L-LGOBE | sloc_name | storage_locations | Varchar(500) |
| Plant | T001L-WERKS | plant_code | storage_locations | FK to plants |

---

## Inventory Management (MM-IM)

### Stock Overview (MMBE)

| SAP Field | SAP Table | Construction App Field | Table | Notes |
|-----------|-----------|------------------------|-------|-------|
| Unrestricted Stock | MARD-LABST | current_quantity | stock_balances | Decimal(15,3) |
| Stock in Quality Inspection | MARD-INSME | - | - | Not implemented |
| Blocked Stock | MARD-SPEME | - | - | Not implemented |
| Reserved Quantity | - | reserved_quantity | stock_balances | Decimal(15,3) |
| Available Quantity | - | available_quantity | stock_balances | Calculated field |
| Stock Value | MBEW-SALK3 | total_value | stock_balances | Decimal(15,2) |

---

## Material Categories/Groups

### SAP Material Group vs Construction App

| Concept | SAP Implementation | Construction App Implementation |
|---------|-------------------|--------------------------------|
| **Hierarchy** | Material Group (MATKL) - Flat structure | Category → Material Group → Material |
| **Category** | Not standard (custom Z-tables) | material_categories (28 categories) |
| **Group** | Material Group (MATKL) | material_groups (50+ groups) |
| **Examples** | MATKL: 001, 002, 003 | CEMENT-OPC, STEEL-REBAR, AGG-SAND |

### Construction App Categories (Not in Standard SAP)

Our custom categories for construction industry:
- CEMENT, AGGREGATE, STEEL, CONCRETE, BRICK
- ELECTRICAL, PLUMBING, PAINTS, TIMBER, HARDWARE
- TILES, GLASS, MARBLE, SANITARY, DOORS
- HVAC, INSULATION, DAMP_PROOF, CONSUMABLE
- ASPHALT, DRAINAGE, FINISHING, MASONRY, POWER
- SAFETY, SIGNAGE, TOOLS, OTHER

---

## Transaction Code Mapping

| SAP T-Code | SAP Description | Construction App Feature | Component |
|------------|-----------------|-------------------------|-----------|
| MM01 | Create Material Master | Create Material Master | CreateMaterialMaster |
| MM02 | Change Material Master | Maintain Material Master | MaintainMaterialMaster |
| MM03 | Display Material Master | Display Material Master | DisplayMaterialMaster |
| MM50 | Extend Material to Plant | Extend Material to Plant | ExtendMaterialToPlant |
| MM60 | Material Plant Parameters | Material Plant Parameters | MaterialPlantParameters |
| MMBE | Stock Overview | Stock Overview | StockOverview |
| MB51 | Material Document List | - | Not implemented |
| MB52 | Stock List | - | Not implemented |

---

## Key Differences from SAP

### 1. Material Type Codes
- **SAP**: FERT, ROH, HALB, HAWA, DIEN
- **Construction App**: FG, RM, SFG, TG, SER
- **Reason**: Simplified for construction industry

### 2. Category Structure
- **SAP**: Flat material group (MATKL)
- **Construction App**: Two-level hierarchy (Category → Group)
- **Reason**: Better organization for construction materials

### 3. Valuation Level
- **SAP**: Can be Plant or Company Code level
- **Construction App**: Plant level only
- **Reason**: Multi-site construction requires plant-level valuation

### 4. Audit Fields
- **SAP**: ERNAM, ERDAT, AENAM, AEDAT (accessible)
- **Construction App**: created_by, created_at, updated_by, updated_at (database-managed)
- **Reason**: Supabase PostgREST limitation

### 5. Material Number
- **SAP**: 18 chars (old) or 40 chars (new)
- **Construction App**: 31 chars
- **Reason**: Balance between flexibility and database performance

---

## Integration Considerations

### For Future SAP Integration

**Material Master Sync**:
```
SAP MARA/MAKT → Construction App materials
SAP MARC → Construction App material_plant_data
SAP MBEW → Construction App material_pricing
```

**Field Transformations**:
- Material Type: FERT→FG, ROH→RM, HALB→SFG, HAWA→TG, DIEN→SER
- Material Group: SAP MATKL → Construction App material_group (lookup table needed)
- Plant: SAP WERKS → Construction App plant_code (direct mapping)

**Data Flow**:
1. Master data flows from SAP to Construction App (read-only)
2. Transactions created in Construction App
3. Periodic sync back to SAP for financial posting

---

## Version History

### v1.0 - 2025-01-26
- Initial mapping document created
- Material master fields mapped
- Organization structure mapped
- Transaction codes mapped
- Key differences documented

---

## References

- SAP Tables: MARA, MAKT, MARC, MBEW, MARD
- SAP T-Codes: MM01, MM02, MM03, MM50, MM60, MMBE
- Construction App Schema: MATERIALS_SCHEMA_REFERENCE.md

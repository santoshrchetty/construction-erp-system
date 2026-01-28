# Materials Module - Schema Reference

## Overview
This document provides the complete schema reference for the Materials Management module in the Construction ERP system.

## Last Updated
- Date: 2025-01-26
- Updated By: System Documentation
- Changes: Added physical properties, removed parent_category, finalized material groups

---

## Core Tables

### 1. materials
**Purpose**: Global material master data (company-wide)

**Columns**:
- `id` (uuid, PK) - Auto-generated
- `material_code` (varchar(31), UNIQUE, NOT NULL) - Unique material identifier
- `material_name` (varchar(240), NOT NULL) - Material name
- `description` (text) - Detailed description
- `category` (varchar(50)) - FK to material_categories.category_code
- `material_group` (varchar(50)) - FK to material_groups.group_code
- `base_uom` (varchar(10), NOT NULL) - Base unit of measure (BAG, TON, CUM, KG, LTR, PCS, MTR, EA)
- `material_type` (varchar(10), NOT NULL) - FK to material_types.material_type_code
- `weight_unit` (varchar(10)) - Weight unit (KG, TON, G, LB)
- `gross_weight` (decimal(15,3), DEFAULT 0) - Gross weight
- `net_weight` (decimal(15,3), DEFAULT 0) - Net weight
- `volume_unit` (varchar(10)) - Volume unit (CUM, LTR, ML, GAL)
- `volume` (decimal(15,3), DEFAULT 0) - Volume
- `is_active` (boolean, DEFAULT true) - Active status
- `created_at` (timestamp) - Auto-managed by database
- `created_by` (uuid) - User who created (NOT accessible via PostgREST)
- `updated_at` (timestamp) - Auto-managed by database
- `updated_by` (uuid) - User who updated (NOT accessible via PostgREST)

**Notes**:
- `created_at`, `updated_at`, `created_by`, `updated_by` are managed by database triggers
- Do NOT manually set these fields in application code
- Physical properties (weight/volume) added on 2025-01-26

---

### 2. material_categories
**Purpose**: Material classification categories

**Columns**:
- `category_code` (varchar(50), PK) - Category code (e.g., CEMENT, STEEL, AGGREGATE)
- `category_name` (varchar(500), NOT NULL) - Display name
- `description` (text) - Category description
- `is_active` (boolean, DEFAULT true) - Active status
- `created_at` (timestamp) - Auto-managed

**Standard Categories** (28 total):
- CEMENT, AGGREGATE, STEEL, CONCRETE, BRICK
- ELECTRICAL, PLUMBING, PAINTS, TIMBER, HARDWARE
- TILES, GLASS, MARBLE, SANITARY, DOORS
- HVAC, INSULATION, DAMP_PROOF, CONSUMABLE, OTHER
- ASPHALT, DRAINAGE, FINISHING, MASONRY, POWER
- SAFETY, SIGNAGE, TOOLS

**Schema Changes**:
- ❌ REMOVED: `parent_category` column (dropped 2025-01-26)
- Reason: Standard ERP design uses flat categories with hierarchical groups

---

### 3. material_groups
**Purpose**: Sub-classification within categories

**Columns**:
- `id` (uuid, PK) - Auto-generated
- `group_code` (varchar(50), UNIQUE, NOT NULL) - Group code (e.g., CEMENT-OPC, STEEL-REBAR)
- `group_name` (varchar(500), NOT NULL) - Display name
- `category_code` (varchar(50), NOT NULL) - FK to material_categories.category_code
- `description` (text) - Group description
- `is_active` (boolean, DEFAULT true) - Active status
- `created_at` (timestamp) - Auto-managed

**Standard Groups** (50+ groups):
- CEMENT: CEMENT-OPC, CEMENT-PPC, CEMENT-PSC, CEMENT-OTHER
- STEEL: STEEL-REBAR, STEEL-STRUCT, STEEL-SHEET, STEEL-WIRE
- AGGREGATE: AGG-SAND, AGG-GRAVEL, AGG-STONE
- CONCRETE: CONC-RMC, CONC-BLOCKS, CONC-OTHER
- BRICK: BRICK-RED, BRICK-FLY, BRICK-AAC
- ELECTRICAL: ELEC-WIRE, ELEC-SWITCH, ELEC-CONDUIT
- PLUMBING: PLUMB-PIPE, PLUMB-FITTING, PLUMB-VALVE, PLUMB-OTHER
- PAINTS: PAINT-EMUL, PAINT-ENAMEL, PAINT-PRIMER
- TIMBER: TIMBER-HARD, TIMBER-SOFT, TIMBER-PLY
- HARDWARE: HARD-BOLT, HARD-NAIL
- TILES: TILE-FLOOR, TILE-WALL
- SANITARY: SAN-WC, SAN-BASIN, SAN-BATH
- POWER: POWER-GEN, POWER-DIST
- SIGNAGE: SIGN-SAFETY, SIGN-INFO
- ASPHALT: ASPH-MIX, ASPH-SEAL
- DRAINAGE: DRAIN-PIPE, DRAIN-GRATE
- SAFETY: SAFE-PPE, SAFE-BARRIER
- FINISHING: FINISH-PLASTER, FINISH-PUTTY, FINISH-OTHER
- OTHER: OTHER-MISC

**Hierarchy**: Category → Group → Material

---

### 4. material_types
**Purpose**: Material type classification

**Columns**:
- `material_type_code` (varchar(10), PK) - Type code
- `material_type_name` (varchar(100), NOT NULL) - Type name
- `description` (text) - Type description
- `is_active` (boolean, DEFAULT true) - Active status
- `created_at` (timestamp) - Auto-managed

**Standard Types**:
- `FG` - Finished Goods (finished construction products)
- `RM` - Raw Materials (raw materials for construction)
- `SFG` - Semi-Finished (semi-finished construction materials)
- `TG` - Trading Goods (trading/resale materials)
- `SER` - Services (service materials)

**Important**: 
- ❌ NOT using SAP codes (FERT, ROH, HALB)
- ✅ Using custom codes (FG, RM, SFG, TG, SER)

---

## Plant-Specific Tables

### 5. material_plant_data
**Purpose**: Plant-specific material parameters

**Columns**:
- `id` (uuid, PK)
- `material_id` (uuid, NOT NULL) - FK to materials.id
- `plant_id` (uuid, NOT NULL) - FK to plants.id
- `material_code` (varchar(31), NOT NULL)
- `plant_code` (varchar(10), NOT NULL)
- `procurement_type` (varchar(10)) - E (In-house), F (External)
- `mrp_type` (varchar(10)) - MRP controller
- `reorder_point` (decimal(15,3))
- `safety_stock` (decimal(15,3))
- `minimum_lot_size` (decimal(15,3))
- `planned_delivery_time` (integer) - Days
- `plant_status` (varchar(20)) - ACTIVE, INACTIVE, BLOCKED
- `is_active` (boolean, DEFAULT true)
- `created_at`, `updated_at`, `created_by`, `updated_by`

---

## Related Tables

### 6. material_pricing
**Purpose**: Material pricing by company/plant

**Columns**:
- `id` (uuid, PK)
- `material_code` (varchar(31), NOT NULL)
- `company_code` (varchar(10), NOT NULL)
- `plant_code` (varchar(10))
- `price_type` (varchar(20)) - STANDARD, MOVING_AVG, etc.
- `price` (decimal(15,2), NOT NULL)
- `currency` (varchar(3), NOT NULL)
- `valid_from` (date, NOT NULL)
- `valid_to` (date)
- `is_active` (boolean, DEFAULT true)
- `created_at`, `updated_at`, `created_by`, `updated_by`

---

## Key Relationships

```
material_categories (1) ──→ (N) material_groups
material_groups (1) ──→ (N) materials
material_types (1) ──→ (N) materials
materials (1) ──→ (N) material_plant_data
materials (1) ──→ (N) material_pricing
plants (1) ──→ (N) material_plant_data
```

---

## Important Notes

### Database-Managed Fields
These fields are managed by database triggers and should NOT be set manually:
- `created_at`
- `updated_at`
- `created_by`
- `updated_by`

### Supabase PostgREST Limitation
The audit fields (`created_by`, `updated_by`) are NOT accessible through Supabase PostgREST API for manual updates. Attempting to set them will result in PGRST204 errors.

### Material Master Operations
1. **Create Material Master** - Creates global material (no plant dependency)
2. **Maintain Material Master** - Updates global material data
3. **Extend Material to Plant** - Makes material available in specific plant
4. **Material Plant Parameters** - Manages plant-specific settings

### Standard ERP Design
- Follows SAP MM module structure
- Global material master (company-wide)
- Plant extensions for plant-specific data
- Flat category structure with hierarchical groups
- No parent-child category relationships

---

## SQL Scripts Reference

### Setup Scripts
- `add-material-physical-properties.sql` - Adds weight/volume columns
- `populate-material-groups.sql` - Populates 40+ material groups
- `populate-remaining-groups.sql` - Adds specialty category groups
- `finalize-groups.sql` - Assigns catch-all groups
- `drop-parent-category.sql` - Removes parent_category column

### Verification Scripts
- `check-categories.sql` - Lists all categories
- `check-material-types.sql` - Lists all material types
- `check-existing-categories.sql` - Verifies category data

---

## Form Fields Reference

### Create/Maintain Material Master Forms
Both forms have identical fields:

**Basic Information**:
- Material Code (required, max 31 chars)
- Material Name (required, max 240 chars)
- Description (optional, text)

**Classification**:
- Category (required, dropdown from material_categories)
- Material Group (optional, dropdown filtered by category)
- Material Type (required, dropdown: FG, RM, SFG, TG, SER)

**Units of Measure**:
- Base UOM (required, dropdown: BAG, TON, CUM, KG, LTR, PCS, MTR, EA)
- Weight Unit (optional, dropdown: KG, TON, G, LB)
- Volume Unit (optional, dropdown: CUM, LTR, ML, GAL)

**Physical Properties**:
- Gross Weight (optional, decimal)
- Net Weight (optional, decimal)
- Volume (optional, decimal)

---

## Version History

### v1.3 - 2025-01-26
- Added physical properties (weight_unit, gross_weight, net_weight, volume_unit, volume)
- Removed parent_category column from material_categories
- Populated all material groups (50+ groups)
- Standardized material types (FG, RM, SFG, TG, SER)
- Aligned Create and Maintain forms with identical fields

### v1.2 - Previous
- Added material_group column to materials table
- Created material_groups table with category relationship
- Populated material categories (28 categories)

### v1.1 - Initial
- Created core materials schema
- Established global material master structure
- Implemented plant extension model

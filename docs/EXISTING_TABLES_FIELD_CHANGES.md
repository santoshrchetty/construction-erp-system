# EXISTING TABLES - FIELD CHANGES SUMMARY

## TABLES BEING MODIFIED: 2

---

## 1. DRAWINGS TABLE

### NEW FIELDS (12 fields added):

| Field Name | Type | Default | Nullable | Purpose |
|------------|------|---------|----------|---------|
| **parent_drawing_id** | UUID | NULL | YES | Link to parent drawing (hierarchy) |
| **drawing_level** | INT | 1 | NO | Hierarchy level (1-5) |
| **drawing_path** | VARCHAR(500) | NULL | YES | Breadcrumb path (e.g., "DWG-001/DWG-001-A") |
| **is_assembly** | BOOLEAN | false | NO | Flag for main assembly drawings |
| **drawing_category** | VARCHAR(50) | 'CONSTRUCTION' | NO | CONSTRUCTION, MAINTENANCE, AS_BUILT, OPERATIONS |
| **facility_id** | UUID | NULL | YES | Link to facilities table |
| **equipment_id** | UUID | NULL | YES | Link to equipment_register table |
| **system_tag** | VARCHAR(50) | NULL | YES | System identifier (HVAC, ELECTRICAL, etc.) |
| **location_reference** | VARCHAR(255) | NULL | YES | Physical location (Building A, Floor 2) |
| **is_released** | BOOLEAN | false | NO | Release flag for external users |
| **released_by** | UUID | NULL | YES | User who released the drawing |
| **released_at** | TIMESTAMPTZ | NULL | YES | When drawing was released |

### UPDATED CONSTRAINTS:

**OLD status constraint:**
```sql
CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'SUPERSEDED', 'OBSOLETE'))
```

**NEW status constraint:**
```sql
CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'RELEASED', 'REJECTED', 'SUPERSEDED', 'OBSOLETE'))
```
*Added: 'RELEASED' status*

**NEW constraints added:**
```sql
CHECK (drawing_level >= 1 AND drawing_level <= 5)
CHECK (drawing_category IN ('CONSTRUCTION', 'MAINTENANCE', 'AS_BUILT', 'OPERATIONS'))
```

### NEW INDEXES (7 indexes added):

```sql
idx_drawings_parent          ON drawings(parent_drawing_id)
idx_drawings_level           ON drawings(drawing_level)
idx_drawings_category        ON drawings(drawing_category)
idx_drawings_facility        ON drawings(facility_id)
idx_drawings_equipment       ON drawings(equipment_id)
idx_drawings_released        ON drawings(is_released) WHERE is_released = true
```

### FOREIGN KEY RELATIONSHIPS ADDED:

```sql
parent_drawing_id  → drawings(id)
facility_id        → facilities(facility_id)
equipment_id       → equipment_register(equipment_id)
released_by        → users(user_id)
```

---

## 2. DRAWING_REVISIONS TABLE

### NEW FIELDS (2 fields added):

| Field Name | Type | Default | Nullable | Purpose |
|------------|------|---------|----------|---------|
| **is_released** | BOOLEAN | false | NO | Flag if this revision is released |
| **released_at** | TIMESTAMPTZ | NULL | YES | When revision was released |

### NEW INDEXES (1 index added):

```sql
idx_drawing_revisions_released  ON drawing_revisions(is_released) WHERE is_released = true
```

---

## MIGRATION SQL

### For drawings table:
```sql
-- Add new fields
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS parent_drawing_id UUID REFERENCES drawings(id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS drawing_level INT DEFAULT 1;
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS drawing_path VARCHAR(500);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS is_assembly BOOLEAN DEFAULT false;
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS drawing_category VARCHAR(50) DEFAULT 'CONSTRUCTION';
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS facility_id UUID REFERENCES facilities(facility_id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS equipment_id UUID REFERENCES equipment_register(equipment_id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS system_tag VARCHAR(50);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS location_reference VARCHAR(255);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS is_released BOOLEAN DEFAULT false;
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS released_by UUID REFERENCES users(user_id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS released_at TIMESTAMP WITH TIME ZONE;

-- Update status constraint
ALTER TABLE drawings DROP CONSTRAINT IF EXISTS drawings_status_check;
ALTER TABLE drawings ADD CONSTRAINT drawings_status_check 
  CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'RELEASED', 'REJECTED', 'SUPERSEDED', 'OBSOLETE'));

-- Add new constraints
ALTER TABLE drawings ADD CONSTRAINT IF NOT EXISTS check_drawing_level 
  CHECK (drawing_level >= 1 AND drawing_level <= 5);
ALTER TABLE drawings ADD CONSTRAINT IF NOT EXISTS drawings_category_check
  CHECK (drawing_category IN ('CONSTRUCTION', 'MAINTENANCE', 'AS_BUILT', 'OPERATIONS'));

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_drawings_parent ON drawings(parent_drawing_id);
CREATE INDEX IF NOT EXISTS idx_drawings_level ON drawings(drawing_level);
CREATE INDEX IF NOT EXISTS idx_drawings_category ON drawings(drawing_category);
CREATE INDEX IF NOT EXISTS idx_drawings_facility ON drawings(facility_id);
CREATE INDEX IF NOT EXISTS idx_drawings_equipment ON drawings(equipment_id);
CREATE INDEX IF NOT EXISTS idx_drawings_released ON drawings(is_released) WHERE is_released = true;
```

### For drawing_revisions table:
```sql
-- Add new fields
ALTER TABLE drawing_revisions ADD COLUMN IF NOT EXISTS is_released BOOLEAN DEFAULT false;
ALTER TABLE drawing_revisions ADD COLUMN IF NOT EXISTS released_at TIMESTAMP WITH TIME ZONE;

-- Add index
CREATE INDEX IF NOT EXISTS idx_drawing_revisions_released ON drawing_revisions(is_released) 
  WHERE is_released = true;
```

---

## IMPACT ANALYSIS

### BACKWARD COMPATIBILITY:
✅ **All new fields are nullable or have defaults** - Existing data will not break  
✅ **Existing queries will continue to work** - No breaking changes  
✅ **New status 'RELEASED' added** - Existing statuses unchanged  

### DATA MIGRATION NEEDED:
❌ **No data migration required** - All fields have safe defaults  
✅ **Existing drawings will have:**
  - drawing_level = 1 (default)
  - drawing_category = 'CONSTRUCTION' (default)
  - is_released = false (default)
  - All other new fields = NULL

### APPLICATION CHANGES NEEDED:
⚠️ **Update drawing creation logic** to set:
  - drawing_category (if maintenance drawing)
  - facility_id (if facility-related)
  - equipment_id (if equipment-related)
  - parent_drawing_id (if child drawing)

⚠️ **Add release functionality** to set:
  - is_released = true
  - released_by = current_user
  - released_at = NOW()
  - status = 'RELEASED'

---

## SUMMARY

**Total Fields Added:** 14 (12 to drawings, 2 to drawing_revisions)  
**Total Indexes Added:** 8  
**Total Constraints Added:** 3  
**Breaking Changes:** 0  
**Data Migration Required:** No  
**Backward Compatible:** Yes  

**Safe to deploy:** ✅ Yes - All changes are additive and backward compatible

# MR Form Fields - Minimal for Site Users

## Design Principle

**Site users need SIMPLE forms. System can auto-populate the rest.**

Target: Create MR in **under 2 minutes** on mobile.

---

## Minimal Fields for Site Users

### **MR Header (5 fields only)**

```
┌─────────────────────────────────────────┐
│  CREATE MATERIAL REQUEST                │
├─────────────────────────────────────────┤
│                                         │
│  Project *                              │
│  [Dropdown: Highway Project P-001   ▼] │
│                                         │
│  Required Date *                        │
│  [Date Picker: 2024-02-15          📅] │
│                                         │
│  Priority                               │
│  [○ Normal  ● Urgent  ○ Emergency]     │
│                                         │
│  Reason                                 │
│  [Text: For foundation work...]        │
│                                         │
└─────────────────────────────────────────┘
```

**Only 5 fields:**
1. **Project** (Required) - Auto-fills plant, company code, WBS
2. **Required Date** (Required) - When materials needed
3. **Priority** (Optional) - Normal/Urgent/Emergency
4. **Reason** (Optional) - Brief justification
5. **Items** (Required) - See below

---

### **MR Line Items (3 fields only)**

```
┌─────────────────────────────────────────┐
│  MATERIALS NEEDED                       │
├─────────────────────────────────────────┤
│                                         │
│  Line 1                                 │
│  Material *                             │
│  [Search: Cement...              🔍]   │
│  → Cement OPC 43 Grade (50kg bag)      │
│                                         │
│  Quantity *                             │
│  [100]  [bags ▼]                       │
│                                         │
│  Notes                                  │
│  [For column casting...]               │
│                                         │
│  [+ Add Another Material]              │
│                                         │
└─────────────────────────────────────────┘
```

**Only 3 fields per line:**
1. **Material** (Required) - Search/select from catalog
2. **Quantity** (Required) - Number + Unit (auto-filled from material master)
3. **Notes** (Optional) - Line-specific notes

---

## Auto-Populated Fields (Hidden from User)

### **System Auto-Fills These:**

```javascript
// When user selects Project
onProjectSelect(projectCode) {
  autoFill({
    company_code: project.company_code,      // From project
    plant_code: project.plant_code,          // From project
    wbs_element: project.wbs_element,        // From project
    cost_center: project.cost_center,        // From project (if applicable)
    storage_location: project.default_storage, // From project
    requested_by: currentUser.id,            // From session
    created_by: currentUser.id,              // From session
    tenant_id: currentUser.tenant_id,        // From session
    status: 'DRAFT',                         // Default
    request_type: 'MATERIAL_REQ',            // Default
    currency_code: company.currency          // From company
  });
}

// When user selects Material
onMaterialSelect(materialCode) {
  autoFill({
    material_id: material.id,                // From material master
    description: material.description,       // From material master
    unit: material.base_uom,                 // From material master
    material_category: material.category,    // From material master
    material_group: material.group           // From material master
  });
}
```

---

## Field Comparison: User vs System

| Field | User Enters | System Auto-Fills | Source |
|-------|-------------|-------------------|--------|
| **Header Fields** |
| request_number | ❌ | ✅ | Number range |
| request_type | ❌ | ✅ | Default: MATERIAL_REQ |
| project_code | ✅ | ❌ | User selects |
| company_code | ❌ | ✅ | From project |
| plant_code | ❌ | ✅ | From project |
| wbs_element | ❌ | ✅ | From project |
| cost_center | ❌ | ✅ | From project (if applicable) |
| storage_location | ❌ | ✅ | From project default |
| required_date | ✅ | ❌ | User enters |
| priority | ✅ | ❌ | User selects (default: NORMAL) |
| justification | ✅ | ❌ | User enters (optional) |
| requested_by | ❌ | ✅ | From session |
| created_by | ❌ | ✅ | From session |
| tenant_id | ❌ | ✅ | From session |
| status | ❌ | ✅ | Default: DRAFT |
| currency_code | ❌ | ✅ | From company |
| **Line Item Fields** |
| line_number | ❌ | ✅ | Auto-increment (1, 2, 3...) |
| material_code | ✅ | ❌ | User searches/selects |
| material_id | ❌ | ✅ | From material master |
| description | ❌ | ✅ | From material master |
| quantity | ✅ | ❌ | User enters |
| unit | ❌ | ✅ | From material master |
| notes | ✅ | ❌ | User enters (optional) |
| account_assignment_category | ❌ | ✅ | From project (P=Project) |
| estimated_unit_cost | ❌ | ✅ | From material pricing |
| estimated_total_cost | ❌ | ✅ | Calculated |

---

## Mobile Form Design (Optimal)

### **Step 1: Basic Info (5 seconds)**
```
┌─────────────────────────────────┐
│ ← Material Request              │
├─────────────────────────────────┤
│                                 │
│ Project *                       │
│ Highway Project P-001       ▼  │
│                                 │
│ Need By *                       │
│ Tomorrow                    📅  │
│                                 │
│ Priority                        │
│ ● Normal  ○ Urgent             │
│                                 │
│         [Next: Add Materials]   │
└─────────────────────────────────┘
```

### **Step 2: Add Materials (30 seconds per item)**
```
┌─────────────────────────────────┐
│ ← Add Materials                 │
├─────────────────────────────────┤
│                                 │
│ Search Material                 │
│ [cement____________]        🔍  │
│                                 │
│ Results:                        │
│ ┌─────────────────────────────┐│
│ │ Cement OPC 43 (50kg bag)   ││
│ │ Cement PPC 53 (50kg bag)   ││
│ │ Cement White (25kg bag)    ││
│ └─────────────────────────────┘│
│                                 │
│ Selected: Cement OPC 43         │
│                                 │
│ Quantity *                      │
│ [100]  bags                     │
│                                 │
│ Notes (optional)                │
│ [For foundation work]           │
│                                 │
│ [+ Add Another]  [Done]         │
└─────────────────────────────────┘
```

### **Step 3: Review & Submit (10 seconds)**
```
┌─────────────────────────────────┐
│ ← Review Request                │
├─────────────────────────────────┤
│                                 │
│ Project: Highway P-001          │
│ Need By: Tomorrow               │
│ Priority: Normal                │
│                                 │
│ Materials:                      │
│ ┌─────────────────────────────┐│
│ │ 1. Cement OPC 43           ││
│ │    100 bags                ││
│ │    For foundation work     ││
│ │                            ││
│ │ 2. Steel Bars TMT 16mm     ││
│ │    5 tons                  ││
│ │    For column reinforcement││
│ └─────────────────────────────┘│
│                                 │
│ [Save as Draft]  [Submit]       │
└─────────────────────────────────┘
```

**Total Time: ~2 minutes** ✅

---

## Advanced Fields (Optional - For Power Users)

### **Show Advanced Options (Collapsed by Default)**
```
┌─────────────────────────────────┐
│ [▶ Advanced Options]            │
└─────────────────────────────────┘

When expanded:
┌─────────────────────────────────┐
│ [▼ Advanced Options]            │
├─────────────────────────────────┤
│ Storage Location                │
│ [WH-01 ▼]                       │
│                                 │
│ Cost Center (override)          │
│ [CC-SITE-01 ▼]                  │
│                                 │
│ Activity Code                   │
│ [A-100 ▼]                       │
└─────────────────────────────────┘
```

**99% of users won't need these!**

---

## Smart Defaults

### **1. Project-Based Defaults**
```javascript
// When user selects project, pre-fill everything
const projectDefaults = {
  company_code: 'C001',
  plant_code: 'PLANT-01',
  storage_location: 'WH-01',
  wbs_element: 'W-001-CIVIL',
  account_assignment_category: 'P'
};
```

### **2. User-Based Defaults**
```javascript
// Remember user's last selections
const userDefaults = {
  last_project: 'P-001',
  default_priority: 'NORMAL',
  preferred_storage: 'WH-01'
};
```

### **3. Material-Based Defaults**
```javascript
// When material selected, auto-fill
const materialDefaults = {
  unit: material.base_uom,           // bags, tons, etc.
  description: material.description,
  estimated_cost: material.standard_price
};
```

---

## Validation Rules (Minimal)

### **Required Fields Only:**
```javascript
const validation = {
  header: {
    project_code: 'required',
    required_date: 'required'
  },
  items: {
    material_code: 'required',
    quantity: 'required|min:0.001'
  }
};
```

**That's it!** Everything else is optional or auto-filled.

---

## Form Variants by User Type

### **1. Site Engineer (Mobile) - SIMPLEST**
```
Fields: 5 header + 3 per line
Time: 2 minutes
Device: Mobile app
```

### **2. Project Manager (Web) - STANDARD**
```
Fields: 8 header + 5 per line
Time: 5 minutes
Device: Desktop/tablet
Additional: Bulk upload, templates
```

### **3. Store Keeper (Web) - ADVANCED**
```
Fields: 12 header + 8 per line
Time: 10 minutes
Device: Desktop
Additional: Stock check, reorder suggestions
```

---

## Template Support (Time Saver)

### **Save as Template**
```
User creates MR for "Weekly Cement Order"
→ Save as template
→ Next time: Load template, adjust quantities, submit
→ Time: 30 seconds instead of 2 minutes
```

### **Common Templates**
- Weekly cement order
- Monthly steel order
- Daily consumables
- Safety equipment
- Office supplies

---

## Voice Input (Future Enhancement)

```
User: "I need 100 bags of cement for Highway Project, needed tomorrow"

System:
✅ Project: Highway P-001
✅ Material: Cement OPC 43
✅ Quantity: 100 bags
✅ Required Date: Tomorrow
✅ Priority: Normal

User: "Submit"
Done! ✅
```

---

## Summary: Minimal MR Form

### **User Enters (8 fields total):**

**Header (5):**
1. Project ✅
2. Required Date ✅
3. Priority ✅
4. Reason ✅
5. Items ✅

**Per Line Item (3):**
1. Material ✅
2. Quantity ✅
3. Notes ✅

### **System Auto-Fills (20+ fields):**
- All organizational data (company, plant, storage)
- All account assignments (WBS, cost center)
- All user/session data (requested_by, tenant_id)
- All material master data (description, unit, price)
- All system data (status, timestamps, document number)

---

## Implementation Recommendation

### **Phase 1: Minimal Form (MVP)**
```typescript
interface MinimalMRForm {
  // Header
  project_code: string;        // Required
  required_date: Date;         // Required
  priority: 'NORMAL' | 'URGENT' | 'EMERGENCY';
  justification?: string;
  
  // Items
  items: {
    material_code: string;     // Required
    quantity: number;          // Required
    notes?: string;
  }[];
}
```

### **Phase 2: Add Smart Features**
- Templates
- Recent materials
- Favorites
- Voice input
- Photo attachment

### **Phase 3: Advanced Options**
- Override defaults
- Bulk upload
- Copy from previous MR
- Multi-project MR

---

## Status: ✅ OPTIMAL DESIGN

**Target achieved: 2-minute MR creation on mobile with only 8 user-entered fields!**

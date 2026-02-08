# Authorization Flow: Tiles → Modules → Authorization Objects → Roles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER LOGIN                                      │
│                         (e.g., emy@prom.com)                                │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          TABLE: user_roles                                   │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │ COLUMNS:                                                        │       │
│  │   • id (uuid, PK)                                               │       │
│  │   • user_id (uuid, FK → users.id)                               │       │
│  │   • role_id (uuid, FK → roles.id)                               │       │
│  │   • tenant_id (uuid, FK → tenants.id)                           │       │
│  │   • created_at (timestamp)                                      │       │
│  │   • updated_at (timestamp)                                      │       │
│  │                                                                 │       │
│  │ EXAMPLE DATA:                                                   │       │
│  │   user_id: abc123                                               │       │
│  │   role_id: hr-role-uuid                                         │       │
│  │   tenant_id: 9bd339ec...                                        │       │
│  └─────────────────────────────────────────────────────────────────┘       │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TABLE: roles                                      │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │ COLUMNS:                                                        │       │
│  │   • id (uuid, PK)                                               │       │
│  │   • name (text)                                                 │       │
│  │   • description (text)                                          │       │
│  │   • tenant_id (uuid, FK → tenants.id)                           │       │
│  │   • is_active (boolean)                                         │       │
│  │   • created_at (timestamp)                                      │       │
│  │   • updated_at (timestamp)                                      │       │
│  │                                                                 │       │
│  │ EXAMPLE DATA:                                                   │       │
│  │   id: hr-role-uuid                                              │       │
│  │   name: "HR"                                                    │       │
│  │   tenant_id: 9bd339ec...                                        │       │
│  │   is_active: true                                               │       │
│  └─────────────────────────────────────────────────────────────────┘       │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                TABLE: role_authorization_objects                             │
│                        (MANY-TO-MANY JUNCTION)                              │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │ COLUMNS:                                                        │       │
│  │   • id (uuid, PK)                                               │       │
│  │   • role_id (uuid, FK → roles.id)                               │       │
│  │   • auth_object_id (uuid, FK → authorization_objects.id)        │       │
│  │   • tenant_id (uuid, FK → tenants.id)                           │       │
│  │   • created_at (timestamp)                                      │       │
│  │   • updated_at (timestamp)                                      │       │
│  │                                                                 │       │
│  │ EXAMPLE DATA:                                                   │       │
│  │   role_id: hr-role-uuid                                         │       │
│  │   auth_object_id: obj-1-uuid  (HR_EMPLOYEE_CREATE)             │       │
│  │   tenant_id: 9bd339ec...                                        │       │
│  │                                                                 │       │
│  │   role_id: hr-role-uuid                                         │       │
│  │   auth_object_id: obj-2-uuid  (HR_EMPLOYEE_EDIT)               │       │
│  │                                                                 │       │
│  │   role_id: hr-role-uuid                                         │       │
│  │   auth_object_id: obj-3-uuid  (MATERIALS_VIEW)                 │       │
│  └─────────────────────────────────────────────────────────────────┘       │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TABLE: authorization_objects                              │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │ COLUMNS:                                                        │       │
│  │   • id (uuid, PK)                                               │       │
│  │   • object_name (text)                                          │       │
│  │   • description (text)                                          │       │
│  │   • module (text)               ◄─── CRITICAL FIELD             │       │
│  │   • tenant_id (uuid, FK → tenants.id)                           │       │
│  │   • is_active (boolean)                                         │       │
│  │   • created_at (timestamp)                                      │       │
│  │   • updated_at (timestamp)                                      │       │
│  │                                                                 │       │
│  │ EXAMPLE DATA:                                                   │       │
│  │   id: obj-1-uuid                                                │       │
│  │   object_name: "HR_EMPLOYEE_CREATE"                             │       │
│  │   module: "hr"                  ◄─── LINKS TO MODULE           │       │
│  │   tenant_id: 9bd339ec...                                        │       │
│  │   is_active: true                                               │       │
│  │                                                                 │       │
│  │   id: obj-3-uuid                                                │       │
│  │   object_name: "MATERIALS_VIEW"                                 │       │
│  │   module: "materials"           ◄─── LINKS TO MODULE           │       │
│  │   tenant_id: 9bd339ec...                                        │       │
│  └─────────────────────────────────────────────────────────────────┘       │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    RPC FUNCTION: get_user_modules()                          │
│                         (PostgreSQL Function)                                │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │ SIGNATURE:                                                      │       │
│  │   get_user_modules(p_user_id uuid)                              │       │
│  │   RETURNS TABLE(module_code text)                               │       │
│  │                                                                 │       │
│  │ LOGIC:                                                          │       │
│  │   1. JOIN user_roles → roles → role_authorization_objects       │       │
│  │   2. JOIN authorization_objects to get module field             │       │
│  │   3. Extract DISTINCT authorization_objects.module              │       │
│  │   4. MAP module (text) → SAP code (text):                       │       │
│  │                                                                 │       │
│  │      CASE authorization_objects.module::text                    │       │
│  │        WHEN 'admin'        THEN 'AD'                            │       │
│  │        WHEN 'configuration' THEN 'CF'                           │       │
│  │        WHEN 'materials'    THEN 'MM'  ◄─── MAPS TO SAME         │       │
│  │        WHEN 'procurement'  THEN 'MM'  ◄─── CODE AS MATERIALS    │       │
│  │        WHEN 'projects'     THEN 'PS'                            │       │
│  │        WHEN 'finance'      THEN 'FI'                            │       │
│  │        WHEN 'hr'           THEN 'HR'                            │       │
│  │        WHEN 'warehouse'    THEN 'WM'                            │       │
│  │        WHEN 'quality'      THEN 'QM'                            │       │
│  │        WHEN 'safety'       THEN 'EH'                            │       │
│  │        WHEN 'documents'    THEN 'DM'                            │       │
│  │        WHEN 'reporting'    THEN 'RP'                            │       │
│  │        WHEN 'user_tasks'   THEN 'MT'                            │       │
│  │        WHEN 'emergency'    THEN 'EM'                            │       │
│  │        WHEN 'integration'  THEN 'IN'                            │       │
│  │      END                                                        │       │
│  │                                                                 │       │
│  │ OUTPUT: TABLE with module_code column                           │       │
│  │   Example: ["HR", "MM"]  ◄─── SAP MODULE CODES                 │       │
│  └─────────────────────────────────────────────────────────────────┘       │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TABLE: tiles                                      │
│                    (FILTERED BY module_code)                                │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │ COLUMNS:                                                        │       │
│  │   • id (uuid, PK)                                               │       │
│  │   • title (text)                                                │       │
│  │   • description (text)                                          │       │
│  │   • icon (text)                                                 │       │
│  │   • route (text)                                                │       │
│  │   • module_code (text)          ◄─── CRITICAL FIELD             │       │
│  │   • tile_category (text)                                        │       │
│  │   • display_order (integer)                                     │       │
│  │   • is_active (boolean)                                         │       │
│  │   • created_at (timestamp)                                      │       │
│  │   • updated_at (timestamp)                                      │       │
│  │                                                                 │       │
│  │ EXAMPLE DATA:                                                   │       │
│  │   id: tile-1-uuid                                               │       │
│  │   title: "Employee Management"                                  │       │
│  │   module_code: "HR"         ◄─── MATCHES RPC OUTPUT            │       │
│  │   tile_category: "HR"                                           │       │
│  │   route: "/hr/employees"                                        │       │
│  │   is_active: true                                               │       │
│  │                                                                 │       │
│  │   id: tile-2-uuid                                               │       │
│  │   title: "Material Master"                                      │       │
│  │   module_code: "MM"         ◄─── MATCHES RPC OUTPUT            │       │
│  │   tile_category: "Materials"                                    │       │
│  │   route: "/materials/master"                                    │       │
│  │                                                                 │       │
│  │   id: tile-3-uuid                                               │       │
│  │   title: "Purchase Orders"                                      │       │
│  │   module_code: "MM"         ◄─── SAME CODE = ALSO VISIBLE!     │       │
│  │   tile_category: "Procurement"                                  │       │
│  │   route: "/procurement/po"                                      │       │
│  └─────────────────────────────────────────────────────────────────┘       │
│                                                                              │
│  FILTER LOGIC: SELECT * FROM tiles                                          │
│                WHERE module_code IN (                                       │
│                  SELECT module_code FROM get_user_modules(user_id)          │
│                )                                                            │
│                                                                              │
│  USER SEES: All tiles where module_code IN ["HR", "MM"]                    │
│  RESULT: HR tiles + Materials tiles + Procurement tiles                    │
└─────────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
                              KEY RELATIONSHIPS
═══════════════════════════════════════════════════════════════════════════════

1. USER → ROLES (many-to-many via user_roles)
   └─ One user can have multiple roles

2. ROLES → AUTHORIZATION OBJECTS (many-to-many via role_authorization_objects)
   └─ One role can have many auth objects
   └─ One auth object can belong to many roles

3. AUTHORIZATION OBJECTS → MODULE (one-to-one via module field)
   └─ Each auth object belongs to exactly ONE module
   └─ Module is a TEXT field in authorization_objects.module
   └─ Values: "hr", "materials", "projects", "finance", etc.

4. MODULE → SAP CODE (mapped in get_user_modules() RPC)
   └─ Multiple modules can map to same SAP code
   └─ Mapping done via CASE statement in RPC function
   └─ Example: "materials" + "procurement" → "MM"

5. SAP CODE → TILES (filtered by module_code field)
   └─ Tiles filtered: WHERE tiles.module_code IN (get_user_modules())
   └─ NO direct link between tiles and authorization objects
   └─ Link is INDIRECT through module mapping
   └─ NO foreign key relationship between tables


═══════════════════════════════════════════════════════════════════════════════
                           CURRENT HR ROLE ISSUE
═══════════════════════════════════════════════════════════════════════════════

HR Role has authorization objects with modules:
  ├─ "hr" (5 objects)
  └─ "materials" (5 objects)

get_user_modules() returns:
  ├─ "HR"  (from "hr" module)
  └─ "MM"  (from "materials" module)

Tiles visible to HR user:
  ├─ All tiles with module_code = "HR" (HR category)
  ├─ All tiles with module_code = "MM" and tile_category = "Materials"
  └─ All tiles with module_code = "MM" and tile_category = "Procurement"  ◄─ UNWANTED

SOLUTION: Remove "materials" module assignments from HR role
  → HR role will only have "hr" module
  → get_user_modules() will only return ["HR"]
  → User will only see HR tiles


═══════════════════════════════════════════════════════════════════════════════
                              DATA FLOW SUMMARY
═══════════════════════════════════════════════════════════════════════════════

┌──────────┐     ┌──────────┐     ┌─────────────────┐     ┌──────────────┐
│  USER    │────▶│  ROLES   │────▶│  AUTH OBJECTS   │────▶│   MODULES    │
└──────────┘     └──────────┘     │  (with module)  │     │ (text field) │
                                   └─────────────────┘     └──────┬───────┘
                                                                   │
                                                                   ▼
                                                          ┌─────────────────┐
                                                          │  RPC FUNCTION   │
                                                          │  (maps module   │
                                                          │   to SAP code)  │
                                                          └────────┬────────┘
                                                                   │
                                                                   ▼
                                                          ┌─────────────────┐
                                                          │   SAP CODES     │
                                                          │  ["HR", "MM"]   │
                                                          └────────┬────────┘
                                                                   │
                                                                   ▼
                                                          ┌─────────────────┐
                                                          │     TILES       │
                                                          │ (filtered by    │
                                                          │  module_code)   │
                                                          └─────────────────┘

NO DIRECT LINK: Tiles ↔ Authorization Objects
INDIRECT LINK: Tiles → module_code → SAP code ← module ← Authorization Objects
```

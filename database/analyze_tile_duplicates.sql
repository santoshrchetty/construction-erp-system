-- Comprehensive Tile Duplication Analysis
-- Identify tiles with overlapping or duplicate functionality

-- 1. Group tiles by similar functionality patterns
SELECT 'POTENTIAL DUPLICATES - Similar Titles/Functions:' as analysis_type;

-- Finance duplicates
SELECT 'Finance Duplicates:' as category;
SELECT title, construction_action, auth_object, 
       CASE 
         WHEN title LIKE '%Report%' OR construction_action LIKE '%report%' THEN 'REPORTING'
         WHEN title LIKE '%Account%' OR construction_action LIKE '%account%' THEN 'ACCOUNTING'
         WHEN title LIKE '%Cost%' OR construction_action LIKE '%cost%' THEN 'COSTING'
         ELSE 'OTHER'
       END as function_group
FROM tiles 
WHERE tile_category = 'Finance'
ORDER BY function_group, title;

-- Materials duplicates  
SELECT 'Materials Duplicates:' as category;
SELECT title, construction_action, auth_object,
       CASE 
         WHEN title LIKE '%Material Master%' OR construction_action LIKE '%material%' THEN 'MATERIAL_MASTER'
         WHEN title LIKE '%Stock%' OR title LIKE '%Inventory%' THEN 'STOCK_MGMT'
         WHEN title LIKE '%Report%' OR construction_action LIKE '%report%' THEN 'REPORTING'
         WHEN title LIKE '%Material%' AND (title LIKE '%Search%' OR title LIKE '%Display%') THEN 'MATERIAL_LOOKUP'
         ELSE 'OTHER'
       END as function_group
FROM tiles 
WHERE tile_category = 'Materials'
ORDER BY function_group, title;

-- Inventory/Warehouse duplicates
SELECT 'Inventory/Warehouse Duplicates:' as category;
SELECT title, construction_action, auth_object, tile_category,
       CASE 
         WHEN title LIKE '%Goods%' THEN 'GOODS_MOVEMENT'
         WHEN title LIKE '%Inventory%' OR title LIKE '%Stock%' THEN 'INVENTORY_MGMT'
         WHEN title LIKE '%Warehouse%' THEN 'WAREHOUSE_MGMT'
         WHEN title LIKE '%Report%' OR construction_action LIKE '%report%' THEN 'REPORTING'
         ELSE 'OTHER'
       END as function_group
FROM tiles 
WHERE tile_category IN ('Inventory', 'Warehouse')
ORDER BY function_group, title;

-- Project Management duplicates
SELECT 'Project Management Duplicates:' as category;
SELECT title, construction_action, auth_object,
       CASE 
         WHEN title LIKE '%Project%' AND title LIKE '%Cost%' THEN 'PROJECT_COSTING'
         WHEN title LIKE '%Report%' OR construction_action LIKE '%report%' THEN 'REPORTING'
         WHEN title LIKE '%Project%' AND (title LIKE '%Create%' OR title LIKE '%Dashboard%') THEN 'PROJECT_MGMT'
         ELSE 'OTHER'
       END as function_group
FROM tiles 
WHERE tile_category = 'Project Management'
ORDER BY function_group, title;

-- HR duplicates
SELECT 'HR Duplicates:' as category;
SELECT title, construction_action, auth_object,
       CASE 
         WHEN title LIKE '%Employee%' THEN 'EMPLOYEE_MGMT'
         WHEN title LIKE '%Timesheet%' THEN 'TIME_MGMT'
         WHEN title LIKE '%Report%' OR construction_action LIKE '%report%' THEN 'REPORTING'
         ELSE 'OTHER'
       END as function_group
FROM tiles 
WHERE tile_category = 'Human Resources'
ORDER BY function_group, title;

-- 2. Cross-category functionality overlaps
SELECT 'CROSS-CATEGORY OVERLAPS:' as analysis_type;

-- Cost management overlaps (Finance vs Project Management)
SELECT 'Cost Management Overlaps:' as overlap_type;
SELECT title, tile_category, construction_action, auth_object
FROM tiles 
WHERE (title LIKE '%Cost%' OR construction_action LIKE '%cost%')
ORDER BY tile_category, title;

-- Reporting overlaps (multiple categories)
SELECT 'Reporting Overlaps:' as overlap_type;
SELECT title, tile_category, construction_action, auth_object
FROM tiles 
WHERE (title LIKE '%Report%' OR construction_action LIKE '%report%')
ORDER BY tile_category, title;

-- User/Employee management overlaps
SELECT 'User/Employee Management Overlaps:' as overlap_type;
SELECT title, tile_category, construction_action, auth_object
FROM tiles 
WHERE (title LIKE '%User%' OR title LIKE '%Employee%' OR construction_action LIKE '%user%' OR construction_action LIKE '%employee%')
ORDER BY tile_category, title;

-- 3. Specific duplicate candidates
SELECT 'SPECIFIC DUPLICATE CANDIDATES:' as analysis_type;

-- Material stock vs inventory overlaps
SELECT 'Material Stock vs Inventory Stock:' as duplicate_type;
SELECT title, tile_category, construction_action, subtitle
FROM tiles 
WHERE (title LIKE '%Stock%' OR title LIKE '%Inventory%') 
  AND tile_category IN ('Materials', 'Inventory')
ORDER BY tile_category, title;

-- Configuration overlaps
SELECT 'Configuration Overlaps:' as duplicate_type;
SELECT title, tile_category, construction_action, auth_object
FROM tiles 
WHERE (title LIKE '%Config%' OR construction_action LIKE '%config%')
ORDER BY tile_category, title;
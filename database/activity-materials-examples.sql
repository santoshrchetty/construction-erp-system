-- =====================================================
-- ACTIVITY MATERIALS - USAGE EXAMPLES
-- =====================================================

-- EXAMPLE 1: Create activity with materials
-- Step 1: Create activity
INSERT INTO activities (
    project_id, wbs_node_id, code, name,
    planned_start_date, planned_end_date, duration_days
) VALUES (
    'your-project-id', 'your-wbs-id', 'ACT-001', 'Foundation Work',
    '2024-03-01', '2024-03-10', 10
) RETURNING id;

-- Step 2: Attach materials (date auto-inherits from activity)
INSERT INTO activity_materials (activity_id, material_id, required_quantity, unit, unit_cost)
VALUES 
    ('activity-uuid', 'cement-material-id', 100, 'BAG', 450),
    ('activity-uuid', 'steel-material-id', 500, 'KG', 75);
-- planned_consumption_date automatically becomes '2024-03-01'


-- EXAMPLE 2: View activity with materials and dates
SELECT 
    a.code AS activity_code,
    a.name AS activity_name,
    a.planned_start_date,
    m.material_code,
    m.material_name,
    am.required_quantity,
    am.unit,
    am.planned_consumption_date,  -- Inherited from activity
    am.total_cost,
    am.status
FROM activities a
JOIN activity_materials am ON a.id = am.activity_id
JOIN materials m ON am.material_id = m.id
WHERE a.code = 'ACT-001';


-- EXAMPLE 3: When activity date changes, update material dates
UPDATE activity_materials 
SET planned_consumption_date = (
    SELECT planned_start_date 
    FROM activities 
    WHERE id = activity_materials.activity_id
)
WHERE activity_id = 'activity-uuid';


-- EXAMPLE 4: Reserve materials when activity is confirmed
UPDATE activity_materials
SET status = 'reserved',
    reserved_quantity = required_quantity
WHERE activity_id = 'activity-uuid' 
  AND status = 'planned';


-- EXAMPLE 5: Issue materials when activity starts
UPDATE activity_materials
SET status = 'issued',
    actual_consumption_date = CURRENT_DATE
WHERE activity_id = 'activity-uuid' 
  AND status = 'reserved';


-- EXAMPLE 6: Material requirements by date (for procurement planning)
SELECT 
    am.planned_consumption_date,
    m.material_code,
    m.material_name,
    SUM(am.required_quantity) AS total_required,
    am.unit,
    SUM(am.total_cost) AS total_cost
FROM activity_materials am
JOIN materials m ON am.material_id = m.id
WHERE am.planned_consumption_date BETWEEN '2024-03-01' AND '2024-03-31'
  AND am.status IN ('planned', 'reserved')
GROUP BY am.planned_consumption_date, m.material_code, m.material_name, am.unit
ORDER BY am.planned_consumption_date, m.material_code;


-- EXAMPLE 7: Activities with material shortages
SELECT 
    a.code,
    a.name,
    a.planned_start_date,
    m.material_code,
    am.required_quantity,
    COALESCE(sl.available_stock, 0) AS available_stock,
    (am.required_quantity - COALESCE(sl.available_stock, 0)) AS shortage
FROM activities a
JOIN activity_materials am ON a.id = am.activity_id
JOIN materials m ON am.material_id = m.id
LEFT JOIN stock_levels sl ON m.id = sl.material_id
WHERE am.status = 'planned'
  AND COALESCE(sl.available_stock, 0) < am.required_quantity
ORDER BY a.planned_start_date;

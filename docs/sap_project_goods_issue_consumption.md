# SAP Goods Issue to Project - Consumption Logic

## ✅ SAP Standard Behavior: Issue to Project = Consumption

### **Key Principle:**
When materials are issued to a **project (WBS Element)**, SAP treats this as **consumption** from inventory, not a transfer.

## 📋 SAP Movement Types for Project Issues

### **Movement Type 201 - Goods Issue to Project**
```
Transaction: MIGO (Goods Issue)
Movement Type: 201
Account Assignment: Project/WBS Element

Inventory Impact:
- Stock Quantity: DECREASES (consumed)
- Stock Value: DECREASES (removed from inventory)

Financial Impact:
- Dr. Project Costs (WBS Element)
- Cr. Inventory Account
```

### **Example Transaction:**
```
Material: Cement (100 tons @ £50/ton)
Movement Type: 201
WBS Element: PRJ001.100 (Foundation Work)

Accounting Entries:
Dr. WBS Element PRJ001.100    £5,000
Cr. Raw Materials Inventory   £5,000

Result: 
- Inventory reduced by 100 tons
- Project charged £5,000
- Material considered "consumed"
```

## 🏗️ Construction Project Scenarios

### **Scenario 1: Direct Project Consumption (Standard)**
```
Use Case: Cement delivered directly to construction site
Movement: Warehouse → Project (WBS Element)
Movement Type: 201 (Goods Issue to Project)

Process:
1. Material Request created for project
2. Goods issued from warehouse to WBS element
3. Inventory decreases immediately
4. Project costs increase immediately
5. Material considered consumed
```

### **Scenario 2: Site Storage Then Consumption**
```
Use Case: Materials stored at site before use
Movement 1: Warehouse → Site Storage Location
Movement Type: 311 (Transfer between storage locations)

Movement 2: Site Storage → Project (WBS Element)  
Movement Type: 201 (Goods Issue to Project)

Process:
1. Transfer to site storage (inventory remains)
2. Later issue to project when actually used
3. Only step 2 reduces inventory and charges project
```

## 📊 Inventory vs Project Accounting

### **Inventory Perspective:**
```
Before Issue: 1000 tons cement in stock
After Issue to Project: 900 tons cement in stock
Status: 100 tons CONSUMED (no longer inventory)
```

### **Project Perspective:**
```
Project Costs Before: £45,000
Project Costs After: £50,000 (£45,000 + £5,000 cement)
Status: Material cost CAPITALIZED to project
```

### **Financial Accounting:**
```
Balance Sheet Impact:
- Inventory (Asset): DECREASES by £5,000
- Work in Progress (Asset): INCREASES by £5,000

P&L Impact: None (asset to asset transfer)
```

## 🔄 Alternative Approaches

### **Option 1: Direct Issue to Project (Recommended)**
```
Pros:
✅ Immediate cost allocation to project
✅ Real-time project cost tracking
✅ Accurate inventory levels
✅ Simple process

Cons:
❌ Cannot track unused materials at site
❌ No site-level inventory control
```

### **Option 2: Two-Step Process (Site Storage + Project Issue)**
```
Step 1: Transfer to Site Storage Location
- Maintains inventory status
- Allows site-level control
- Enables return to warehouse if unused

Step 2: Issue to Project When Actually Used
- Reduces inventory
- Charges project costs
- Reflects actual consumption

Pros:
✅ Better site inventory control
✅ Can return unused materials
✅ Accurate consumption tracking

Cons:
❌ More complex process
❌ Additional transactions required
```

## 🎯 Construction Industry Best Practice

### **Recommended Approach:**
```
For Construction Projects:
1. Use Movement Type 201 for direct project consumption
2. Issue materials when actually used in construction
3. Maintain site storage for temporary holding
4. Use reservations to guarantee material availability
```

### **Process Flow:**
```
1. MRP generates Material Request for project
2. Create Reservation against project (WBS Element)
3. Transfer materials to site storage location (if needed)
4. Issue materials to project when consumed in construction
5. Project costs updated in real-time
```

## 💾 Database Implementation

### **Material Consumption Tracking:**
```sql
-- Track material consumption by project
CREATE TABLE material_consumption (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_code VARCHAR(50) NOT NULL,
    project_code VARCHAR(50) NOT NULL,
    wbs_element VARCHAR(50),
    activity_code VARCHAR(50),
    consumption_date DATE NOT NULL,
    quantity_consumed DECIMAL(15,3) NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL,
    movement_type VARCHAR(10) DEFAULT '201',
    document_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Update inventory on consumption
CREATE OR REPLACE FUNCTION consume_material_to_project(
    p_material_code VARCHAR(50),
    p_plant_code VARCHAR(10),
    p_storage_location VARCHAR(10),
    p_quantity DECIMAL(15,3),
    p_project_code VARCHAR(50),
    p_wbs_element VARCHAR(50)
) RETURNS VOID AS $$
DECLARE
    v_unit_cost DECIMAL(15,2);
    v_total_cost DECIMAL(15,2);
BEGIN
    -- Get current unit cost
    SELECT unit_cost INTO v_unit_cost
    FROM inventory_stock
    WHERE material_code = p_material_code
    AND plant_code = p_plant_code
    AND storage_location = p_storage_location;
    
    v_total_cost := p_quantity * v_unit_cost;
    
    -- Reduce inventory
    UPDATE inventory_stock
    SET quantity_on_hand = quantity_on_hand - p_quantity,
        last_movement_date = CURRENT_DATE
    WHERE material_code = p_material_code
    AND plant_code = p_plant_code
    AND storage_location = p_storage_location;
    
    -- Record consumption
    INSERT INTO material_consumption (
        material_code, project_code, wbs_element,
        consumption_date, quantity_consumed, unit_cost, total_cost
    ) VALUES (
        p_material_code, p_project_code, p_wbs_element,
        CURRENT_DATE, p_quantity, v_unit_cost, v_total_cost
    );
    
    -- Update project costs
    UPDATE projects
    SET actual_cost = actual_cost + v_total_cost
    WHERE code = p_project_code;
END;
$$ LANGUAGE plpgsql;
```

## 📈 Project Cost Tracking

### **Real-Time Project Costs:**
```sql
-- View project material consumption
CREATE VIEW project_material_costs AS
SELECT 
    project_code,
    wbs_element,
    material_code,
    SUM(quantity_consumed) as total_quantity,
    SUM(total_cost) as total_cost,
    AVG(unit_cost) as average_cost
FROM material_consumption
GROUP BY project_code, wbs_element, material_code;
```

## 🔑 Key Takeaways

✅ **SAP Standard:** Issue to project = Consumption (inventory reduced)
✅ **Movement Type 201:** Standard for project goods issue
✅ **Immediate Impact:** Inventory decreases, project costs increase
✅ **Asset Transfer:** From inventory asset to WIP asset
✅ **Real-Time Costing:** Project costs updated immediately

This approach ensures **accurate project costing** and **proper inventory management** while following **SAP standard practices** for construction project accounting.
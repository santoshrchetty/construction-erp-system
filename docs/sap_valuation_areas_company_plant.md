# SAP Valuation Areas - Company Code vs Plant Level

## ✅ SAP Valuation Area Configuration

### **Two Valuation Area Options:**

### 1. **Company Code Level Valuation (Standard)**
```
Configuration: Valuation Area = Company Code
- All plants within company code share same material prices
- Centralized price management
- Simplified inter-plant transfers
- Most common configuration
```

### 2. **Plant Level Valuation (Advanced)**
```
Configuration: Valuation Area = Plant
- Each plant maintains separate material prices
- Decentralized price management
- Complex inter-plant transfer pricing
- Used for specific business requirements
```

## SAP Configuration Tables

### **Valuation Area Definition (OMWB):**
```
Company Code: 1000 (ODL_UK)
Valuation Level: 1 (Company Code) or 2 (Plant)

If Valuation Level = 1:
- Valuation Area = Company Code (1000)
- All plants (1000, 2000, 3000) use same prices

If Valuation Level = 2:
- Valuation Area = Plant Code
- Plant 1000, Plant 2000, Plant 3000 each have separate prices
```

### **Material Valuation (MBEW Table):**
```
Company Code Level Valuation:
MANDT | MATNR  | BWKEY | BWTAR | VPRSV | VERPR | STPRS
100   | MAT001 | 1000  |       | V     | 51.50 | 50.00

Plant Level Valuation:
MANDT | MATNR  | BWKEY | BWTAR | VPRSV | VERPR | STPRS
100   | MAT001 | 1000  |       | V     | 52.00 | 50.00  (Plant 1000)
100   | MAT001 | 2000  |       | V     | 51.00 | 50.00  (Plant 2000)
100   | MAT001 | 3000  |       | V     | 50.50 | 50.00  (Plant 3000)
```

## Construction Industry Use Cases

### **Company Code Level Valuation:**
**When to Use:**
- Single procurement organization
- Centralized purchasing
- Consistent pricing across sites
- Simplified accounting

**Example:**
```
ODL_UK Company Code:
- Plant 1000 (Main Warehouse): Cement £51.50/ton
- Plant 2000 (Site A): Cement £51.50/ton
- Plant 3000 (Site B): Cement £51.50/ton
- Plant 4000 (Office): Cement £51.50/ton

Same price across all plants
```

### **Plant Level Valuation:**
**When to Use:**
- Multiple procurement sources
- Different suppliers per location
- Local sourcing requirements
- Transfer pricing needs

**Example:**
```
ODL_UK Company Code with Plant Level Valuation:
- Plant 1000 (Main Warehouse): Cement £52.00/ton (Bulk supplier)
- Plant 2000 (Site A): Cement £51.00/ton (Local supplier)
- Plant 3000 (Site B): Cement £50.50/ton (Regional supplier)
- Plant 4000 (Office): Cement £53.00/ton (Small quantity premium)

Different prices per plant based on local conditions
```

## Database Schema Implementation

### **Valuation Area Configuration:**
```sql
-- Company configuration
ALTER TABLE company_codes 
ADD COLUMN valuation_level INTEGER DEFAULT 1 
    CHECK (valuation_level IN (1, 2)),
ADD COLUMN valuation_area_type VARCHAR(20) DEFAULT 'COMPANY_CODE'
    CHECK (valuation_area_type IN ('COMPANY_CODE', 'PLANT'));

-- Material valuation per valuation area
CREATE TABLE material_valuations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_code VARCHAR(50) NOT NULL,
    valuation_area VARCHAR(10) NOT NULL, -- Company Code or Plant Code
    valuation_type VARCHAR(10) NOT NULL, -- '' for standard, or valuation type
    price_control VARCHAR(1) NOT NULL CHECK (price_control IN ('S', 'V')),
    standard_price DECIMAL(15,2),
    moving_average_price DECIMAL(15,2),
    price_unit INTEGER DEFAULT 1,
    currency VARCHAR(3) DEFAULT 'GBP',
    valuation_class VARCHAR(10),
    last_price_change_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_code, valuation_area, valuation_type)
);
```

### **Valuation Logic Function:**
```sql
CREATE OR REPLACE FUNCTION get_material_price(
    p_material_code VARCHAR(50),
    p_plant_code VARCHAR(10),
    p_company_code VARCHAR(10)
) RETURNS DECIMAL(15,2) AS $$
DECLARE
    v_valuation_level INTEGER;
    v_valuation_area VARCHAR(10);
    v_price DECIMAL(15,2);
BEGIN
    -- Get valuation level for company
    SELECT valuation_level INTO v_valuation_level
    FROM company_codes 
    WHERE company_code = p_company_code;
    
    -- Determine valuation area
    IF v_valuation_level = 1 THEN
        v_valuation_area := p_company_code; -- Company Code level
    ELSE
        v_valuation_area := p_plant_code;   -- Plant level
    END IF;
    
    -- Get price from valuation area
    SELECT COALESCE(moving_average_price, standard_price) INTO v_price
    FROM material_valuations
    WHERE material_code = p_material_code 
    AND valuation_area = v_valuation_area;
    
    RETURN v_price;
END;
$$ LANGUAGE plpgsql;
```

## Inter-Plant Transfer Pricing

### **Company Code Level Valuation:**
```sql
-- Simple transfer - same price
Transfer from Plant 1000 to Plant 2000:
- Issue from Plant 1000: £51.50/ton
- Receipt at Plant 2000: £51.50/ton
- No price difference
```

### **Plant Level Valuation:**
```sql
-- Complex transfer - different prices
Transfer from Plant 1000 to Plant 2000:
- Issue from Plant 1000: £52.00/ton (Plant 1000 price)
- Receipt at Plant 2000: £51.00/ton (Plant 2000 price)
- Price difference: £1.00/ton (posted to price difference account)
```

## Material Request Implementation

### **Price Determination:**
```sql
-- Get price based on valuation area configuration
SELECT get_material_price('MAT001', 'PLANT_2000', 'ODL_UK') as material_price;

-- Returns:
-- Company Code Level: Same price for all plants
-- Plant Level: Plant-specific price
```

### **MR Line Item Valuation:**
```sql
UPDATE material_request_items 
SET standard_price = get_material_price(material_code, plant_code, company_code),
    total_line_value = quantity * get_material_price(material_code, plant_code, company_code)
WHERE material_request_id = 'MR_ID';
```

## Benefits Comparison

### **Company Code Level:**
✅ **Simplicity** - Single price per material
✅ **Easy transfers** - No price differences
✅ **Centralized control** - One price to manage
✅ **Consistent reporting** - Same costs across plants

### **Plant Level:**
✅ **Local flexibility** - Plant-specific pricing
✅ **Accurate costing** - Reflects local conditions
✅ **Transfer pricing** - Proper inter-plant accounting
✅ **Procurement optimization** - Local sourcing benefits

## Recommendation for Construction ERP

**Start with Company Code Level** for simplicity, then **upgrade to Plant Level** if business requires:
- Multiple procurement sources
- Significant price differences between locations
- Transfer pricing requirements
- Local sourcing strategies

This provides **SAP-compliant valuation** with flexibility to match business requirements.
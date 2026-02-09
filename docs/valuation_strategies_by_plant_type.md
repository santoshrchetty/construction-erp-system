# Material Valuation Strategies by Plant Type

## Plant Types & Valuation Methods

### 1. **WAREHOUSE (Central Distribution)**
**Characteristics:**
- High-volume storage
- Multiple material types
- Frequent receipts and issues
- Cost optimization focus

**Recommended Valuation Method:** **Moving Average Price (MAP)**
```
Rationale:
- Smooths price fluctuations from multiple suppliers
- Reflects current market conditions
- Automatic price updates with each receipt
- Suitable for high-turnover materials
```

**Example:**
```
Current Stock: 1000 tons cement @ £50/ton = £50,000
New Receipt: 500 tons cement @ £55/ton = £27,500
New MAP: (£50,000 + £27,500) ÷ 1500 tons = £51.67/ton
```

### 2. **SITE (Project Locations)**
**Characteristics:**
- Project-specific materials
- Limited storage capacity
- Direct consumption
- Project cost accuracy critical

**Recommended Valuation Method:** **FIFO (First In, First Out)**
```
Rationale:
- Matches physical flow (older materials used first)
- Prevents material deterioration costs
- Accurate project costing
- Better inventory turnover tracking
```

**Example:**
```
Batch 1: 100 tons @ £50/ton (Week 1)
Batch 2: 150 tons @ £55/ton (Week 2)
Issue 120 tons: 100 tons @ £50 + 20 tons @ £55 = £6,100
Remaining: 130 tons @ £55/ton
```

### 3. **YARD (Material Staging)**
**Characteristics:**
- Temporary storage
- Weather exposure risk
- Bulk materials
- Transfer hub function

**Recommended Valuation Method:** **Standard Price + Variance**
```
Rationale:
- Predictable costing for planning
- Variance tracking for cost control
- Simplified transfer pricing
- Weather/damage loss tracking
```

**Example:**
```
Standard Price: £50/ton cement
Actual Receipt: £52/ton
Material Value: £50/ton (standard)
Price Variance: £2/ton (tracked separately)
```

### 4. **OFFICE (Administrative Supplies)**
**Characteristics:**
- Low-value consumables
- Infrequent usage
- Administrative overhead
- Simple tracking needs

**Recommended Valuation Method:** **Standard Price**
```
Rationale:
- Simplified administration
- Predictable budgeting
- Minimal impact on project costs
- Annual price reviews sufficient
```

**Example:**
```
Office Supplies Standard Prices:
- A4 Paper: £5.00/ream
- Pens: £0.50/piece
- Folders: £2.00/piece
Updated annually or when significant variance occurs
```

### 5. **VEHICLE (Mobile Storage)**
**Characteristics:**
- Tools and equipment
- High-value items
- Security concerns
- Individual tracking

**Recommended Valuation Method:** **Specific Identification**
```
Rationale:
- Individual item tracking
- Serial number management
- Accurate depreciation
- Theft/loss control
```

**Example:**
```
Tool Inventory:
- Drill #001: £250 (Purchase Date: 01/01/2024)
- Saw #002: £180 (Purchase Date: 15/01/2024)
- Generator #003: £1,200 (Purchase Date: 20/01/2024)
Each item tracked individually with serial numbers
```

## Valuation Method Comparison

| Plant Type | Primary Method | Secondary Method | Rationale |
|------------|---------------|------------------|-----------|
| **WAREHOUSE** | Moving Average | Standard Price | High turnover, price stability |
| **SITE** | FIFO | Moving Average | Physical flow matching |
| **YARD** | Standard Price | Moving Average | Predictable costing |
| **OFFICE** | Standard Price | - | Simplicity, low impact |
| **VEHICLE** | Specific ID | Standard Price | Individual tracking |

## Implementation Considerations

### 1. **Material Type Influence**
```
Raw Materials (Cement, Steel):
- WAREHOUSE: Moving Average
- SITE: FIFO
- YARD: Standard Price

Consumables (Fuel, Lubricants):
- All Plants: Moving Average

Tools & Equipment:
- All Plants: Specific Identification

Office Supplies:
- All Plants: Standard Price
```

### 2. **Transfer Pricing Between Plants**
```
WAREHOUSE → SITE:
- Transfer at Moving Average Price
- Add transport costs at SITE

WAREHOUSE → YARD:
- Transfer at Moving Average Price
- No additional costs

YARD → SITE:
- Transfer at Standard Price
- Add handling costs at SITE
```

### 3. **Cost Flow Example**
```
Material Journey: Cement
1. WAREHOUSE Receipt: £52/ton (actual)
   Valuation: Moving Average = £51.50/ton

2. Transfer to YARD: £51.50/ton
   Valuation: Standard Price = £50/ton
   Variance: £1.50/ton (tracked)

3. Transfer to SITE: £50/ton + £3/ton transport
   Valuation: FIFO = £53/ton (landed cost)

4. Project Consumption: £53/ton
   Charged to project at actual landed cost
```

## System Configuration

### Database Schema Enhancement:
```sql
ALTER TABLE plants ADD COLUMN 
    default_valuation_method VARCHAR(20) DEFAULT 'MOVING_AVERAGE'
    CHECK (default_valuation_method IN (
        'MOVING_AVERAGE', 
        'FIFO', 
        'LIFO', 
        'STANDARD_PRICE', 
        'SPECIFIC_ID'
    ));

ALTER TABLE materials ADD COLUMN
    valuation_method_override VARCHAR(20),
    allow_plant_override BOOLEAN DEFAULT false;
```

### Valuation Rules Engine:
```sql
CREATE TABLE valuation_rules (
    id UUID PRIMARY KEY,
    plant_type VARCHAR(20),
    material_type VARCHAR(20),
    valuation_method VARCHAR(20),
    priority INTEGER,
    is_active BOOLEAN DEFAULT true
);

-- Example rules
INSERT INTO valuation_rules VALUES
('rule1', 'WAREHOUSE', 'RAW_MATERIAL', 'MOVING_AVERAGE', 1, true),
('rule2', 'SITE', 'RAW_MATERIAL', 'FIFO', 1, true),
('rule3', 'OFFICE', 'CONSUMABLE', 'STANDARD_PRICE', 1, true),
('rule4', 'VEHICLE', 'TOOLS', 'SPECIFIC_ID', 1, true);
```

## Benefits by Plant Type

### WAREHOUSE (Moving Average):
✅ Accurate current costs
✅ Automatic price updates
✅ Smooth price fluctuations
✅ Suitable for high volume

### SITE (FIFO):
✅ Matches physical flow
✅ Accurate project costing
✅ Prevents obsolescence
✅ Better inventory control

### YARD (Standard Price):
✅ Predictable costs
✅ Simplified transfers
✅ Variance tracking
✅ Budget control

### OFFICE (Standard Price):
✅ Administrative simplicity
✅ Predictable budgets
✅ Low maintenance
✅ Cost effective

### VEHICLE (Specific ID):
✅ Individual tracking
✅ Security control
✅ Accurate depreciation
✅ Loss prevention

This valuation strategy ensures optimal cost management across different plant types while maintaining accuracy and operational efficiency.
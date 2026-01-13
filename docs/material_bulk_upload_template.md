# Material Master Bulk Upload Template

## Excel/CSV Column Structure (aligned with materials table)

| Column | Field Name | Data Type | Required | Example |
|--------|------------|-----------|----------|---------|
| A | item_code | VARCHAR(50) | Yes | CEMENT-OPC-53 |
| B | description | TEXT | Yes | OPC 53 Grade Cement |
| C | category | VARCHAR(50) | No | CEMENT |
| D | unit | VARCHAR(10) | Yes | BAG |
| E | plant_code | VARCHAR(20) | No | P001 |
| F | plant_name | VARCHAR(100) | No | Main Plant |
| G | reorder_level | NUMERIC | No | 100 |
| H | safety_stock | NUMERIC | No | 50 |
| I | standard_price | NUMERIC | No | 500.00 |
| J | currency | VARCHAR(3) | No | INR |
| K | sloc_code | VARCHAR(20) | No | S001 |
| L | sloc_name | VARCHAR(100) | No | Main Store |
| M | current_stock | NUMERIC | No | 0 |
| N | company_code | VARCHAR(10) | No | C001 |
| O | company_name | VARCHAR(100) | No | ABC Construction |

## Sample Data Row:
```
STEEL-TMT-12MM | TMT Steel Bars 12mm | STEEL | TON | P001 | Main Plant | 5 | 2 | 65000.00 | INR | S001 | Main Store | 0 | C001 | ABC Construction
```

## Validation Rules:
- item_code: Must be unique
- unit: Standard units (BAG, TON, KG, M, SQM, etc.)
- currency: ISO codes (INR, USD, EUR)
- All numeric fields: Positive values only
- is_active: Defaults to TRUE

## Upload Process:
1. Download template from Bulk Upload Materials tile
2. Fill data following the format above
3. Upload Excel/CSV file
4. System validates and shows preview
5. Confirm to insert into materials table

The bulk upload tile is perfectly aligned with your current materials table structure.
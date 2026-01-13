# Account Determination Business Logic - Construction ERP

## Overview
Account Determination automatically maps material transactions to the correct GL accounts based on:
- **Company Code**: Legal entity (C001, C002)
- **Valuation Class**: Material category (MAT001=Raw Materials, MAT002=Finished Goods)  
- **Account Key**: Transaction type (BSX, GBB, PRD, etc.)

## Business Flow

### 1. Material Receipt (Goods Receipt)
```
Material Received → BSX Account Key → Stock Account (140000/150000)
```
- Raw Materials (MAT001) → 140000 (Raw Materials Inventory)
- Finished Goods (MAT002) → 150000 (Finished Goods Inventory)

### 2. Material Consumption (Goods Issue)
```
Material Issued → GBB Account Key → Consumption Account
```
- Raw Materials → 500000 (Material Consumption)
- Finished Goods → 510000 (Cost of Goods Sold)

### 3. Purchase Price Variances
```
Price Difference → PRD Account Key → 540000 (Price Differences)
```
- When purchase price differs from standard price
- Captures material cost variances

### 4. Goods Receipt/Invoice Receipt Clearing
```
GR/IR Process → INV Account Key → 191000 (GR/IR Clearing)
```
- Temporary account for goods received but not invoiced
- Clears when invoice is received

### 5. Work in Progress
```
Project Materials → WIP Account Key → 130000 (Work in Progress)
```
- Materials allocated to construction projects
- Part of project cost accumulation

## Construction Industry Specifics

### Material Categories
- **MAT001 (Raw Materials)**: Cement, Steel, Aggregates, Hardware
- **MAT002 (Finished Goods)**: Prefab components, Completed assemblies

### Account Keys Usage
- **BSX**: Stock valuation for inventory
- **GBB**: Direct consumption/cost allocation  
- **PRD**: Purchase price variances
- **INV**: GR/IR clearing for procurement
- **WIP**: Project material allocation
- **VAR**: Material cost variances
- **FRE**: Freight and transportation costs

### Multi-Company Support
- Each company (C001, C002) has separate account determination
- Allows different accounting treatments per legal entity
- Supports consolidated reporting

## Integration Points

### With MM (Materials Management)
- Automatic posting during goods movements
- Real-time inventory valuation
- Purchase order processing

### With FI (Financial Accounting)
- Automatic GL postings
- Cost center assignments
- Profit center allocations

### With CO (Controlling)
- Project cost allocation
- Cost center postings
- Internal order settlements

### With PS (Project System)
- WBS element assignments
- Project material costs
- Settlement to profitability analysis

## Validation Rules
1. All combinations must have valid GL account mapping
2. Account keys must match movement types
3. Valuation classes must be assigned to materials
4. Company codes must be active and valid

## Reporting Impact
- **Balance Sheet**: Inventory valuations (BSX accounts)
- **P&L**: Material consumption (GBB accounts)  
- **Cost Reports**: Project allocations (WIP accounts)
- **Variance Analysis**: Price differences (PRD accounts)
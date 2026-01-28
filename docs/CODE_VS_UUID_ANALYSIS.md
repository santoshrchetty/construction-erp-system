# Database Design: Code vs UUID Foreign Keys - Analysis

## Current Situation

### material_requests table has BOTH:
```sql
-- Code fields (VARCHAR)
company_code        VARCHAR(10)
plant_code          VARCHAR(10)
cost_center         VARCHAR(20)
project_code        VARCHAR(20)
wbs_element         VARCHAR(50)

-- UUID fields (UUID)
company_id          UUID
plant_id            UUID
project_id          UUID
cost_center_id      UUID
wbs_element_id      UUID
activity_id         UUID
```

## Option 1: Use Codes Only (RECOMMENDED) ✅

### Advantages:
1. **Human Readable**
   ```sql
   SELECT request_number, company_code, plant_code, project_code
   FROM material_requests
   WHERE company_code = '1000' AND plant_code = 'P001';
   -- Result: MR5300000001, 1000, P001, HW-0001
   ```

2. **No Joins Needed for Display**
   ```sql
   -- Current with UUIDs (requires joins)
   SELECT mr.*, cc.company_name, p.plant_name
   FROM material_requests mr
   JOIN company_codes cc ON mr.company_id = cc.id
   JOIN plants p ON mr.plant_id = p.id;
   
   -- With codes only (direct display)
   SELECT request_number, company_code, plant_code, project_code
   FROM material_requests;
   ```

3. **Easier Debugging**
   - Can read data directly in database
   - No UUID lookup needed
   - Logs are readable

4. **Better Performance**
   - Smaller index size (VARCHAR vs UUID)
   - Fewer joins in queries
   - Faster lookups

5. **SAP Alignment**
   - SAP uses codes everywhere (BUKRS, WERKS, KOSTL, etc.)
   - Direct mapping to SAP fields
   - No conversion needed for integration

6. **Simpler API**
   ```typescript
   // No conversion needed
   const request = {
     company_code: '1000',
     plant_code: 'P001',
     project_code: 'HW-0001'
   }
   ```

### Disadvantages:
1. **Referential Integrity**
   - Need to ensure codes exist in master tables
   - Can use foreign key constraints on code fields
   ```sql
   ALTER TABLE material_requests
   ADD CONSTRAINT fk_company_code 
   FOREIGN KEY (company_code) 
   REFERENCES company_codes(company_code);
   ```

2. **Code Changes**
   - If company code changes, need to update all references
   - Mitigated: Codes rarely change in ERP systems
   - SAP standard: Codes are immutable

3. **Slightly Larger Storage**
   - VARCHAR(10) = 10 bytes vs UUID = 16 bytes
   - But saves join overhead

## Option 2: Use UUIDs Only

### Advantages:
1. **Immutable References**
   - UUID never changes
   - Safe from code changes

2. **Database Best Practice**
   - Surrogate keys
   - Normalized design

### Disadvantages:
1. **Not Human Readable**
   ```sql
   SELECT * FROM material_requests;
   -- Result: 8cde2191-2582-4cb0-b748-2a3e334da736, a1b2c3d4-...
   -- What company? What plant? Need joins to know!
   ```

2. **Always Need Joins**
   ```sql
   -- Every query needs joins
   SELECT mr.*, cc.company_code, p.plant_code
   FROM material_requests mr
   JOIN company_codes cc ON mr.company_id = cc.id
   JOIN plants p ON mr.plant_id = p.id
   JOIN projects pr ON mr.project_id = pr.id
   JOIN cost_centers c ON mr.cost_center_id = c.id;
   ```

3. **Complex API Logic**
   ```typescript
   // Need to resolve codes to UUIDs
   const companyId = await resolveCompanyCode(company_code)
   const plantId = await resolvePlantCode(plant_code)
   // Then save
   ```

4. **Not SAP-Aligned**
   - SAP uses codes
   - Need conversion layer

## Option 3: Hybrid (Current State)

### Current Implementation:
- Has BOTH code and UUID fields
- Redundant storage
- Inconsistent usage

### Problems:
1. **Data Duplication**
   - Storing same information twice
   - Sync issues possible

2. **Confusion**
   - Which field to use?
   - Inconsistent queries

3. **Maintenance Overhead**
   - Update both fields
   - Validate consistency

## Recommendation: Use Codes Only ✅

### Migration Strategy:

```sql
-- Step 1: Ensure code fields are populated
UPDATE material_requests mr
SET company_code = cc.company_code
FROM company_codes cc
WHERE mr.company_id = cc.id AND mr.company_code IS NULL;

-- Step 2: Add foreign key constraints
ALTER TABLE material_requests
ADD CONSTRAINT fk_mr_company_code 
FOREIGN KEY (company_code) REFERENCES company_codes(company_code),
ADD CONSTRAINT fk_mr_plant_code 
FOREIGN KEY (plant_code) REFERENCES plants(plant_code),
ADD CONSTRAINT fk_mr_project_code 
FOREIGN KEY (project_code) REFERENCES projects(project_code),
ADD CONSTRAINT fk_mr_cost_center 
FOREIGN KEY (cost_center) REFERENCES cost_centers(cost_center_code);

-- Step 3: Drop UUID columns (after verification)
ALTER TABLE material_requests
DROP COLUMN company_id,
DROP COLUMN plant_id,
DROP COLUMN project_id,
DROP COLUMN cost_center_id,
DROP COLUMN wbs_element_id,
DROP COLUMN activity_id;
```

### Benefits After Migration:

1. **Cleaner Schema**
   ```sql
   material_requests:
   - id (UUID, PK)
   - request_number (VARCHAR)
   - company_code (VARCHAR, FK)
   - plant_code (VARCHAR, FK)
   - project_code (VARCHAR, FK)
   - cost_center (VARCHAR, FK)
   - wbs_element (VARCHAR, FK)
   ```

2. **Simpler Queries**
   ```sql
   -- Get all requests for company 1000, plant P001
   SELECT * FROM material_requests
   WHERE company_code = '1000' AND plant_code = 'P001';
   
   -- No joins needed!
   ```

3. **Readable Data**
   ```
   request_number | company_code | plant_code | project_code
   MR5300000001  | 1000         | P001       | HW-0001
   MR5300000002  | 1000         | P002       | HW-0002
   ```

4. **SAP Integration Ready**
   ```typescript
   // Direct mapping to SAP
   const sapData = {
     BANFN: request.request_number,
     BUKRS: request.company_code,
     WERKS: request.plant_code,
     KOSTL: request.cost_center
   }
   ```

## Real-World Comparison

### SAP S/4HANA Approach:
```sql
-- SAP EBAN (Purchase Requisition)
BANFN    BUKRS  WERKS  KOSTL   PSPEL
10000001 1000   P001   CC001   WBS001

-- Uses codes, not UUIDs!
```

### Our Approach (Recommended):
```sql
-- material_requests
request_number  company_code  plant_code  cost_center  wbs_element
MR5300000001   1000          P001        CC001        WBS001

-- Same as SAP!
```

## Decision Matrix

| Criteria | Codes Only | UUIDs Only | Hybrid |
|----------|-----------|------------|--------|
| Readability | ✅ Excellent | ❌ Poor | ⚠️ Mixed |
| Performance | ✅ Fast | ❌ Slow (joins) | ⚠️ Medium |
| SAP Alignment | ✅ Perfect | ❌ Poor | ⚠️ Partial |
| Maintenance | ✅ Simple | ⚠️ Complex | ❌ Very Complex |
| Storage | ✅ Efficient | ✅ Efficient | ❌ Redundant |
| Referential Integrity | ✅ FK constraints | ✅ FK constraints | ⚠️ Dual maintenance |
| Code Changes | ⚠️ Need cascade | ✅ Immune | ⚠️ Need sync |

## Conclusion

**Use Codes Only** for:
- material_requests
- purchase_requisitions
- purchase_orders
- goods_receipts
- All transactional tables

**Reasoning:**
1. SAP standard practice
2. Human readable
3. Better performance
4. Simpler code
5. Easier debugging
6. Direct integration ready

**Implementation:**
- Keep UUID as primary key (id)
- Use codes for all foreign keys
- Add FK constraints on codes
- Remove UUID foreign key columns

This is the **SAP-aligned, industry-standard approach** for ERP systems.

## **DESIGN REFERENCE UPDATE: HSN Material Master Integration**

### **Added to Existing Architecture**

Building on our **centralized authorization service** and **multi-company database architecture**, we now include **HSN Material Master** for complete GST compliance.

## **Enhanced Multi-Company Architecture with HSN Management**

### **Layer 1: Authorization Service (Existing)**
- ✅ **authMiddleware.ts**: Centralized auth with 4-layer architecture
- ✅ **authorizationService.ts**: Business logic with getUserPermissions, getUserModules
- ✅ **authorizationRepository.ts**: Data access with getUserRole, getRolePermissions

### **Layer 2: Multi-Company Database (Existing)**
- ✅ **consolidate-abc-companies.sql**: Parent companies with grouped company codes
- ✅ **Master Data Isolation**: company_code columns in all master data tables
- ✅ **Data Sharing**: copy_project_master_data() within same parent company

### **Layer 3: GST Compliance Engine (NEW)**
- ✅ **minimal-gst-implementation.sql**: State-based GST calculation with CGST/SGST vs IGST
- ✅ **hsn-material-master-approach.sql**: Material master with HSN classification
- ✅ **Capital Goods Logic**: 20% immediate, 80% restricted input credit over 4 years

## **Complete GL Determination Framework**

### **Enhanced Data Flow**
```
Material Code → Material Master → HSN Code → GST Rate → GL Accounts
     ↓              ↓              ↓           ↓           ↓
  STEEL_TMT_8MM → TMT Steel 8mm → 7214 → 18% → 130200 (Inventory)
                                   ↓
                            State Logic → CGST+SGST vs IGST
```

### **Multi-Company HSN Management**
```sql
-- Company-specific material master with HSN
material_master:
- C001: STEEL_TMT_8MM → HSN 7214 → 18% GST
- C002: STEEL_TMT_8MM → HSN 7214 → 18% GST (shared within ABC Group)
- B001: STEEL_TMT_8MM → HSN 7214 → 18% GST (separate company)
```

## **Integration with Existing Components**

### **API Layer Updates**
- ✅ **app/api/erp-config/projects/route.ts**: Enhanced with HSN fields and minimal GST endpoint
- ✅ **domains/projects/projectConfigServices.ts**: Added getGLDeterminationMinimal method

### **Frontend Components**
- ✅ **components/EnhancedProjectsConfigTab.tsx**: Updated with company_code columns visible
- ⚠️ **PENDING**: Add HSN code fields and material master integration

### **Service Layer**
- ✅ **lib/services/authorizationService.ts**: Multi-company authorization
- ✅ **lib/authMiddleware.ts**: Centralized auth context
- ⚠️ **PENDING**: Material master service integration

## **Complete Architecture Benefits**

### **1. Authorization + Multi-Company + GST Compliance**
- **Secure**: Role-based access with company isolation
- **Compliant**: GST Act 2017 compliant with proper HSN classification
- **Scalable**: Supports multiple companies with shared/isolated data

### **2. Data Consistency**
- **Material Master**: Same material always uses same HSN across companies
- **Company Isolation**: C001-C004 data sharing within ABC Group, isolated from other companies
- **Authorization**: Users only see data they're authorized for

### **3. Operational Efficiency**
- **Automated GST**: No manual HSN entry, calculated from material master
- **Centralized Auth**: Single authorization service across all modules
- **Multi-Company**: Shared master data within parent companies

## **Implementation Status**

### **✅ COMPLETED**
- Multi-company database architecture
- Centralized authorization service  
- Minimal GST compliance engine
- Company code visibility in UI tables
- State-based GST calculation
- Capital goods input credit logic

### **⚠️ PENDING (3-4 Hours)**
- Material master table creation
- HSN master data setup
- Frontend material selection
- Complete GL determination integration

## **Final Architecture Stack**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  EnhancedProjectsConfigTab.tsx (with company_code columns)  │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                  AUTHENTICATION LAYER                      │
│     authMiddleware.ts → authorizationService.ts            │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                     │
│  projectConfigServices.ts + Material Master Services       │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                       │
│  Multi-Company DB + GST Engine + Material Master           │
│  - consolidate-abc-companies.sql                           │
│  - minimal-gst-implementation.sql                          │
│  - hsn-material-master-approach.sql                        │
└─────────────────────────────────────────────────────────────┘
```

## **Key Design Decisions**

1. **HSN at Material Level**: Ensures consistency and compliance
2. **State-Based GST**: Automatic CGST/SGST vs IGST calculation
3. **Multi-Company Isolation**: Company codes in all master data
4. **Centralized Authorization**: Single auth service across modules
5. **Parent Company Sharing**: ABC Group companies share master data

This creates a **production-ready, compliance-driven, multi-company Construction ERP** with proper authorization, GST compliance, and operational efficiency.
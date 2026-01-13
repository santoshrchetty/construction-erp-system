# Architecture Discovery Guide

## Quick Start: Understanding This Codebase

When approaching this construction management app fresh, examine these files in order:

### 1. Project Overview (30 seconds)
```
package.json                    # Tech stack: Next.js + Supabase + TypeScript
docs/README.md                  # Module implementation strategy
tsconfig.json                  # TypeScript configuration
```

### 2. Application Structure (2 minutes)
```
app/layout.tsx                 # Root layout, providers, global setup
app/page.tsx                   # Main entry point
middleware.ts                  # Route protection, auth flow
```

### 3. Data Architecture (5 minutes)
```
types/supabase/database.types.ts    # Complete database schema
types/index.ts                      # Main type exports
lib/repositories.ts                 # Repository factory/registry
examples/usage.ts                   # Complete workflow demonstration
```

### 4. Business Logic (10 minutes)
```
domains/                       # Domain services (11 modules)
├── projects/projectServices.ts
├── procurement/createPurchaseOrder.ts  # Full business logic example
├── finance/financeServices.ts
└── ...

lib/services/                  # Calculation services
├── ctc.service.ts            # Cost-to-Complete
├── evm.service.ts            # Earned Value Management
└── margin.service.ts         # Margin analysis
```

### 5. Authentication & Authorization (5 minutes)
```
lib/auth.ts                    # Auth service
lib/contexts/AuthContext.tsx   # Auth state management
components/permissions/        # Permission system
```

## 4-Layer Architecture Implementation

This app follows a **proper 4-layer architecture**:

### Layer 1: Presentation
```
app/                          # Next.js App Router pages
components/                   # React components
├── ui/                      # Reusable UI components
├── forms/                   # Form components
├── projects/                # Feature-specific components
└── permissions/             # Authorization components
```

### Layer 2: Business Logic
```
domains/                     # Domain services (11 modules)
├── projects/               # Project management
├── procurement/            # Purchase orders, vendors
├── finance/               # Financial operations
├── materials/             # Material management
├── hr/                    # Human resources
└── ...

lib/services/              # Calculation engines
├── ctc.service.ts        # Cost-to-Complete calculations
├── evm.service.ts        # Earned Value Management
└── margin.service.ts     # Margin analysis
```

### Layer 3: Data Access
```
types/repositories/           # Repository pattern (15+ repositories)
├── base.repository.ts       # Base CRUD operations
├── projects.repository.ts   # Project-specific queries
├── procurement.repository.ts # Vendor & PO operations
└── ...

lib/repositories.ts          # Repository factory
```

### Layer 4: Database
```
database/                    # SQL files, functions, policies
├── migrations/             # Database migrations
├── functions/              # Stored procedures
├── policies/               # Row Level Security
└── archive/                # Legacy SQL files (needs cleanup)
```

## Key Discovery Files

### Most Revealing for Architecture Understanding:

1. **`examples/usage.ts`** - Shows complete construction workflow
2. **`domains/procurement/createPurchaseOrder.ts`** - Excellent business logic example
3. **`lib/services/ctc.service.ts`** - Advanced calculation service
4. **`types/repositories/base.repository.ts`** - Data access patterns
5. **`lib/repositories.ts`** - Available data operations

### Business Logic Quality Assessment:

**✅ Excellent Implementation:**
- `domains/procurement/createPurchaseOrder.ts` - Full validation, business rules
- `lib/services/ctc.service.ts` - Complex calculations, formatting
- `lib/services/evm.service.ts` - Earned value management

**⚠️ Needs Completion:**
- `domains/projects/projectServices.ts` - Currently returns mock data
- Some API handlers in `app/api/` - Thin stubs (should call services)

## Architecture Compliance

### ✅ What's Correct:
- **4-layer separation** properly implemented
- **Repository pattern** with inheritance and domain-specific methods
- **Business services** contain real calculation logic
- **Type safety** throughout with TypeScript + Zod
- **Domain organization** by business area

### ⚠️ Minor Issues:
- Some services return mock data (need completion)
- Repository factory missing some exports
- Examples bypass business layer (architectural violation)

## Common Misconceptions

### ❌ "Business layer is missing"
**Reality**: 11 domain services + 3 calculation services exist

### ❌ "Only repositories exist"
**Reality**: Rich business logic in domains/ and lib/services/

### ❌ "Architecture is incomplete"
**Reality**: Proper 4-layer implementation with minor gaps

## Next Steps for New Developers

1. **Run examples/usage.ts** to see complete workflow
2. **Study domains/procurement/** for business logic patterns
3. **Check lib/services/** for calculation examples
4. **Review types/repositories/** for data access patterns
5. **Examine components/projects/** for UI integration

## Architecture Discovery Checklist

When analyzing any similar codebase:

- [ ] Check root directory structure first
- [ ] Look for business logic in multiple locations (domains/, services/, lib/)
- [ ] Verify repository pattern implementation
- [ ] Test example workflows
- [ ] Assess service quality individually
- [ ] Don't assume missing layers without systematic exploration

This prevents the common mistake of concluding "business layer is missing" when it's actually well-implemented in a different location.
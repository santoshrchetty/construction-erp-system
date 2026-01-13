// Configuration constants - centralized to avoid hardcoding
export const CONFIG = {
  // Company settings
  DEFAULT_COMPANY_CODE: process.env.NEXT_PUBLIC_DEFAULT_COMPANY_CODE || 'C001',
  
  // Project categories
  PROJECT_CATEGORIES: {
    CUSTOMER: 'Customer Projects',
    CONTRACT: 'Contract Projects', 
    CAPITAL: 'Capital Projects',
    OVERHEAD: 'Overhead Projects',
    RND: 'R&D Projects',
    MAINTENANCE: 'Maintenance Projects'
  },
  
  // Cost ownership patterns - reflects final cost destination
  COST_OWNERSHIP: {
    ASSET_CAPITALIZED: 'Capitalize to Fixed Assets',
    PERIOD_EXPENSED: 'Expense to Current Period', 
    COST_ALLOCATED: 'Allocate Across Cost Objects',
    REVENUE_GENERATING: 'Revenue Recognition Matching'
  },
  
  // Event types
  EVENT_TYPES: {
    MATERIAL_CONSUMPTION: 'Material Consumption',
    LABOR_COST: 'Labor Cost',
    OVERHEAD_ALLOCATION: 'Overhead Allocation',
    REVENUE_RECOGNITION: 'Revenue Recognition'
  },
  
  // GL Account types
  GL_ACCOUNT_TYPES: {
    WIP: 'Work in Progress',
    EXPENSE: 'Expense',
    REVENUE: 'Revenue',
    COGS: 'Cost of Goods Sold'
  },
  
  // Debit/Credit options
  DEBIT_CREDIT: {
    D: 'Debit',
    C: 'Credit'
  },
  
  // Workflow statuses
  WORKFLOW_STATUS: {
    ACTIVE: 'Active',
    DRAFT: 'Draft',
    INACTIVE: 'Inactive'
  },
  
  // UI Configuration
  UI: {
    ITEMS_PER_PAGE: 10,
    SEARCH_DEBOUNCE_MS: 300,
    NOTIFICATION_TIMEOUT_MS: 3000,
    MIN_TOUCH_TARGET_SIZE: 44 // pixels
  },

  // Project types for 2-level hierarchy
  PROJECT_TYPES: {
    // Customer types
    FIXED_PRICE: 'Fixed Price Contracts',
    TIME_MATERIAL: 'Time & Material',
    COST_PLUS: 'Cost Plus Fee',
    MAINTENANCE: 'Service Contracts',
    
    // Contract types
    LUMP_SUM: 'Lump Sum Contract',
    UNIT_PRICE: 'Unit Price Contract', 
    MILESTONE: 'Milestone Contract',
    RETAINER: 'Retainer Contract',
    
    // Capital types
    BUILDING: 'Building Construction',
    EQUIPMENT: 'Equipment Purchase',
    IT_INFRASTRUCTURE: 'IT Infrastructure',
    RENOVATION: 'Renovation Projects'
  }
}
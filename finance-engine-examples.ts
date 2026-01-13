// Example Usage of Modern Finance Engine
// Shows how different modules post events to the universal journal

import { ModernFinanceEngine, FinanceEvent } from './ModernFinanceEngine'

// Example 1: Project Labor Cost Event (from HR/Timesheet)
const projectLaborEvent: FinanceEvent = {
  eventId: "evt-789456",
  eventType: "PROJECT_LABOR_COST",
  eventTimestamp: "2026-01-15T10:30:00Z",
  sourceSystem: "HR",
  sourceDocument: { type: "TIMESHEET", id: "TS-789456" },
  companyCode: "C001",
  postingDate: "2026-01-15",
  ledgerScope: ["ACCRUAL"],
  currency: { transaction: "USD", amount: 800 },
  dimensions: {
    glAccount: "510000", // Will be overridden by lines
    costCenter: "CC-HR",
    profitCenter: "PC-TECH",
    project: "P100",
    wbs: "P100-01",
    asset: "CIP-900123",
    employee: "E4567"
  },
  postingKey: "AUTO",
  lines: [
    { side: "DEBIT", glAccount: "510000", amount: 800 },   // Labor Expense
    { side: "CREDIT", glAccount: "210000", amount: 800 }   // Payroll Liability
  ]
}

// Example 2: Customer Invoice Event (from Sales)
const customerInvoiceEvent: FinanceEvent = {
  eventId: "evt-inv-123",
  eventType: "CUSTOMER_INVOICE_POSTED",
  eventTimestamp: "2026-01-15T14:00:00Z",
  sourceSystem: "SD",
  sourceDocument: { type: "INVOICE", id: "INV-123456" },
  companyCode: "C001",
  postingDate: "2026-01-15",
  ledgerScope: ["ACCRUAL", "TAX"],
  currency: { transaction: "USD", amount: 12000 },
  dimensions: {
    glAccount: "130000",
    customer: "CUST-001",
    project: "P100",
    profitCenter: "PC-SALES"
  },
  postingKey: "AUTO",
  lines: [
    { side: "DEBIT", glAccount: "130000", amount: 12000 },  // Accounts Receivable
    { side: "CREDIT", glAccount: "400000", amount: 10000 }, // Revenue
    { side: "CREDIT", glAccount: "240000", amount: 2000 }   // Sales Tax Payable
  ]
}

// Example 3: Material Issue to Production
const materialIssueEvent: FinanceEvent = {
  eventId: "evt-mat-456",
  eventType: "MATERIAL_ISSUED_TO_PRODUCTION",
  eventTimestamp: "2026-01-15T09:15:00Z",
  sourceSystem: "MM",
  sourceDocument: { type: "MATERIAL_DOCUMENT", id: "MD-456789" },
  companyCode: "C001",
  postingDate: "2026-01-15",
  ledgerScope: ["ACCRUAL"],
  currency: { transaction: "USD", amount: 5000 },
  dimensions: {
    glAccount: "140000",
    material: "MAT-STEEL-001",
    project: "P100",
    wbs: "P100-02",
    costCenter: "CC-PROD"
  },
  postingKey: "AUTO",
  lines: [
    { side: "CREDIT", glAccount: "140000", amount: 5000 }, // Inventory
    { side: "DEBIT", glAccount: "520000", amount: 5000 }   // Production Cost
  ]
}

// Example 4: Depreciation Event (from Asset Accounting)
const depreciationEvent: FinanceEvent = {
  eventId: "evt-depr-789",
  eventType: "DEPRECIATION_POSTED",
  eventTimestamp: "2026-01-31T23:59:00Z",
  sourceSystem: "AA",
  sourceDocument: { type: "DEPRECIATION_RUN", id: "DEPR-202601" },
  companyCode: "C001",
  postingDate: "2026-01-31",
  ledgerScope: ["ACCRUAL"],
  currency: { transaction: "USD", amount: 2500 },
  dimensions: {
    glAccount: "170000",
    asset: "EQUIP-001",
    costCenter: "CC-ADMIN"
  },
  postingKey: "AUTO",
  lines: [
    { side: "DEBIT", glAccount: "540000", amount: 2500 },  // Depreciation Expense
    { side: "CREDIT", glAccount: "180000", amount: 2500 }  // Accumulated Depreciation
  ]
}

// Usage Example
export async function processBusinessEvents() {
  const financeEngine = new ModernFinanceEngine()
  const userId = "user-123"

  try {
    // Process different business events
    await financeEngine.processFinanceEvent(projectLaborEvent, userId)
    await financeEngine.processFinanceEvent(customerInvoiceEvent, userId)
    await financeEngine.processFinanceEvent(materialIssueEvent, userId)
    await financeEngine.processFinanceEvent(depreciationEvent, userId)

    console.log("All events processed successfully")
  } catch (error) {
    console.error("Error processing events:", error)
  }
}

// API Endpoint for processing finance events
export async function POST(request: Request) {
  try {
    const event: FinanceEvent = await request.json()
    const financeEngine = new ModernFinanceEngine()
    
    // Get user from auth context (simplified)
    const userId = "system-user"
    
    const result = await financeEngine.processFinanceEvent(event, userId)
    
    return Response.json({
      success: true,
      message: `Processed ${result.journalEntries} journal entries`,
      eventId: event.eventId
    })
  } catch (error) {
    return Response.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
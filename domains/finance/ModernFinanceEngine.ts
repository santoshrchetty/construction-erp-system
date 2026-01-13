// Modern Event-Based Finance Engine Service
// Processes business events and creates universal journal entries

export interface FinanceEvent {
  eventId: string
  eventType: string
  eventTimestamp: string
  sourceSystem: string
  sourceDocument: {
    type: string
    id: string
  }
  companyCode: string
  postingDate: string
  ledgerScope: string[] // ['ACCRUAL', 'CASH', 'TAX', 'MANAGEMENT']
  currency: {
    transaction: string
    amount: number
  }
  dimensions: {
    glAccount: string
    costCenter?: string
    profitCenter?: string
    project?: string
    wbs?: string
    asset?: string
    employee?: string
    customer?: string
    supplier?: string
    material?: string
    [key: string]: any
  }
  postingKey: 'AUTO' // Always auto-derive
  lines: Array<{
    side: 'DEBIT' | 'CREDIT'
    glAccount: string
    amount: number
  }>
}

export interface UniversalJournalEntry {
  eventId: string
  eventType: string
  eventTimestamp: string
  sourceSystem: string
  sourceDocumentType: string
  sourceDocumentId: string
  companyCode: string
  ledger: string
  postingDate: string
  documentDate: string
  glAccount: string
  postingKey: string
  debitCredit: 'D' | 'C'
  transactionCurrency: string
  transactionAmount: number
  companyCurrency: string
  companyAmount: number
  groupCurrency?: string
  groupAmount?: number
  fxRateTransactionToCompany?: number
  fxRateTransactionToGroup?: number
  fxRateSource?: string
  fxRateTimestamp?: string
  // Dimensions
  costCenter?: string
  profitCenter?: string
  projectCode?: string
  wbsElement?: string
  assetNumber?: string
  materialNumber?: string
  employeeId?: string
  customerCode?: string
  supplierCode?: string
  taxCode?: string
  createdBy: string
}

export class ModernFinanceEngine {
  private repository: FinanceEngineRepository

  constructor() {
    this.repository = new FinanceEngineRepository()
  }

  // Main entry point - processes any business event
  async processFinanceEvent(event: FinanceEvent, userId: string): Promise<{success: boolean, journalEntries: number}> {
    try {
      console.log('Processing finance event:', event.eventType, event.eventId)

      // 1. Validate event
      await this.validateEvent(event)

      // 2. Get company currencies
      const companyCurrencies = await this.repository.getCompanyCurrencies(event.companyCode)

      // 3. Get FX rates if needed
      const fxRates = await this.getFXRates(event.currency.transaction, companyCurrencies, event.postingDate)

      // 4. Process each ledger scope
      const journalEntries: UniversalJournalEntry[] = []

      for (const ledger of event.ledgerScope) {
        for (const line of event.lines) {
          // 5. Auto-derive posting key
          const postingKey = await this.derivePostingKey(event.eventType, line.glAccount)

          // 6. Create journal entry
          const journalEntry: UniversalJournalEntry = {
            eventId: event.eventId,
            eventType: event.eventType,
            eventTimestamp: event.eventTimestamp,
            sourceSystem: event.sourceSystem,
            sourceDocumentType: event.sourceDocument.type,
            sourceDocumentId: event.sourceDocument.id,
            companyCode: event.companyCode,
            ledger,
            postingDate: event.postingDate,
            documentDate: event.postingDate,
            glAccount: line.glAccount,
            postingKey: postingKey.postingKey,
            debitCredit: line.side === 'DEBIT' ? 'D' : 'C',
            transactionCurrency: event.currency.transaction,
            transactionAmount: line.amount,
            companyCurrency: companyCurrencies.local,
            companyAmount: line.amount * (fxRates.transactionToCompany || 1),
            groupCurrency: companyCurrencies.group,
            groupAmount: line.amount * (fxRates.transactionToGroup || 1),
            fxRateTransactionToCompany: fxRates.transactionToCompany,
            fxRateTransactionToGroup: fxRates.transactionToGroup,
            fxRateSource: fxRates.source,
            fxRateTimestamp: fxRates.timestamp,
            // Map dimensions
            costCenter: event.dimensions.costCenter,
            profitCenter: event.dimensions.profitCenter,
            projectCode: event.dimensions.project,
            wbsElement: event.dimensions.wbs,
            assetNumber: event.dimensions.asset,
            employeeId: event.dimensions.employee,
            customerCode: event.dimensions.customer,
            supplierCode: event.dimensions.supplier,
            createdBy: userId
          }

          journalEntries.push(journalEntry)
        }
      }

      // 7. Post to universal journal
      await this.repository.insertJournalEntries(journalEntries)

      console.log(`Posted ${journalEntries.length} journal entries for event ${event.eventId}`)

      return { success: true, journalEntries: journalEntries.length }

    } catch (error) {
      console.error('Error processing finance event:', error)
      throw error
    }
  }

  // Auto-derive posting key from event type + GL account type
  private async derivePostingKey(eventType: string, glAccount: string): Promise<{postingKey: string, debitCredit: string}> {
    // Get GL account type
    const accountType = await this.repository.getGLAccountType(glAccount)
    
    // Lookup posting key mapping
    const mapping = await this.repository.getPostingKeyMapping(eventType, accountType)
    
    if (!mapping) {
      throw new Error(`No posting key mapping found for event type ${eventType} and account type ${accountType}`)
    }

    return {
      postingKey: mapping.posting_key,
      debitCredit: mapping.debit_credit
    }
  }

  // Get FX rates for currency conversion
  private async getFXRates(transactionCurrency: string, companyCurrencies: any, postingDate: string) {
    const rates: any = {
      transactionToCompany: 1,
      transactionToGroup: 1,
      source: 'SYSTEM',
      timestamp: new Date().toISOString()
    }

    if (transactionCurrency !== companyCurrencies.local) {
      rates.transactionToCompany = await this.repository.getFXRate(transactionCurrency, companyCurrencies.local, postingDate)
    }

    if (transactionCurrency !== companyCurrencies.group) {
      rates.transactionToGroup = await this.repository.getFXRate(transactionCurrency, companyCurrencies.group, postingDate)
    }

    return rates
  }

  private async validateEvent(event: FinanceEvent): Promise<void> {
    if (!event.eventId || !event.eventType || !event.companyCode) {
      throw new Error('Missing required event fields')
    }

    if (!event.lines || event.lines.length === 0) {
      throw new Error('Event must have at least one journal line')
    }

    // Validate balanced entry
    const debitTotal = event.lines.filter(l => l.side === 'DEBIT').reduce((sum, l) => sum + l.amount, 0)
    const creditTotal = event.lines.filter(l => l.side === 'CREDIT').reduce((sum, l) => sum + l.amount, 0)

    if (Math.abs(debitTotal - creditTotal) > 0.01) {
      throw new Error(`Unbalanced entry: Debit ${debitTotal}, Credit ${creditTotal}`)
    }
  }
}
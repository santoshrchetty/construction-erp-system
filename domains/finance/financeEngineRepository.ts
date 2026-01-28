// Finance Engine Repository - Data Access Layer for Universal Journal
import { createClient } from '@supabase/supabase-js'
import { UniversalJournalEntry } from './ModernFinanceEngine'

export class FinanceEngineRepository {
  private supabase

  constructor() {
    this.supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
    )
  }

  // Insert journal entries to universal journal
  async insertJournalEntries(entries: UniversalJournalEntry[]): Promise<void> {
    const { error } = await this.supabase
      .from('universal_journal')
      .insert(entries.map(entry => ({
        event_id: entry.eventId,
        event_type: entry.eventType,
        event_timestamp: entry.eventTimestamp,
        source_system: entry.sourceSystem,
        source_document_type: entry.sourceDocumentType,
        source_document_id: entry.sourceDocumentId,
        company_code: entry.companyCode,
        ledger: entry.ledger,
        posting_date: entry.postingDate,
        document_date: entry.documentDate,
        gl_account: entry.glAccount,
        posting_key: entry.postingKey,
        debit_credit: entry.debitCredit,
        transaction_currency: entry.transactionCurrency,
        transaction_amount: entry.transactionAmount,
        company_currency: entry.companyCurrency,
        company_amount: entry.companyAmount,
        group_currency: entry.groupCurrency,
        group_amount: entry.groupAmount,
        fx_rate_transaction_to_company: entry.fxRateTransactionToCompany,
        fx_rate_transaction_to_group: entry.fxRateTransactionToGroup,
        fx_rate_source: entry.fxRateSource,
        fx_rate_timestamp: entry.fxRateTimestamp,
        cost_center: entry.costCenter,
        profit_center: entry.profitCenter,
        project_code: entry.projectCode,
        wbs_element: entry.wbsElement,
        asset_number: entry.assetNumber,
        employee_id: entry.employeeId,
        customer_code: entry.customerCode,
        supplier_code: entry.supplierCode,
        created_by: entry.createdBy
      })))

    if (error) throw error
  }

  // Get GL account type for posting key derivation
  async getGLAccountType(glAccount: string): Promise<string> {
    const { data, error } = await this.supabase
      .from('chart_of_accounts')
      .select('account_type')
      .eq('account_code', glAccount)
      .single()

    if (error) throw error
    return data.account_type
  }

  // Get posting key mapping
  async getPostingKeyMapping(eventType: string, accountType: string): Promise<any> {
    const { data, error } = await this.supabase
      .from('posting_key_mapping')
      .select('posting_key, debit_credit, posting_key_description')
      .eq('event_type', eventType)
      .eq('gl_account_type', accountType)
      .eq('is_active', true)
      .single()

    if (error) throw error
    return data
  }

  // Get company currencies
  async getCompanyCurrencies(companyCode: string): Promise<{local: string, group: string}> {
    const { data, error } = await this.supabase
      .from('company_codes')
      .select('local_currency, reporting_currency')
      .eq('company_code', companyCode)
      .single()

    if (error) throw error
    
    return {
      local: data.local_currency || 'USD',
      group: data.reporting_currency || 'USD'
    }
  }

  // Get FX rate (simplified - in real implementation, connect to FX rate service)
  async getFXRate(fromCurrency: string, toCurrency: string, postingDate: string): Promise<number> {
    if (fromCurrency === toCurrency) return 1

    // Simplified FX rate lookup - in production, use real FX rate service
    const { data, error } = await this.supabase
      .from('fx_rates')
      .select('exchange_rate')
      .eq('from_currency', fromCurrency)
      .eq('to_currency', toCurrency)
      .lte('rate_date', postingDate)
      .order('rate_date', { ascending: false })
      .limit(1)
      .single()

    if (error || !data) {
      console.warn(`No FX rate found for ${fromCurrency}/${toCurrency}, using 1.0`)
      return 1.0
    }

    return data.exchange_rate
  }

  // Query universal journal for reporting
  async getJournalEntries(filters: {
    companyCode?: string
    ledger?: string
    eventType?: string
    postingDateFrom?: string
    postingDateTo?: string
    glAccount?: string
    projectCode?: string
    costCenter?: string
  }): Promise<any[]> {
    let query = this.supabase
      .from('universal_journal')
      .select('*')

    if (filters.companyCode) query = query.eq('company_code', filters.companyCode)
    if (filters.ledger) query = query.eq('ledger', filters.ledger)
    if (filters.eventType) query = query.eq('event_type', filters.eventType)
    if (filters.postingDateFrom) query = query.gte('posting_date', filters.postingDateFrom)
    if (filters.postingDateTo) query = query.lte('posting_date', filters.postingDateTo)
    if (filters.glAccount) query = query.eq('gl_account', filters.glAccount)
    if (filters.projectCode) query = query.eq('project_code', filters.projectCode)
    if (filters.costCenter) query = query.eq('cost_center', filters.costCenter)

    const { data, error } = await query.order('posting_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  // Get trial balance from universal journal
  async getTrialBalance(companyCode: string, ledger: string, postingDate: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .rpc('get_trial_balance', {
        p_company_code: companyCode,
        p_ledger: ledger,
        p_posting_date: postingDate
      })

    if (error) throw error
    return data || []
  }
}
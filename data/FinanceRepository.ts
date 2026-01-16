// Finance Repository - Data Access Layer
// Handles all database operations for GL Posting

import { createClient } from '@supabase/supabase-js'
import { GLDocument, GLEntry, ValidationResult } from '@/domains/finance/FinanceService'

export class FinanceRepository {
  private supabase

  constructor() {
    this.supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
  }

  // Get Cost Centers
  async getCostCenters(companyCode: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('cost_centers')
      .select('cost_center_code, cost_center_name, cost_center_type, responsible_person')
      .eq('company_code', companyCode)
      .eq('is_active', true)
      .order('cost_center_code')

    if (error) throw error
    return data || []
  }

  // Get WBS Elements
  async getWBSElements(companyCode: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('wbs_elements')
      .select('wbs_element, wbs_description, project_code, project_manager')
      .eq('company_code', companyCode)
      .eq('is_active', true)
      .order('wbs_element')

    if (error) throw error
    return data || []
  }

  // Get Profit Centers
  async getProfitCenters(companyCode: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('profit_centers')
      .select('profit_center_code, profit_center_name, responsible_person')
      .eq('company_code', companyCode)
      .eq('is_active', true)
      .order('profit_center_code')

    if (error) throw error
    return data || []
  }

  // Validate GL Posting using database function
  async validateGLPosting(companyCode: string, postingDate: string, entries: GLEntry[]): Promise<ValidationResult> {
    const { data, error } = await this.supabase
      .rpc('validate_gl_posting', {
        p_company_code: companyCode,
        p_posting_date: postingDate,
        p_entries: JSON.stringify(entries)
      })

    if (error) throw error
    
    const result = data?.[0]
    return {
      is_valid: result?.is_valid || false,
      error_message: result?.error_message
    }
  }

  // Check Account Authorization
  async checkAccountAuthorization(userId: string, companyCode: string, accountCode: string, authType: string, amount: number): Promise<boolean> {
    const { data, error } = await this.supabase
      .from('gl_account_authorization')
      .select('amount_limit')
      .eq('user_id', userId)
      .eq('company_code', companyCode)
      .eq('account_code', accountCode)
      .eq('authorization_type', authType)
      .single()

    if (error || !data) return false
    
    // Check amount limit
    if (data.amount_limit && amount > data.amount_limit) return false
    
    return true
  }

  // Check if approval required
  async checkApprovalRequired(documentType: string, totalAmount: number): Promise<boolean> {
    const { data, error } = await this.supabase
      .from('document_types')
      .select('requires_approval, approval_amount_limit')
      .eq('document_type', documentType)
      .single()

    if (error || !data) return false
    
    if (!data.requires_approval) return false
    
    if (data.approval_amount_limit && totalAmount <= data.approval_amount_limit) return false
    
    return true
  }

  // Get next document number
  async getNextDocumentNumber(companyCode: string, documentType: string): Promise<string> {
    const { data, error } = await this.supabase
      .rpc('get_next_document_number', {
        p_company_code: companyCode,
        p_document_type: documentType
      })

    if (error) throw error
    return data
  }

  // Create GL Document
  async createGLDocument(document: GLDocument & { document_number: string, status: string }, userId: string): Promise<any> {
    // Start transaction
    const { data: docData, error: docError } = await this.supabase
      .from('gl_documents')
      .insert({
        company_code: document.company_code,
        document_number: document.document_number,
        document_type: document.document_type || 'SA',
        posting_date: document.posting_date,
        document_date: document.document_date,
        reference: document.reference,
        header_text: document.header_text,
        currency_code: document.currency_code || 'USD',
        status: document.status,
        total_debit: document.entries.reduce((sum, e) => sum + (e.debit_credit === 'D' ? e.transaction_amount || 0 : 0), 0),
        total_credit: document.entries.reduce((sum, e) => sum + (e.debit_credit === 'C' ? e.transaction_amount || 0 : 0), 0),
        created_by: userId,
        posted_by: document.status === 'POSTED' ? userId : null,
        posted_at: document.status === 'POSTED' ? new Date().toISOString() : null
      })
      .select()
      .single()

    if (docError) throw docError

    // Insert entries
    const entriesData = document.entries.map(entry => ({
      document_id: docData.id,
      account_code: entry.account_code,
      debit_credit: entry.debit_credit || (entry.debit_amount > 0 ? 'D' : 'C'),
      transaction_amount: entry.transaction_amount || Math.max(entry.debit_amount || 0, entry.credit_amount || 0),
      cost_center: entry.cost_center,
      project_code: entry.project_code,
      wbs_element: entry.wbs_element,
      profit_center: entry.profit_center,
      description: entry.description,
      tax_code: entry.tax_code,
      tax_amount: entry.tax_amount || 0,
      assignment: entry.assignment,
      text: entry.text,
      currency_code: document.currency_code || 'USD'
    }))

    const { error: entriesError } = await this.supabase
      .from('gl_entries')
      .insert(entriesData)

    if (entriesError) throw entriesError

    return {
      document_id: docData.id,
      document_number: docData.document_number
    }
  }

  // Create Draft Document
  async createDraftDocument(document: GLDocument, userId: string): Promise<any> {
    const documentNumber = await this.getNextDocumentNumber(document.company_code, document.document_type || 'SA')
    
    return await this.createGLDocument({
      ...document,
      document_number: documentNumber,
      status: 'DRAFT'
    }, userId)
  }

  // Get GL Document
  async getGLDocument(documentId: string): Promise<any> {
    const { data: docData, error: docError } = await this.supabase
      .from('gl_documents')
      .select('*')
      .eq('id', documentId)
      .single()

    if (docError) throw docError

    const { data: entriesData, error: entriesError } = await this.supabase
      .from('gl_entries')
      .select('*')
      .eq('document_id', documentId)
      .order('created_at')

    if (entriesError) throw entriesError

    return {
      ...docData,
      entries: entriesData
    }
  }

  // Reverse GL Document
  async reverseGLDocument(documentId: string, userId: string, reason: string): Promise<any> {
    // Get original document
    const originalDoc = await this.getGLDocument(documentId)
    
    // Create reversal document
    const reversalNumber = await this.getNextDocumentNumber(originalDoc.company_code, originalDoc.document_type)
    
    // Reverse entries (swap debit/credit)
    const reversalEntries = originalDoc.entries.map((entry: any) => ({
      ...entry,
      debit_credit: entry.debit_credit === 'D' ? 'C' : 'D',
      description: `Reversal: ${entry.description}`
    }))

    const reversalDoc = await this.createGLDocument({
      company_code: originalDoc.company_code,
      document_type: originalDoc.document_type,
      posting_date: new Date().toISOString().split('T')[0],
      document_date: new Date().toISOString().split('T')[0],
      reference: `REV-${originalDoc.document_number}`,
      header_text: `Reversal of ${originalDoc.document_number}: ${reason}`,
      currency_code: originalDoc.currency_code,
      entries: reversalEntries,
      document_number: reversalNumber,
      status: 'POSTED'
    }, userId)

    // Update original document
    await this.supabase
      .from('gl_documents')
      .update({
        status: 'REVERSED',
        reversed_by: userId,
        reversed_at: new Date().toISOString(),
        reversal_reason: reason
      })
      .eq('id', documentId)

    return {
      reversal_document_number: reversalNumber
    }
  }

  // Get Companies
  async getCompanies(): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('company_codes')
      .select('company_code, company_name')
      .eq('is_active', true)
      .order('company_code')

    if (error) throw error
    
    return data?.map(company => ({
      code: company.company_code,
      name: `${company.company_code} - ${company.company_name}`
    })) || []
  }

  // Get GL Posting Configuration
  async getGLPostingConfig(companyCode: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .rpc('get_gl_posting_config', {
        p_company_code: companyCode
      })

    if (error) throw error
    return data || []
  }

  // Get Chart of Accounts
  async getChartOfAccounts(companyCode: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('chart_of_accounts')
      .select('account_code, account_name, account_type')
      .eq('company_code', companyCode)
      .eq('is_active', true)
      .order('account_code')

    if (error) throw error
    return data || []
  }

  // Copy Chart of Accounts between companies
  async copyChartOfAccounts(sourceCompany: string, targetCompany: string): Promise<any> {
    console.log('Repository: Starting copy', { sourceCompany, targetCompany }) // Debug
    
    // Create service role client for admin operations
    const serviceClient = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
    )

    // Get accounts from source company
    console.log('Repository: Fetching source accounts') // Debug
    const { data: sourceAccounts, error: sourceError } = await serviceClient
      .from('chart_of_accounts')
      .select('*')
      .eq('company_code', sourceCompany)

    console.log('Repository: Source accounts result', { 
      count: sourceAccounts?.length, 
      error: sourceError,
      firstAccount: sourceAccounts?.[0]
    }) // Debug

    if (sourceError) {
      console.error('Repository: Source error', sourceError)
      throw sourceError
    }

    if (!sourceAccounts || sourceAccounts.length === 0) {
      console.log('Repository: No source accounts found')
      throw new Error(`No accounts found in source company ${sourceCompany}`)
    }

    // Delete existing accounts for target company
    console.log('Repository: Deleting target accounts') // Debug
    const { error: deleteError } = await serviceClient
      .from('chart_of_accounts')
      .delete()
      .eq('company_code', targetCompany)

    console.log('Repository: Delete result', { error: deleteError }) // Debug

    if (deleteError) {
      console.error('Repository: Delete error', deleteError)
      throw deleteError
    }

    // Insert copied accounts with UPSERT to handle duplicates
    const accountsToInsert = sourceAccounts.map(account => ({
      company_code: targetCompany,
      account_code: account.account_code,
      account_name: account.account_name,
      account_type: account.account_type,
      coa_code: account.coa_code,
      coa_name: account.coa_name,
      cost_relevant: account.cost_relevant || false,
      balance_sheet_account: account.balance_sheet_account || false,
      cost_category: account.cost_category,
      is_active: true,
      created_at: new Date().toISOString()
    }))

    console.log('Repository: Inserting accounts', { 
      count: accountsToInsert.length,
      firstInsert: accountsToInsert[0]
    }) // Debug
    
    const { data: insertData, error: insertError } = await serviceClient
      .from('chart_of_accounts')
      .insert(accountsToInsert)
      .select()

    console.log('Repository: Insert result', { 
      error: insertError,
      insertedCount: insertData?.length
    }) // Debug

    if (insertError) {
      console.error('Repository: Insert error', insertError)
      throw insertError
    }

    const finalCount = insertData?.length || accountsToInsert.length
    console.log('Repository: Copy completed', { count: finalCount })
    
    return { count: finalCount }
  }
}
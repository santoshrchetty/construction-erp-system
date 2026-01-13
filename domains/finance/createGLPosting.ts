import { createServiceClient } from '@/lib/supabase'

export interface GLPostingPayload {
  company_code: string
  document_date: string
  posting_date: string
  reference: string
  header_text?: string
  entries: GLEntry[]
}

export interface GLEntry {
  account_code: string
  debit_amount?: number
  credit_amount?: number
  cost_center?: string
  project_code?: string
  description: string
}

export async function createGLPosting(payload: GLPostingPayload, userId: string) {
  const supabase = createServiceClient()
  
  // Validate document balance
  const entries = payload.entries || []
  const totalDebit = entries.reduce((sum, entry) => sum + (entry.debit_amount || 0), 0)
  const totalCredit = entries.reduce((sum, entry) => sum + (entry.credit_amount || 0), 0)
  
  if (Math.abs(totalDebit - totalCredit) > 0.01) {
    throw new Error('Document must be balanced: debits must equal credits')
  }

  // Generate document number
  const year = new Date().getFullYear()
  const docNumber = `GL-${payload.company_code}-${year}-${Date.now().toString().slice(-6)}`

  // Create GL document
  const { data: document, error: docError } = await supabase
    .from('gl_documents')
    .insert({
      company_code: payload.company_code,
      document_number: docNumber,
      posting_date: payload.posting_date,
      document_date: payload.document_date,
      reference: payload.reference,
      header_text: payload.header_text,
      status: 'POSTED',
      created_by: userId
    })
    .select()
    .single()

  if (docError) throw docError

  // Create GL entries
  if (entries.length > 0) {
    const glEntries = entries.map(entry => ({
      document_id: document.id,
      account_code: entry.account_code,
      debit_amount: entry.debit_amount || 0,
      credit_amount: entry.credit_amount || 0,
      cost_center: entry.cost_center,
      project_code: entry.project_code,
      description: entry.description
    }))

    const { error: entriesError } = await supabase
      .from('gl_entries')
      .insert(glEntries)

    if (entriesError) throw entriesError
  }

  return { document, entries: payload.entries }
}

export async function getGLAccounts(companyCode: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('chart_of_accounts')
    .select('account_code, account_name, account_type')
    .eq('company_code', companyCode)
    .eq('is_active', true)
    .order('account_code')

  if (error) throw error
  return data || []
}
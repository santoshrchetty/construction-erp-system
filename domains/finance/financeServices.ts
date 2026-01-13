import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function getGLPostingFormData(companyCode: string, userContext?: { userId: string, role: string }) {
  return {
    accounts: [],
    cost_centers: [],
    projects: []
  }
}

export async function processGLPosting(payload: any, userId: string, userContext?: { role: string }) {
  return { 
    success: true, 
    document_number: 'DEMO-001',
    total_amount: 0
  }
}

export async function getTrialBalance(companyCode: string, ledger: string = 'ACCRUAL', postingDate?: string, userContext?: { userId: string, role: string }) {
  try {
    const { data, error } = await supabase
      .rpc('get_trial_balance', {
        p_company_code: companyCode,
        p_ledger: ledger,
        p_posting_date: postingDate || new Date().toISOString().split('T')[0]
      })

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error getting trial balance:', error)
    return []
  }
}

export async function getProfitLoss(companyCode: string, fromDate?: string, toDate?: string, userContext?: { userId: string, role: string }) {
  return []
}

export async function getChartOfAccounts(companyCode: string, filters?: any, userContext?: { userId: string, role: string }) {
  return { accounts: [], grouped: {} }
}

export async function createAccount(payload: any, userId: string) {
  return { id: '1', ...payload }
}

export async function updateAccount(accountId: string, payload: any, userId: string) {
  return { id: accountId, ...payload }
}

export async function deleteAccount(accountId: string) {
  return { success: true }
}
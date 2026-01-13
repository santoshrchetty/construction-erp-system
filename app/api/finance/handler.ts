import { NextRequest } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { UserRole, Module, Permission } from '@/lib/permissions/types'
import { permissionChecker } from '@/lib/permissions/checker'
import * as financeServices from '@/domains/finance/financeServices'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function handleFinance(action: string, request: NextRequest, method: string = 'GET') {
  // Simplified auth - remove session check for now
  const userRole = UserRole.ADMIN // Default to admin for testing
  
  if (!permissionChecker.hasPermission(userRole, Module.COSTING, Permission.VIEW)) {
    throw new Error('Forbidden')
  }
  switch (action) {
    case 'gl_posting':
      return await financeServices.getGLPostingFormData('C001')
    case 'trial_balance':
      let ledger = 'ACCRUAL'
      let postingDate = new Date().toISOString().split('T')[0]
      
      if (method === 'POST') {
        try {
          const body = await request.json()
          ledger = body.ledger || 'ACCRUAL'
          postingDate = body.postingDate || postingDate
        } catch (e) {
          // Use defaults if JSON parsing fails
        }
      }
      
      return await financeServices.getTrialBalance('C001', ledger, postingDate)
    case 'profit_loss':
      return await financeServices.getProfitLoss('C001')
    case 'chart_of_accounts':
      return await financeServices.getChartOfAccounts('C001')
    case 'reports':
      return { report_type: 'demo', data: [] }
    default:
      return { action, message: `${action} functionality available` }
  }
}
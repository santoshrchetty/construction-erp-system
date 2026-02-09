import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'
import { getConsolidatedStockOverview, getMultiCompanyStockComparison } from '@/domains/currency/consolidationService'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action')
    
    const authContext = await withAuth(request)
    
    if (action === 'consolidated_stock') {
      const groupCode = searchParams.get('group_code')
      const reportingDate = searchParams.get('reporting_date')
      
      if (!groupCode) {
        return NextResponse.json({
          success: false,
          error: 'Group code required'
        }, { status: 400 })
      }
      
      const data = await getConsolidatedStockOverview(groupCode, reportingDate || undefined)
      
      return NextResponse.json({
        success: true,
        data
      })
    }
    
    if (action === 'multi_company_comparison') {
      const companyCodes = searchParams.get('company_codes')?.split(',') || []
      const reportingCurrency = searchParams.get('reporting_currency') || 'USD'
      const reportingDate = searchParams.get('reporting_date')
      
      if (companyCodes.length === 0) {
        return NextResponse.json({
          success: false,
          error: 'Company codes required'
        }, { status: 400 })
      }
      
      const data = await getMultiCompanyStockComparison(companyCodes, reportingCurrency, reportingDate || undefined)
      
      return NextResponse.json({
        success: true,
        data
      })
    }
    
    return NextResponse.json({
      success: false,
      error: 'Invalid action'
    }, { status: 400 })
    
  } catch (error) {
    if (error instanceof Error && (error.message === 'Unauthorized' || error.message === 'Forbidden')) {
      return NextResponse.json({ error: error.message }, { status: error.message === 'Unauthorized' ? 401 : 403 })
    }
    
    return NextResponse.json({
      error: 'Consolidation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { withAuth } from '@/lib/authMiddleware'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const body = await request.json()
    
    // Check if posting is allowed for the given date
    if (body.posting_date) {
      const postingDate = new Date(body.posting_date)
      const fiscalYear = postingDate.getFullYear().toString()
      const period = String(postingDate.getMonth() + 1).padStart(2, '0')
      
      const { data, error } = await supabase
        .from('period_controls')
        .select('posting_allowed')
        .eq('company_code', body.company_code)
        .eq('fiscal_year', fiscalYear)
        .eq('period', period)
        .eq('account_type', 'S')
        .single()
      
      if (error && error.code !== 'PGRST116') throw error
      
      const postingAllowed = data?.posting_allowed ?? true
      return NextResponse.json({ 
        success: true, 
        data: { posting_allowed: postingAllowed, fiscal_year: fiscalYear, period } 
      })
    }
    
    return NextResponse.json({ success: false, error: 'posting_date required' }, { status: 400 })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['PERIOD_CONTROLS_READ'])
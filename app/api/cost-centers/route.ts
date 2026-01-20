import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const companyId = searchParams.get('companyId')
    
    let query = supabase
      .from('cost_centers')
      .select('id, cost_center_code, cost_center_name, company_code')
      .eq('is_active', true)
      .order('cost_center_code')
    
    if (companyId) {
      const { data: company } = await supabase
        .from('company_codes')
        .select('company_code')
        .eq('id', companyId)
        .single()
      
      if (company) {
        query = query.eq('company_code', company.company_code)
      }
    }
    
    const { data, error } = await query
    
    if (error) throw error
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    
    // Filter parameters
    const status = searchParams.get('status')
    const requestType = searchParams.get('request_type')
    const projectCode = searchParams.get('project_code')
    const dateFrom = searchParams.get('date_from')
    const dateTo = searchParams.get('date_to')
    const requestNumber = searchParams.get('request_number')
    const materialCode = searchParams.get('material_code')
    
    // Get tenant from auth
    const authHeader = request.headers.get('authorization')
    const token = authHeader?.replace('Bearer ', '')
    
    let tenantId: string | undefined
    if (token) {
      const { data: { user } } = await supabase.auth.getUser(token)
      if (user) {
        const { data: profile } = await supabase
          .from('users')
          .select('tenant_id')
          .eq('id', user.id)
          .single()
        tenantId = profile?.tenant_id
      }
    }
    
    let query = supabase
      .from('material_requests')
      .select(`
        id,
        request_number,
        request_type,
        status,
        priority,
        project_code,
        wbs_element,
        wbs_id,
        company_code,
        plant_code,
        cost_center,
        created_at,
        created_by,
        material_request_items(
          id,
          line_number,
          material_code,
          material_name,
          description,
          requested_quantity,
          base_uom,
          estimated_price,
          currency_code,
          delivery_date,
          storage_location,
          priority,
          required_date
        )
      `)
      .order('created_at', { ascending: false })

    if (tenantId) {
      query = query.eq('tenant_id', tenantId)
    }

    // Apply filters
    if (status) query = query.eq('status', status)
    if (requestType) query = query.eq('request_type', requestType)
    if (projectCode) query = query.eq('project_code', projectCode)
    if (requestNumber) query = query.ilike('request_number', `%${requestNumber}%`)
    if (dateFrom) query = query.gte('created_at', dateFrom)
    if (dateTo) query = query.lte('created_at', dateTo)

    const { data, error } = await query

    if (error) throw error
    
    // Flatten data to show each line item as a row
    const flattenedData = data?.flatMap(request => 
      request.material_request_items.map(item => ({
        ...request,
        ...item,
        request_id: request.id,
        item_id: item.id
      }))
    ) || []
    
    // Apply material code filter on flattened data
    const filteredData = materialCode 
      ? flattenedData.filter(row => row.material_code?.includes(materialCode))
      : flattenedData

    return NextResponse.json({ success: true, data: filteredData })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}
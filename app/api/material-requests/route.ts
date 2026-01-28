import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { withAuth } from '@/lib/authMiddleware'

export const GET = withAuth(async (request: NextRequest, context) => {
  try {
    const supabase = await createServiceClient()
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    
    if (id) {
      // Get single request with items
      const { data: request, error: requestError } = await supabase
        .from('material_requests')
        .select('*')
        .eq('id', id)
        .single()
      
      if (requestError) throw requestError
      
      // Get project details
      const { data: project } = await supabase
        .from('projects')
        .select('project_code, name')
        .eq('project_code', request.project_code)
        .single()
      
      // Format display fields
      const formattedRequest = {
        ...request,
        project_display: project ? `${project.project_code} - ${project.name}` : request.project_code
      }
      
      const { data: items, error: itemsError } = await supabase
        .from('material_request_items')
        .select('*')
        .eq('material_request_id', id)
        .order('line_number')
      
      if (itemsError) throw itemsError
      
      return NextResponse.json({ 
        success: true, 
        data: { ...formattedRequest, items: items || [] }
      })
    }
    
    // Get all requests for user
    const { data, error } = await supabase
      .from('material_requests')
      .select('*')
      .eq('requested_by', context.user.id)
      .order('created_at', { ascending: false })
    
    if (error) throw error
    return NextResponse.json({ success: true, data })
    
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MATERIAL_REQUEST_READ'])

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const supabase = await createServiceClient()
    const body = await request.json()
    
    // Generate request number from number range
    const { data: numberData, error: numberError } = await supabase.rpc('get_next_number', {
      p_company_code: body.company_code,
      p_document_type: 'MR',
      p_fiscal_year: new Date().getFullYear().toString()
    })
    
    if (numberError) throw numberError
    const requestNumber = numberData
    
    const requestData = {
      request_number: requestNumber,
      company_code: body.company_code,
      plant_code: body.plant_code,
      project_code: body.project_code,
      cost_center: body.cost_center,
      wbs_element: body.wbs_element,
      requested_by: context.user.id,
      request_date: new Date().toISOString().split('T')[0],
      required_date: body.required_date,
      status: 'draft',
      priority: body.priority || 3,
      justification: body.justification,
      total_estimated_cost: body.total_estimated_cost || 0
    }

    const { data: newRequest, error: requestError } = await supabase
      .from('material_requests')
      .insert(requestData)
      .select()
      .single()

    if (requestError) throw requestError

    // Insert items
    if (body.items && body.items.length > 0) {
      const itemsData = body.items.map((item: any, index: number) => ({
        material_request_id: newRequest.id,
        line_number: index + 1,
        material_code: item.material_code,
        description: item.description,
        quantity: item.quantity,
        unit: item.unit,
        estimated_unit_cost: item.estimated_unit_cost || 0,
        estimated_total_cost: item.estimated_total_cost || 0,
        urgency_level: item.urgency_level || 3
      }))

      const { error: itemsError } = await supabase
        .from('material_request_items')
        .insert(itemsData)

      if (itemsError) throw itemsError
    }

    return NextResponse.json({ success: true, data: newRequest })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MATERIAL_REQUEST_WRITE'])

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const supabase = await createServiceClient()
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    const body = await request.json()
    
    if (!id) {
      return NextResponse.json({ success: false, error: 'Request ID required' }, { status: 400 })
    }

    const updateData = {
      company_code: body.company_code,
      plant_code: body.plant_code,
      project_code: body.project_code,
      cost_center: body.cost_center,
      wbs_element: body.wbs_element,
      required_date: body.required_date,
      priority: body.priority,
      justification: body.justification,
      total_estimated_cost: body.total_estimated_cost || 0
    }

    const { data, error } = await supabase
      .from('material_requests')
      .update(updateData)
      .eq('id', id)
      .eq('requested_by', context.user.id)
      .select()
      .single()

    if (error) throw error
    return NextResponse.json({ success: true, data })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MATERIAL_REQUEST_WRITE'])
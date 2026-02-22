import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const resource = searchParams.get('resource')
    const id = searchParams.get('id')
    
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    switch (resource) {
      case 'drawings':
        if (id) {
          const { data, error } = await supabase
            .from('drawings')
            .select('*')
            .eq('drawing_id', id)
            .single()
          return NextResponse.json({ success: !error, data, error: error?.message })
        }
        const { data, error } = await supabase
          .from('drawings')
          .select('*')
          .order('created_at', { ascending: false })
        return NextResponse.json({ success: !error, data, error: error?.message })

      case 'contracts':
        if (id) {
          const { data, error } = await supabase
            .from('contracts')
            .select('*')
            .eq('contract_id', id)
            .single()
          return NextResponse.json({ success: !error, data, error: error?.message })
        }
        const { data: contracts, error: contractsError } = await supabase
          .from('contracts')
          .select('*')
          .order('created_at', { ascending: false })
        return NextResponse.json({ success: !contractsError, data: contracts, error: contractsError?.message })

      case 'rfis':
        if (id) {
          const { data, error } = await supabase
            .from('rfis')
            .select('*')
            .eq('rfi_id', id)
            .single()
          return NextResponse.json({ success: !error, data, error: error?.message })
        }
        const { data: rfis, error: rfisError } = await supabase
          .from('rfis')
          .select('*')
          .order('created_at', { ascending: false })
        return NextResponse.json({ success: !rfisError, data: rfis, error: rfisError?.message })

      case 'specifications':
        const { data: specs, error: specsError } = await supabase
          .from('specifications')
          .select('*')
          .order('created_at', { ascending: false })
        return NextResponse.json({ success: !specsError, data: specs, error: specsError?.message })

      case 'submittals':
        const { data: submittals, error: submittalsError } = await supabase
          .from('submittals')
          .select('*')
          .order('created_at', { ascending: false })
        return NextResponse.json({ success: !submittalsError, data: submittals, error: submittalsError?.message })

      case 'change-orders':
        const { data: changeOrders, error: changeOrdersError } = await supabase
          .from('change_orders')
          .select('*')
          .order('created_at', { ascending: false })
        return NextResponse.json({ success: !changeOrdersError, data: changeOrders, error: changeOrdersError?.message })

      case 'master-data':
        const { data: masterData, error: masterDataError } = await supabase
          .from('master_data_documents')
          .select('*')
          .order('created_at', { ascending: false })
        return NextResponse.json({ success: !masterDataError, data: masterData, error: masterDataError?.message })

      default:
        return NextResponse.json({ error: 'Invalid resource' }, { status: 400 })
    }
  } catch (error) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const resource = searchParams.get('resource')
    const body = await request.json()
    
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { data: profile } = await supabase
      .from('users')
      .select('tenant_id')
      .eq('id', user.id)
      .single()

    const tenant_id = profile?.tenant_id

    switch (resource) {
      case 'drawings':
        const { data: drawing, error: drawingError } = await supabase
          .from('drawings')
          .insert({ ...body, tenant_id, created_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !drawingError, data: drawing, error: drawingError?.message })

      case 'contracts':
        const { data: contract, error: contractError } = await supabase
          .from('contracts')
          .insert({ ...body, tenant_id, created_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !contractError, data: contract, error: contractError?.message })

      case 'rfis':
        const { data: rfi, error: rfiError } = await supabase
          .from('rfis')
          .insert({ ...body, tenant_id, created_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !rfiError, data: rfi, error: rfiError?.message })

      case 'rfi-responses':
        const { data: response, error: responseError } = await supabase
          .from('rfi_responses')
          .insert({ ...body, tenant_id, responded_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !responseError, data: response, error: responseError?.message })

      case 'specifications':
        const { data: spec, error: specError } = await supabase
          .from('specifications')
          .insert({ ...body, tenant_id, created_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !specError, data: spec, error: specError?.message })

      case 'submittals':
        const { data: submittal, error: submittalError } = await supabase
          .from('submittals')
          .insert({ ...body, tenant_id, created_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !submittalError, data: submittal, error: submittalError?.message })

      case 'change-orders':
        const { data: changeOrder, error: changeOrderError } = await supabase
          .from('change_orders')
          .insert({ ...body, tenant_id, created_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !changeOrderError, data: changeOrder, error: changeOrderError?.message })

      case 'master-data':
        const { data: masterDoc, error: masterDocError } = await supabase
          .from('master_data_documents')
          .insert({ ...body, tenant_id, created_by: user.id })
          .select()
          .single()
        return NextResponse.json({ success: !masterDocError, data: masterDoc, error: masterDocError?.message })

      default:
        return NextResponse.json({ error: 'Invalid resource' }, { status: 400 })
    }
  } catch (error) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const resource = searchParams.get('resource')
    const id = searchParams.get('id')
    const body = await request.json()
    
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    if (!id) {
      return NextResponse.json({ error: 'ID required' }, { status: 400 })
    }

    switch (resource) {
      case 'drawings':
        const { data: drawing, error: drawingError } = await supabase
          .from('drawings')
          .update({ ...body, modified_by: user.id })
          .eq('drawing_id', id)
          .select()
          .single()
        return NextResponse.json({ success: !drawingError, data: drawing, error: drawingError?.message })

      case 'contracts':
        const { data: contract, error: contractError } = await supabase
          .from('contracts')
          .update({ ...body, modified_by: user.id })
          .eq('contract_id', id)
          .select()
          .single()
        return NextResponse.json({ success: !contractError, data: contract, error: contractError?.message })

      case 'rfis':
        const { data: rfi, error: rfiError } = await supabase
          .from('rfis')
          .update(body)
          .eq('rfi_id', id)
          .select()
          .single()
        return NextResponse.json({ success: !rfiError, data: rfi, error: rfiError?.message })

      case 'specifications':
        const { data: spec, error: specError } = await supabase
          .from('specifications')
          .update(body)
          .eq('spec_id', id)
          .select()
          .single()
        return NextResponse.json({ success: !specError, data: spec, error: specError?.message })

      case 'submittals':
        const { data: submittal, error: submittalError } = await supabase
          .from('submittals')
          .update(body)
          .eq('submittal_id', id)
          .select()
          .single()
        return NextResponse.json({ success: !submittalError, data: submittal, error: submittalError?.message })

      case 'change-orders':
        const { data: changeOrder, error: changeOrderError } = await supabase
          .from('change_orders')
          .update(body)
          .eq('change_order_id', id)
          .select()
          .single()
        return NextResponse.json({ success: !changeOrderError, data: changeOrder, error: changeOrderError?.message })

      default:
        return NextResponse.json({ error: 'Invalid resource' }, { status: 400 })
    }
  } catch (error) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const resource = searchParams.get('resource')
    const id = searchParams.get('id')
    
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    if (!id) {
      return NextResponse.json({ error: 'ID required' }, { status: 400 })
    }

    switch (resource) {
      case 'drawings':
        const { error: drawingError } = await supabase
          .from('drawings')
          .delete()
          .eq('drawing_id', id)
        return NextResponse.json({ success: !drawingError, error: drawingError?.message })

      case 'contracts':
        const { error: contractError } = await supabase
          .from('contracts')
          .delete()
          .eq('contract_id', id)
        return NextResponse.json({ success: !contractError, error: contractError?.message })

      case 'rfis':
        const { error: rfiError } = await supabase
          .from('rfis')
          .delete()
          .eq('rfi_id', id)
        return NextResponse.json({ success: !rfiError, error: rfiError?.message })

      default:
        return NextResponse.json({ error: 'Invalid resource' }, { status: 400 })
    }
  } catch (error) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

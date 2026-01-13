import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { withAuth } from '@/lib/authMiddleware'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export const GET = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const company = searchParams.get('company') || 'C001'
    const id = searchParams.get('id')
    const search = searchParams.get('search')
    
    let query = supabase
      .from('material_master')
      .select('*')
      .eq('company_code', company)
      .eq('is_active', true)
    
    if (id) {
      query = query.eq('material_code', id)
      const { data, error } = await query.single()
      if (error) throw error
      return NextResponse.json({ success: true, data })
    }
    
    if (search) {
      query = query.ilike('material_name', `%${search}%`)
    }
    
    const { data, error } = await query.order('material_name').limit(50)
    if (error) throw error
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MATERIAL_MASTER_READ'])

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const body = await request.json()
    
    const materialData = {
      material_code: body.material_code,
      material_name: body.material_name,
      material_group: body.material_group,
      hsn_sac_code: body.hsn_sac_code,
      gst_rate: body.gst_rate || 18,
      is_capital_goods: body.is_capital_goods || false,
      company_code: body.company_code || 'C001',
      is_active: true
    }

    const { data, error } = await supabase
      .from('material_master')
      .insert(materialData)
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
}, ['MATERIAL_MASTER_WRITE'])

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    const body = await request.json()
    
    if (!id) {
      return NextResponse.json({ success: false, error: 'Material code required' }, { status: 400 })
    }

    const { data, error } = await supabase
      .from('material_master')
      .update({
        material_name: body.material_name,
        material_group: body.material_group,
        hsn_sac_code: body.hsn_sac_code,
        gst_rate: body.gst_rate,
        is_capital_goods: body.is_capital_goods
      })
      .eq('material_code', id)
      .eq('company_code', body.company_code)
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
}, ['MATERIAL_MASTER_WRITE'])

export const DELETE = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    const company = searchParams.get('company')
    
    if (!id) {
      return NextResponse.json({ success: false, error: 'Material code required' }, { status: 400 })
    }

    const { data, error } = await supabase
      .from('material_master')
      .update({ is_active: false })
      .eq('material_code', id)
      .eq('company_code', company)
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
}, ['MATERIAL_MASTER_WRITE'])
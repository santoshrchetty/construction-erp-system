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
    const id = searchParams.get('id')
    const search = searchParams.get('search')
    const plantId = searchParams.get('plantId')
    const plantCode = searchParams.get('plantCode')
    const storageLocationId = searchParams.get('storageLocationId')
    const storageLocation = searchParams.get('storageLocation')
    const withStock = searchParams.get('withStock') === 'true'
    const limit = parseInt(searchParams.get('limit') || '50')
    
    // Single material lookup
    if (id) {
      const { data, error } = await supabase
        .from('material_master_view')
        .select('*')
        .eq('material_code', id)
        .eq('is_active', true)
        .single()
      if (error) throw error
      return NextResponse.json({ success: true, data })
    }
    
    // Search with optional stock info
    if (withStock) {
      // Simple query without complex nested joins
      let query = supabase
        .from('materials')
        .select('id, material_code, material_name, description, base_uom, material_group, category')
        .eq('is_active', true)
      
      if (search) {
        query = query.or(`material_code.ilike.%${search}%,material_name.ilike.%${search}%`)
      }
      
      const { data, error } = await query.limit(limit)
      if (error) {
        console.error('Materials query error:', error)
        throw error
      }
      
      return NextResponse.json({ success: true, data: data || [] })
    }
    
    // Simple search from view
    let query = supabase
      .from('material_master_view')
      .select('*')
      .eq('is_active', true)
    
    if (search) {
      query = query.or(`material_code.ilike.%${search}%,material_name.ilike.%${search}%`)
    }
    
    const { data, error } = await query.order('material_name').limit(limit)
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
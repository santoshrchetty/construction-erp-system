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
    
    // Check if vendors table exists, fallback to suppliers
    let query = supabase
      .from('vendors')
      .select('vendor_code as supplier_code, vendor_name as supplier_name, state, gstin')
      .eq('is_active', true)
    
    if (id) {
      query = query.eq('vendor_code', id)
      const { data, error } = await query.single()
      if (error) {
        // Fallback to suppliers table
        const fallbackQuery = supabase
          .from('suppliers')
          .select('*')
          .eq('supplier_code', id)
          .eq('company_code', company)
          .eq('is_active', true)
          .single()
        const { data: fallbackData, error: fallbackError } = await fallbackQuery
        if (fallbackError) throw fallbackError
        return NextResponse.json({ success: true, data: fallbackData })
      }
      return NextResponse.json({ success: true, data })
    }
    
    if (search) {
      query = query.ilike('vendor_name', `%${search}%`)
    }
    
    const { data, error } = await query.order('vendor_name').limit(50)
    if (error) {
      // Fallback to suppliers table
      let fallbackQuery = supabase
        .from('suppliers')
        .select('*')
        .eq('company_code', company)
        .eq('is_active', true)
      
      if (search) {
        fallbackQuery = fallbackQuery.ilike('supplier_name', `%${search}%`)
      }
      
      const { data: fallbackData, error: fallbackError } = await fallbackQuery.order('supplier_name').limit(50)
      if (fallbackError) throw fallbackError
      return NextResponse.json({ success: true, data: fallbackData })
    }
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['SUPPLIER_MASTER_READ'])

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const body = await request.json()
    
    const supplierData = {
      supplier_code: body.supplier_code,
      supplier_name: body.supplier_name,
      state_code: body.state_code,
      gstin: body.gstin,
      company_code: body.company_code || 'C001',
      is_active: true
    }

    const { data, error } = await supabase
      .from('suppliers')
      .insert(supplierData)
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
}, ['SUPPLIER_MASTER_WRITE'])

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    const body = await request.json()
    
    if (!id) {
      return NextResponse.json({ success: false, error: 'Supplier code required' }, { status: 400 })
    }

    const { data, error } = await supabase
      .from('suppliers')
      .update({
        supplier_name: body.supplier_name,
        state_code: body.state_code,
        gstin: body.gstin
      })
      .eq('supplier_code', id)
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
}, ['SUPPLIER_MASTER_WRITE'])

export const DELETE = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    const company = searchParams.get('company')
    
    if (!id) {
      return NextResponse.json({ success: false, error: 'Supplier code required' }, { status: 400 })
    }

    const { data, error } = await supabase
      .from('suppliers')
      .update({ is_active: false })
      .eq('supplier_code', id)
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
}, ['SUPPLIER_MASTER_WRITE'])
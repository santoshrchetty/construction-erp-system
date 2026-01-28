import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const category = searchParams.get('category')
    
    if (category !== 'erp-config') {
      return NextResponse.json({ success: false, error: 'Invalid category' }, { status: 400 })
    }

    // Authentication only - authorization handled at tile level
    const authContext = await withAuth(request)

    const supabase = await createServiceClient()

    const [mgRes, vcRes, ptRes, uomRes, msRes, valRes, mtRes, glRes, ccRes, plantRes, slRes, akRes, adRes] = await Promise.all([
      supabase.from('material_groups').select('*').order('group_code'),
      supabase.from('vendor_categories').select('*').order('category_code'),
      supabase.from('payment_terms').select('*').order('term_code'),
      supabase.from('uom_groups').select('*').order('base_uom'),
      supabase.from('material_status').select('*').order('status_code'),
      supabase.from('valuation_classes').select('*').order('class_code'),
      supabase.from('movement_types').select('*').order('movement_type'),
      supabase.from('chart_of_accounts').select('*').order('account_code'),
      supabase.from('company_codes').select('*').order('company_code'),
      supabase.from('plants').select('*').order('plant_code'),
      supabase.from('storage_locations').select('*').order('sloc_code'),
      supabase.from('account_keys').select('*').order('account_key_code'),
      supabase.from('account_determination').select('*')
    ])

    console.log('Account Determination API Result:', adRes) // Debug log

    return NextResponse.json({
      success: true,
      data: {
        material_groups: mgRes.data || [],
        vendor_categories: vcRes.data || [],
        payment_terms: ptRes.data || [],
        uom_groups: uomRes.data || [],
        material_status: msRes.data || [],
        valuation_classes: valRes.data || [],
        movement_types: mtRes.data || [],
        chart_of_accounts: glRes.data || [],
        company_codes: ccRes.data || [],
        plants: plantRes.data || [],
        storage_locations: slRes.data || [],
        account_keys: akRes.data || [],
        account_determination: adRes.data || []
      }
    })

  } catch (error) {
    console.error('ERP Config API Error:', error)
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const entity = searchParams.get('entity')
    const body = await request.json()

    const supabase = await createServiceClient()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 })
    }

    const tableMap: Record<string, string> = {
      groups: 'material_groups',
      categories: 'vendor_categories',
      terms: 'payment_terms'
    }

    const table = tableMap[entity || '']
    if (!table) {
      return NextResponse.json({ success: false, error: 'Invalid entity' }, { status: 400 })
    }

    let insertData: any = {}
    if (entity === 'groups') {
      insertData = {
        group_code: body.code,
        group_name: body.name,
        description: body.description
      }
    } else if (entity === 'categories') {
      insertData = {
        category_code: body.code,
        category_name: body.name,
        description: body.description
      }
    } else if (entity === 'terms') {
      insertData = {
        term_code: body.code,
        term_name: body.name,
        days: body.days,
        description: body.description
      }
    }

    const { error } = await supabase.from(table).insert([insertData])
    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Create error:', error)
    return NextResponse.json({ success: false, error: 'Failed to create item' }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const entity = searchParams.get('entity')
    const body = await request.json()

    const supabase = await createServiceClient()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 })
    }

    const tableMap: Record<string, string> = {
      groups: 'material_groups',
      categories: 'vendor_categories',
      terms: 'payment_terms'
    }

    const table = tableMap[entity || '']
    if (!table) {
      return NextResponse.json({ success: false, error: 'Invalid entity' }, { status: 400 })
    }

    let updateData: any = {}
    if (entity === 'groups') {
      updateData = {
        group_code: body.code,
        group_name: body.name,
        description: body.description
      }
    } else if (entity === 'categories') {
      updateData = {
        category_code: body.code,
        category_name: body.name,
        description: body.description
      }
    } else if (entity === 'terms') {
      updateData = {
        term_code: body.code,
        term_name: body.name,
        days: body.days,
        description: body.description
      }
    }

    const { error } = await supabase.from(table).update(updateData).eq('id', body.id)
    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Update error:', error)
    return NextResponse.json({ success: false, error: 'Failed to update item' }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const entity = searchParams.get('entity')
    const id = searchParams.get('id')

    const supabase = await createServiceClient()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 })
    }

    const tableMap: Record<string, string> = {
      groups: 'material_groups',
      categories: 'vendor_categories',
      terms: 'payment_terms'
    }

    const table = tableMap[entity || '']
    if (!table || !id) {
      return NextResponse.json({ success: false, error: 'Invalid entity or ID' }, { status: 400 })
    }

    const { error } = await supabase.from(table).delete().eq('id', id)
    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Delete error:', error)
    return NextResponse.json({ success: false, error: 'Failed to delete item' }, { status: 500 })
  }
}
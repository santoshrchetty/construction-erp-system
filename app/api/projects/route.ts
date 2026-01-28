import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { handleProjects } from './handler'

export async function GET(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const companyCode = url.searchParams.get('companyCode')
    const id = url.searchParams.get('id')
    
    if (action) {
      const result = await handleProjects(action, { companyCode, id }, 'GET')
      return NextResponse.json({ success: true, data: result })
    }
    
    const supabase = await createServiceClient()
    let query = supabase
      .from('projects')
      .select('id, project_code, name, status, company_code')
      .order('created_at', { ascending: false })
    
    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }

    const { data, error } = await query

    if (error) throw error

    return NextResponse.json({ success: true, data: data || [] })
  } catch (error) {
    console.error('Projects API error:', error)
    return NextResponse.json({ success: false, error: 'Failed to fetch projects' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const body = await request.json()
    
    if (action) {
      const result = await handleProjects(action, body, 'POST')
      return NextResponse.json({ success: true, data: result })
    }

    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('projects')
      .insert(body)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error('Projects API error:', error)
    return NextResponse.json({ success: false, error: 'Failed to process request' }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const body = await request.json()
    
    if (action) {
      const result = await handleProjects(action, body, 'PUT')
      return NextResponse.json({ success: true, data: result })
    }

    return NextResponse.json({ success: false, error: 'Action required' }, { status: 400 })
  } catch (error) {
    console.error('Projects API error:', error)
    return NextResponse.json({ success: false, error: 'Failed to update' }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const id = url.searchParams.get('id')
    
    if (action) {
      const result = await handleProjects(action, { id }, 'DELETE')
      return NextResponse.json({ success: true, data: result })
    }

    return NextResponse.json({ success: false, error: 'Action required' }, { status: 400 })
  } catch (error) {
    console.error('Projects API error:', error)
    return NextResponse.json({ success: false, error: 'Failed to delete' }, { status: 500 })
  }
}
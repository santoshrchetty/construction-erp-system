import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function GET() {
  try {
    const supabase = await createServiceClient()
    
    const [objectsRes, roleAuthsRes, rolesRes] = await Promise.all([
      supabase.from('authorization_objects').select('*, authorization_fields(*)'),
      supabase.from('role_authorization_assignments').select('*'),
      supabase.from('roles').select('id, name')
    ])

    return NextResponse.json({
      success: true,
      data: {
        objects: objectsRes.data || [],
        roleAuths: roleAuthsRes.data || [],
        roles: rolesRes.data || []
      }
    })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('authorization_objects')
      .insert(body)
      .select()
      .single()
    
    if (error) throw error
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    const { id, ...updates } = body
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('authorization_objects')
      .update(updates)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const body = await request.json()
    const supabase = await createServiceClient()
    
    const { error } = await supabase
      .from('authorization_objects')
      .delete()
      .eq('id', body.id)
    
    if (error) throw error
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

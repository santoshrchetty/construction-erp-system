import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('authorization_fields')
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
      .from('authorization_fields')
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
      .from('authorization_fields')
      .delete()
      .eq('id', body.id)
    
    if (error) throw error
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { withAuth } from '@/lib/authMiddleware'

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ error: 'Tenant ID required' }, { status: 400 })
    }

    const body = await request.json()
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('authorization_object_fields')
      .insert({
        ...body,
        tenant_id: tenantId
      })
      .select()
      .single()
    
    if (error) throw error
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
})

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ error: 'Tenant ID required' }, { status: 400 })
    }

    const body = await request.json()
    const { id, ...updates } = body
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('authorization_object_fields')
      .update(updates)
      .eq('id', id)
      .eq('tenant_id', tenantId)
      .select()
      .single()
    
    if (error) throw error
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
})

export const DELETE = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ error: 'Tenant ID required' }, { status: 400 })
    }

    const body = await request.json()
    const supabase = await createServiceClient()
    
    const { error } = await supabase
      .from('authorization_object_fields')
      .delete()
      .eq('id', body.id)
      .eq('tenant_id', tenantId)
    
    if (error) throw error
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
})

import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { withAuth } from '@/lib/authMiddleware'

export const GET = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    
    if (!tenantId) {
      return NextResponse.json({ 
        success: false,
        error: 'Tenant ID required' 
      }, { status: 400 })
    }
    
    const supabase = await createServiceClient()
    
    const [objectsRes, roleAuthsRes, rolesRes] = await Promise.all([
      supabase
        .from('authorization_objects')
        .select(`
          *,
          fields:authorization_fields(*)
        `)
        .eq('tenant_id', tenantId),
      supabase
        .from('role_authorization_objects')
        .select('*, roles(name)')
        .eq('tenant_id', tenantId),
      supabase
        .from('roles')
        .select('id, name')
        .eq('tenant_id', tenantId)
    ])

    // Transform roleAuths to include role_name at top level
    const roleAuthsWithNames = (roleAuthsRes.data || []).map(auth => ({
      ...auth,
      role_name: auth.roles?.name || 'Unknown Role'
    }))

    if (objectsRes.error) throw objectsRes.error
    if (roleAuthsRes.error) throw roleAuthsRes.error
    if (rolesRes.error) throw rolesRes.error

    return NextResponse.json({
      success: true,
      data: {
        objects: objectsRes.data || [],
        roleAuths: roleAuthsWithNames,
        roles: rolesRes.data || []
      }
    })
  } catch (error) {
    console.error('Authorization objects GET error:', error)
    return NextResponse.json({ 
      success: false,
      error: error.message 
    }, { status: 500 })
  }
})

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    
    if (!tenantId) {
      return NextResponse.json({ 
        success: false,
        error: 'Tenant ID required' 
      }, { status: 400 })
    }
    
    const body = await request.json()
    const supabase = await createServiceClient()
    
    const dataWithTenant = {
      ...body,
      tenant_id: tenantId
    }
    
    const { data, error } = await supabase
      .from('authorization_objects')
      .insert(dataWithTenant)
      .select()
      .single()
    
    if (error) throw error
    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error('Authorization objects POST error:', error)
    return NextResponse.json({ 
      success: false,
      error: error.message 
    }, { status: 500 })
  }
})

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    
    if (!tenantId) {
      return NextResponse.json({ 
        success: false,
        error: 'Tenant ID required' 
      }, { status: 400 })
    }
    
    const body = await request.json()
    const { id, ...updates } = body
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('authorization_objects')
      .update(updates)
      .eq('id', id)
      .eq('tenant_id', tenantId)
      .select()
      .single()
    
    if (error) throw error
    
    if (!data) {
      return NextResponse.json({ 
        success: false,
        error: 'Object not found or access denied' 
      }, { status: 404 })
    }
    
    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error('Authorization objects PUT error:', error)
    return NextResponse.json({ 
      success: false,
      error: error.message 
    }, { status: 500 })
  }
})

export const DELETE = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    
    if (!tenantId) {
      return NextResponse.json({ 
        success: false,
        error: 'Tenant ID required' 
      }, { status: 400 })
    }
    
    const body = await request.json()
    const supabase = await createServiceClient()
    
    const { error } = await supabase
      .from('authorization_objects')
      .delete()
      .eq('id', body.id)
      .eq('tenant_id', tenantId)
    
    if (error) throw error
    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Authorization objects DELETE error:', error)
    return NextResponse.json({ 
      success: false,
      error: error.message 
    }, { status: 500 })
  }
})

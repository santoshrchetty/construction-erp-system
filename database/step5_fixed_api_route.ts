import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { withAuth } from '@/lib/authMiddleware'

// GET - Fetch authorization objects with tenant isolation
export const GET = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    
    // Validate tenant ID
    if (!tenantId) {
      return NextResponse.json({ 
        success: false,
        error: 'Tenant ID required' 
      }, { status: 400 })
    }
    
    const supabase = await createServiceClient()
    
    // Fetch data with tenant filtering
    const [objectsRes, roleAuthsRes, rolesRes] = await Promise.all([
      supabase
        .from('authorization_objects')
        .select('*, authorization_fields(*)')
        .eq('tenant_id', tenantId),  // ✅ Tenant filter
        
      supabase
        .from('role_authorization_objects')
        .select('*')
        .eq('tenant_id', tenantId),  // ✅ Tenant filter
        
      supabase
        .from('roles')
        .select('id, name')
        .eq('tenant_id', tenantId)   // ✅ Tenant filter
    ])

    // Check for errors
    if (objectsRes.error) throw objectsRes.error
    if (roleAuthsRes.error) throw roleAuthsRes.error
    if (rolesRes.error) throw rolesRes.error

    return NextResponse.json({
      success: true,
      data: {
        objects: objectsRes.data || [],
        roleAuths: roleAuthsRes.data || [],
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

// POST - Create authorization object with tenant isolation
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
    
    // Add tenant_id to the data
    const dataWithTenant = {
      ...body,
      tenant_id: tenantId  // ✅ Force tenant ID
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

// PUT - Update authorization object with tenant isolation
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
    
    // Update only if belongs to tenant
    const { data, error } = await supabase
      .from('authorization_objects')
      .update(updates)
      .eq('id', id)
      .eq('tenant_id', tenantId)  // ✅ Tenant filter
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

// DELETE - Delete authorization object with tenant isolation
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
    
    // Delete only if belongs to tenant
    const { error } = await supabase
      .from('authorization_objects')
      .delete()
      .eq('id', body.id)
      .eq('tenant_id', tenantId)  // ✅ Tenant filter
    
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

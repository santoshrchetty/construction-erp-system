import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function GET(request: NextRequest) {
  try {
    const cookieStore = cookies()
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
      {
        cookies: {
          get(name: string) {
            return cookieStore.get(name)?.value
          },
        },
      }
    )
    
    // Get authorization objects
    const { data: objects, error: objectsError } = await supabase
      .from('authorization_objects')
      .select('*')
      .order('object_name')

    if (objectsError) {
      console.error('Database error:', objectsError)
      throw objectsError
    }

    // Get authorization fields
    const { data: fields, error: fieldsError } = await supabase
      .from('authorization_fields')
      .select('*')
      .order('field_name')

    if (fieldsError) {
      console.error('Fields error:', fieldsError)
    }

    // Get all roles first
    const { data: roles, error: rolesError } = await supabase
      .from('roles')
      .select('id, name')
      .order('name')

    if (rolesError) {
      console.error('Roles error:', rolesError)
    }

    // Get role authorization assignments
    const { data: roleAuths, error: roleAuthsError } = await supabase
      .from('role_authorization_objects')
      .select(`
        id,
        role_id,
        auth_object_id,
        field_values,
        valid_from,
        valid_to,
        is_active,
        module_full_access,
        object_full_access
      `)
      .eq('is_active', true)
      .order('created_at', { ascending: false })

    if (roleAuthsError) {
      console.error('Role auths error:', roleAuthsError)
    }

    // Transform authorization objects data
    const transformedObjects = objects?.map(obj => ({
      id: obj.id,
      object_name: obj.object_name,
      description: obj.description,
      module: obj.module,
      is_active: obj.is_active,
      fields: fields?.filter(f => f.auth_object_id === obj.id).map(field => ({
        id: field.id,
        field_name: field.field_name,
        field_description: field.field_description,
        field_values: field.field_values,
        is_required: field.is_required,
        is_organizational: ['BUKRS', 'WERKS', 'EKORG', 'LGORT', 'KOSTL'].includes(field.field_name)
      })) || []
    })) || []

    // Transform role authorization assignments
    const transformedRoleAuths = roleAuths?.map(auth => {
      const role = roles?.find(r => r.id === auth.role_id)
      return {
        id: auth.id,
        role_id: auth.role_id,
        role_name: role?.name || 'Unknown Role',
        auth_object_id: auth.auth_object_id,
        field_values: auth.field_values,
        valid_from: auth.valid_from,
        valid_to: auth.valid_to,
        is_active: auth.is_active,
        module_full_access: auth.module_full_access,
        object_full_access: auth.object_full_access
      }
    }) || []

    return NextResponse.json({
      success: true,
      data: {
        objects: transformedObjects,
        roleAuths: transformedRoleAuths,
        roles: roles || []
      }
    })
  } catch (error) {
    console.error('Authorization objects API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message 
    }, { status: 500 })
  }
}
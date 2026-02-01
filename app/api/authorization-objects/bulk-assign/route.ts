import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function POST(request: NextRequest) {
  try {
    const cookieStore = await cookies()
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
      {
        cookies: {
          getAll: () => cookieStore.getAll(),
          setAll: (cookiesToSet) => {
            cookiesToSet.forEach(({ name, value, options }) => cookieStore.set(name, value, options))
          },
        },
      }
    )

    const { roleId, objectIds, template, cascadeLevel, module } = await request.json()

    // Convert role name to role ID if needed
    let actualRoleId = roleId
    if (typeof roleId === 'string' && !roleId.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)) {
      // It's a role name, convert to ID
      const { data: roleData, error: roleError } = await supabase
        .from('roles')
        .select('id')
        .eq('name', roleId)
        .single()
      
      if (roleError || !roleData) {
        return NextResponse.json({ 
          success: false, 
          error: `Role '${roleId}' not found` 
        }, { status: 400 })
      }
      
      actualRoleId = roleData.id
    }

    // Use cascading function for module/object level assignments
    if (cascadeLevel === 'module' && module) {
      const { data, error } = await supabase.rpc('assign_cascading_authorization', {
        target_role_id: actualRoleId,
        target_module: module,
        target_object_id: null,
        access_level: template,
        cascade_level: cascadeLevel
      })

      if (error) {
        console.error('Cascading assignment error:', error)
        return NextResponse.json({ 
          success: false, 
          error: error.message 
        }, { status: 500 })
      }

      return NextResponse.json({
        success: true,
        message: `Successfully assigned ${data} objects with cascading to role`,
        cascaded: true
      })
    }

    // Use cascading function for single object assignments
    if (cascadeLevel === 'object' && objectIds.length === 1) {
      const { data, error } = await supabase.rpc('assign_cascading_authorization', {
        target_role_id: actualRoleId,
        target_module: null,
        target_object_id: objectIds[0],
        access_level: template,
        cascade_level: cascadeLevel
      })

      if (error) {
        console.error('Object cascading assignment error:', error)
        return NextResponse.json({ 
          success: false, 
          error: error.message 
        }, { status: 500 })
      }

      return NextResponse.json({
        success: true,
        message: `Successfully assigned object with cascading to role`,
        cascaded: true
      })
    }

    // Fallback to original field-level assignment
    let fieldValues: Record<string, string[]>
    
    switch (template) {
      case 'full_access':
        fieldValues = {
          "COMP_CODE": ["*"],
          "PLANT": ["*"], 
          "DEPT": ["*"],
          "ACTION": ["CREATE", "MODIFY", "DELETE", "REVIEW", "EXECUTE", "APPROVE"]
        }
        break
      case 'read_only':
        fieldValues = {
          "COMP_CODE": ["*"],
          "PLANT": ["*"],
          "DEPT": ["*"], 
          "ACTION": ["REVIEW"]
        }
        break
      default:
        fieldValues = {
          "COMP_CODE": ["1000"],
          "PLANT": ["P001"],
          "DEPT": ["ADMIN"],
          "ACTION": ["REVIEW"]
        }
    }

    // Bulk insert role authorization assignments
    const assignments = objectIds.map((objectId: string) => ({
      role_id: roleId,
      auth_object_id: objectId,
      field_values: fieldValues,
      is_active: true
    }))

    const { data, error } = await supabase
      .from('role_authorization_objects')
      .upsert(assignments, { 
        onConflict: 'role_id,auth_object_id',
        ignoreDuplicates: false 
      })

    if (error) {
      console.error('Bulk assignment error:', error)
      return NextResponse.json({ 
        success: false, 
        error: error.message 
      }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      message: `Successfully assigned ${objectIds.length} objects to role`,
      data
    })

  } catch (error) {
    console.error('Bulk assignment API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message 
    }, { status: 500 })
  }
}

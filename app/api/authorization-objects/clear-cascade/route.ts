import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function PUT(request: NextRequest) {
  try {
    const { roleId, module } = await request.json()
    
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

    // Get role UUID from role name
    const { data: roleData } = await supabase
      .from('roles')
      .select('id')
      .eq('name', roleId)
      .single()

    if (!roleData) {
      return NextResponse.json({ 
        success: false, 
        error: 'Role not found' 
      }, { status: 404 })
    }

    // Clear only cascade flags, preserve custom assignments
    const { error } = await supabase
      .from('role_authorization_objects')
      .update({
        module_full_access: false,
        object_full_access: false,
        inherited_from: null
      })
      .eq('role_id', roleData.id)
      .in('auth_object_id', 
        supabase
          .from('authorization_objects')
          .select('id')
          .eq('module', module)
      )

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Clear cascade error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message 
    }, { status: 500 })
  }
}
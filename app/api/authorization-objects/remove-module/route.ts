import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function DELETE(request: NextRequest) {
  try {
    const cookieStore = await cookies()
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

    const { roleId, module } = await request.json()

    // Convert role name to role ID if needed
    let actualRoleId = roleId
    if (typeof roleId === 'string' && !roleId.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)) {
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

    // Call the remove function
    const { data, error } = await supabase.rpc('remove_module_assignments', {
      target_role_id: actualRoleId,
      target_module: module
    })

    if (error) {
      console.error('Module removal error:', error)
      return NextResponse.json({ 
        success: false, 
        error: error.message 
      }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      message: `Successfully removed ${data} assignments from ${module} module`,
      removed: data
    })

  } catch (error) {
    console.error('Module removal API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message 
    }, { status: 500 })
  }
}

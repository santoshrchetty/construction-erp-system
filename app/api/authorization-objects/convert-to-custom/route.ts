import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function PUT(request: NextRequest) {
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

    const body = await request.json()
    console.log('Convert to custom request body:', body)
    const { assignmentId } = body

    if (!assignmentId) {
      console.error('Missing assignmentId')
      return NextResponse.json({ 
        success: false, 
        error: 'Assignment ID is required' 
      }, { status: 400 })
    }

    console.log('Converting assignment:', assignmentId)

    // Convert inherited assignment to custom template
    const { data, error } = await supabase
      .from('role_authorization_objects')
      .update({
        module_full_access: false,
        object_full_access: false,
        inherited_from: null
      })
      .eq('id', assignmentId)
      .select()

    if (error) {
      console.error('Supabase error:', error)
      return NextResponse.json({ 
        success: false, 
        error: `Database error: ${error.message}` 
      }, { status: 500 })
    }

    if (!data || data.length === 0) {
      console.error('No assignment found with ID:', assignmentId)
      return NextResponse.json({ 
        success: false, 
        error: 'Assignment not found' 
      }, { status: 404 })
    }

    console.log('Successfully converted assignment:', data[0])
    return NextResponse.json({
      success: true,
      message: 'Successfully converted to custom template',
      data: data[0]
    })

  } catch (error) {
    console.error('Convert to custom API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: `Server error: ${error.message}` 
    }, { status: 500 })
  }
}

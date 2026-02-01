import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function DELETE(request: NextRequest) {
  try {
    const { assignmentId } = await request.json()
    
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

    const { error } = await supabase
      .from('role_authorization_objects')
      .delete()
      .eq('id', assignmentId)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Remove assignment error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message 
    }, { status: 500 })
  }
}

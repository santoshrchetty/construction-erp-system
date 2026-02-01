import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function PUT(request: NextRequest) {
  try {
    const { assignmentId, fieldValues, cascadeLevel, template } = await request.json()
    
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

    let updateData: any = {}

    if (fieldValues) {
      updateData.field_values = fieldValues
    }

    if (cascadeLevel === 'object' && template === 'full_access') {
      // Get the assignment to find its fields
      const { data: assignment } = await supabase
        .from('role_authorization_objects')
        .select('auth_object_id')
        .eq('id', assignmentId)
        .single()

      if (assignment) {
        // Get all fields for this object
        const { data: fields } = await supabase
          .from('authorization_fields')
          .select('field_name')
          .eq('auth_object_id', assignment.auth_object_id)

        // Set all fields to full access
        const fullAccessValues: Record<string, string[]> = {}
        fields?.forEach(field => {
          fullAccessValues[field.field_name] = ['*']
        })

        updateData.field_values = fullAccessValues
        updateData.object_full_access = true
        updateData.inherited_from = 'object'
      }
    }

    const { error } = await supabase
      .from('role_authorization_objects')
      .update(updateData)
      .eq('id', assignmentId)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Update assignment error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message 
    }, { status: 500 })
  }
}

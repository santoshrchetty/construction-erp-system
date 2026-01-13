import { NextRequest, NextResponse } from 'next/server'
import { supabase } from '../../../../lib/supabase-simple'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const id = searchParams.get('id')

    switch (section) {
      case 'categories':
        if (id) {
          const { data, error } = await supabase
            .from('project_categories')
            .select('*')
            .eq('id', id)
            .single()
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        } else {
          const { data, error } = await supabase
            .from('project_categories')
            .select('*')
            .eq('company_code', 'C001')
            .order('sort_order')
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        }

      case 'gl-rules':
        if (id) {
          const { data, error } = await supabase
            .from('project_gl_determination')
            .select('*')
            .eq('id', id)
            .single()
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        } else {
          const { data, error } = await supabase
            .from('project_gl_determination')
            .select('*')
            .eq('is_active', true)
            .order('project_category')
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        }

      case 'numbering':
        const { data: numberingData, error: numberingError } = await supabase
          .from('project_numbering_rules')
          .select('*')
          .eq('is_active', true)
          .order('entity_type')
        
        if (numberingError) throw numberingError
        return NextResponse.json({ success: true, data: numberingData })

      case 'workflows':
        const { data: workflowData, error: workflowError } = await supabase
          .from('project_workflows')
          .select('*')
          .eq('is_active', true)
          .order('workflow_name')
        
        if (workflowError) throw workflowError
        return NextResponse.json({ success: true, data: workflowData })

      default:
        return NextResponse.json({ success: false, error: 'Invalid section' }, { status: 400 })
    }
  } catch (error) {
    console.error('GET Error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const body = await request.json()

    switch (section) {
      case 'categories':
        const categoryData = {
          category_code: body.category_code,
          category_name: body.category_name,
          posting_logic: body.posting_logic,
          real_time_posting: body.real_time_posting || false,
          company_code: body.company_code || 'C001',
          is_active: true,
          sort_order: body.sort_order || 999
        }

        const { data: categoryResult, error: categoryError } = await supabase
          .from('project_categories')
          .insert(categoryData)
          .select()
          .single()

        if (categoryError) throw categoryError
        return NextResponse.json({ success: true, data: categoryResult })

      case 'gl-rules':
        const ruleData = {
          project_category: body.project_category,
          event_type: body.event_type,
          gl_account_type: body.gl_account_type,
          debit_credit: body.debit_credit,
          posting_key: body.posting_key,
          is_active: true
        }

        const { data: ruleResult, error: ruleError } = await supabase
          .from('project_gl_determination')
          .insert(ruleData)
          .select()
          .single()

        if (ruleError) throw ruleError
        return NextResponse.json({ success: true, data: ruleResult })

      default:
        return NextResponse.json({ success: false, error: 'Invalid section' }, { status: 400 })
    }
  } catch (error) {
    console.error('POST Error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const id = searchParams.get('id')
    const body = await request.json()

    if (!id) {
      return NextResponse.json({ success: false, error: 'ID required for update' }, { status: 400 })
    }

    switch (section) {
      case 'categories':
        const { data: categoryResult, error: categoryError } = await supabase
          .from('project_categories')
          .update(body)
          .eq('id', id)
          .select()
          .single()

        if (categoryError) throw categoryError
        return NextResponse.json({ success: true, data: categoryResult })

      case 'gl-rules':
        const { data: ruleResult, error: ruleError } = await supabase
          .from('project_gl_determination')
          .update(body)
          .eq('id', id)
          .select()
          .single()

        if (ruleError) throw ruleError
        return NextResponse.json({ success: true, data: ruleResult })

      default:
        return NextResponse.json({ success: false, error: 'Invalid section' }, { status: 400 })
    }
  } catch (error) {
    console.error('PUT Error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const id = searchParams.get('id')

    if (!id) {
      return NextResponse.json({ success: false, error: 'ID required for delete' }, { status: 400 })
    }

    switch (section) {
      case 'categories':
        const { error: categoryError } = await supabase
          .from('project_categories')
          .update({ is_active: false })
          .eq('id', id)

        if (categoryError) throw categoryError
        return NextResponse.json({ success: true })

      case 'gl-rules':
        const { error: ruleError } = await supabase
          .from('project_gl_determination')
          .update({ is_active: false })
          .eq('id', id)

        if (ruleError) throw ruleError
        return NextResponse.json({ success: true })

      default:
        return NextResponse.json({ success: false, error: 'Invalid section' }, { status: 400 })
    }
  } catch (error) {
    console.error('DELETE Error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}
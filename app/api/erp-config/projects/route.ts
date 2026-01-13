import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { withAuth } from '@/lib/authMiddleware'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export const GET = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const id = searchParams.get('id')
    const company = searchParams.get('company')
    
    if (!company) {
      return NextResponse.json({ 
        success: false, 
        error: 'Company code required for multi-tenant data' 
      }, { status: 400 })
    }
    
    // Validate user has access to this company code
    const userCompanyCodes = await context.authService.getUserCompanyCodes(context.user.id)
    if (!userCompanyCodes.companyCodes.some(c => c.company_code === company)) {
      return NextResponse.json({ error: 'Access denied to company code' }, { status: 403 })
    }

    switch (section) {
      case 'categories':
        if (id) {
          const { data, error } = await supabase
            .from('project_categories')
            .select('*')
            .eq('company_code', company)
            .eq('category_code', id)
            .single()
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        } else {
          const { data, error } = await supabase
            .from('project_categories')
            .select('*')
            .eq('company_code', company)
            .eq('is_active', true)
            .order('category_name')
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        }

      case 'gl-rules':
        if (id) {
          const { data, error } = await supabase
            .from('project_gl_determination')
            .select('*, hsn_sac_code, supplier_code, gst_rate, is_capital_goods')
            .eq('company_code', company)
            .eq('id', id)
            .single()
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        } else {
          const { data, error } = await supabase
            .from('project_gl_determination')
            .select('*, hsn_sac_code, supplier_code, gst_rate, is_capital_goods')
            .eq('company_code', company)
            .eq('is_active', true)
            .order('project_category')
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        }

      case 'gl-minimal':
        // This will be handled in POST method
        return NextResponse.json({ success: false, error: 'Use POST for GL determination' }, { status: 400 })

      case 'numbering':
        if (id) {
          const { data, error } = await supabase
            .from('project_numbering_rules')
            .select('*')
            .eq('company_code', company)
            .eq('id', id)
            .single()
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        } else {
          const { data, error } = await supabase
            .from('project_numbering_rules')
            .select('*')
            .eq('company_code', company)
            .eq('is_active', true)
            .order('entity_type')
          
          if (error) throw error
          return NextResponse.json({ success: true, data })
        }

      case 'workflows':
        const { data: workflowData, error: workflowError } = await supabase
          .from('project_workflows')
          .select('*')
          .eq('company_code', company)
          .eq('is_active', true)
          .order('workflow_name')
        
        if (workflowError) throw workflowError
        return NextResponse.json({ success: true, data: workflowData })

      case 'types':
        const category = searchParams.get('category')
        let typesQuery = supabase
          .from('project_types')
          .select('*')
          .eq('company_code', company)
          .eq('is_active', true)
        
        if (category) {
          typesQuery = typesQuery.eq('category_code', category)
        }
        
        const { data: typesData, error: typesError } = await typesQuery.order('type_name')
        
        if (typesError) throw typesError
        return NextResponse.json({ success: true, data: typesData })

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
}, ['PROJECT_CONFIG_READ']);

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const body = await request.json()

    // Validate company access for POST operations
    const companyCode = body.company_code || process.env.NEXT_PUBLIC_DEFAULT_COMPANY_CODE || 'C001'
    const userCompanyCodes = await context.authService.getUserCompanyCodes(context.user.id)
    if (!userCompanyCodes.companyCodes.some(c => c.company_code === companyCode)) {
      return NextResponse.json({ error: 'Access denied to company code' }, { status: 403 })
    }

    switch (section) {
      case 'categories':
        const categoryData = {
          category_code: body.category_code,
          category_name: body.category_name,
          cost_ownership: body.cost_ownership,
          real_time_posting: body.real_time_posting || false,
          company_code: body.company_code || process.env.NEXT_PUBLIC_DEFAULT_COMPANY_CODE || 'C001',
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
          company_code: body.company_code || 'C001',
          project_category: body.project_category,
          event_type: body.event_type,
          gl_account_type: body.gl_account_type,
          debit_credit: body.debit_credit,
          posting_key: body.posting_key,
          gl_account_range: body.gl_account_range,
          description: body.description,
          hsn_sac_code: body.hsn_sac_code || '7214',
          supplier_code: body.supplier_code,
          gst_rate: body.gst_rate || 18.0,
          is_capital_goods: body.is_capital_goods || false,
          is_active: true
        }

        const { data: ruleResult, error: ruleError } = await supabase
          .from('project_gl_determination')
          .insert(ruleData)
          .select()
          .single()

        if (ruleError) throw ruleError
        return NextResponse.json({ success: true, data: ruleResult })

      case 'gl-minimal':
        // SAP-like HSN validation with multiple HSN selection
        const { data: validationResult, error: validationError } = await supabase
          .rpc('validate_hsn_with_selection', {
            p_company_code: body.company_code,
            p_material_code: body.material_code,
            p_movement_type: body.movement_type,
            p_supplier_code: body.supplier_code,
            p_taxable_amount: body.taxable_amount
          })

        if (validationError) throw validationError
        
        // If HSN selection required, return options to user
        if (validationResult[0]?.validation_status === 'HSN_SELECTION_REQUIRED') {
          return NextResponse.json({ 
            success: false, 
            error: validationResult[0]?.error_message,
            validation_status: 'HSN_SELECTION_REQUIRED',
            hsn_options: validationResult[0]?.hsn_options,
            default_hsn: validationResult[0]?.default_hsn,
            material_group: validationResult[0]?.material_group,
            requires_user_selection: true
          }, { status: 422 })
        }
        
        // If other validation errors and no override provided
        if (validationResult[0]?.validation_status !== 'SUCCESS' && !body.override_hsn) {
          return NextResponse.json({ 
            success: false, 
            error: validationResult[0]?.error_message,
            validation_status: validationResult[0]?.validation_status,
            default_hsn: validationResult[0]?.default_hsn,
            requires_user_input: true
          }, { status: 422 })
        }

        // Proceed with GL determination
        const { data: glResult, error: glError } = await supabase
          .rpc('get_gl_with_hsn_validation', {
            p_company_code: body.company_code,
            p_movement_type: body.movement_type,
            p_material_code: body.material_code,
            p_supplier_code: body.supplier_code,
            p_taxable_amount: body.taxable_amount,
            p_transaction_id: body.transaction_id,
            p_override_hsn: body.override_hsn || validationResult[0]?.default_hsn,
            p_user_id: context.user.id
          })

        if (glError) throw glError
        return NextResponse.json({ success: true, data: glResult })

      case 'gl-universal':
        // Multi-country tax calculation
        const { data: universalResult, error: universalError } = await supabase
          .rpc('get_gl_universal', {
            p_company_code: body.company_code,
            p_movement_type: body.movement_type,
            p_material_code: body.material_code,
            p_supplier_code: body.supplier_code,
            p_taxable_amount: body.taxable_amount
          })

        if (universalError) throw universalError
        return NextResponse.json({ success: true, data: universalResult })

      case 'numbering':
        const numberingData = {
          entity_type: body.entity_type,
          pattern: body.pattern,
          current_number: isNaN(parseInt(body.current_number)) ? 1 : parseInt(body.current_number),
          description: body.description,
          company_code: body.company_code || process.env.NEXT_PUBLIC_DEFAULT_COMPANY_CODE || 'C001',
          is_active: true
        }

        const { data: numberingResult, error: numberingError } = await supabase
          .from('project_numbering_rules')
          .insert(numberingData)
          .select()
          .single()

        if (numberingError) throw numberingError
        return NextResponse.json({ success: true, data: numberingResult })

      case 'types':
        const typeData = {
          type_code: body.type_code,
          type_name: body.type_name,
          category_code: body.category_code,
          gl_posting_variant: body.gl_posting_variant,
          description: body.description,
          company_code: body.company_code || 'C001',
          is_active: true,
          sort_order: body.sort_order || 999
        }

        const { data: typeResult, error: typeError } = await supabase
          .from('project_types')
          .insert(typeData)
          .select()
          .single()

        if (typeError) throw typeError
        return NextResponse.json({ success: true, data: typeResult })

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
}, ['PROJECT_CONFIG_WRITE']);

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const id = searchParams.get('id')
    const company = searchParams.get('company')
    const body = await request.json()

    if (!id) {
      return NextResponse.json({ success: false, error: 'ID required for update' }, { status: 400 })
    }

    switch (section) {
      case 'categories':
        const allowedCategoryFields = {
          category_code: body.category_code,
          category_name: body.category_name,
          cost_ownership: body.cost_ownership,
          real_time_posting: body.real_time_posting,
          description: body.description,
          sort_order: body.sort_order
        }
        const { data: categoryResult, error: categoryError } = await supabase
          .from('project_categories')
          .update(allowedCategoryFields)
          .eq('id', id)
          .eq('company_code', company)
          .select()
          .single()

        if (categoryError) throw categoryError
        return NextResponse.json({ success: true, data: categoryResult })

      case 'gl-rules':
        const allowedGLFields = {
          project_category: body.project_category,
          event_type: body.event_type,
          gl_account_type: body.gl_account_type,
          debit_credit: body.debit_credit,
          posting_key: body.posting_key,
          gl_account_range: body.gl_account_range,
          description: body.description,
          hsn_sac_code: body.hsn_sac_code,
          supplier_code: body.supplier_code,
          gst_rate: body.gst_rate,
          is_capital_goods: body.is_capital_goods
        }
        const { data: ruleResult, error: ruleError } = await supabase
          .from('project_gl_determination')
          .update(allowedGLFields)
          .eq('id', id)
          .eq('company_code', company)
          .select()
          .single()

        if (ruleError) throw ruleError
        return NextResponse.json({ success: true, data: ruleResult })

      case 'numbering':
        const allowedNumberingFields = {
          entity_type: body.entity_type,
          pattern: body.pattern,
          current_number: parseInt(body.current_number),
          description: body.description
        }
        const { data: numberingResult, error: numberingError } = await supabase
          .from('project_numbering_rules')
          .update(allowedNumberingFields)
          .eq('id', id)
          .eq('company_code', company)
          .select()
          .single()

        if (numberingError) throw numberingError
        return NextResponse.json({ success: true, data: numberingResult })

      case 'types':
        const allowedTypeFields = {
          type_code: body.type_code,
          type_name: body.type_name,
          category_code: body.category_code,
          gl_posting_variant: body.gl_posting_variant,
          description: body.description,
          sort_order: body.sort_order
        }
        const { data: typeUpdateResult, error: typeUpdateError } = await supabase
          .from('project_types')
          .update(allowedTypeFields)
          .eq('id', id)
          .eq('company_code', company)
          .select()
          .single()

        if (typeUpdateError) throw typeUpdateError
        return NextResponse.json({ success: true, data: typeUpdateResult })

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
}, ['PROJECT_CONFIG_WRITE']);

export const DELETE = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const section = searchParams.get('section')
    const id = searchParams.get('id')
    const company = searchParams.get('company')

    if (!id) {
      return NextResponse.json({ success: false, error: 'ID required for delete' }, { status: 400 })
    }

    if (!company) {
      return NextResponse.json({ 
        success: false, 
        error: 'Company code required for multi-tenant operations' 
      }, { status: 400 })
    }

    switch (section) {
      case 'categories':
        const { error: categoryError } = await supabase
          .from('project_categories')
          .update({ is_active: false })
          .eq('id', id)
          .eq('company_code', company)

        if (categoryError) throw categoryError
        return NextResponse.json({ success: true })

      case 'gl-rules':
        const { error: ruleError } = await supabase
          .from('project_gl_determination')
          .update({ is_active: false })
          .eq('id', id)
          .eq('company_code', company)

        if (ruleError) throw ruleError
        return NextResponse.json({ success: true })

      case 'numbering':
        const { error: numberingError } = await supabase
          .from('project_numbering_rules')
          .update({ is_active: false })
          .eq('id', id)
          .eq('company_code', company)

        if (numberingError) throw numberingError
        return NextResponse.json({ success: true })

      case 'types':
        const { error: typeDeleteError } = await supabase
          .from('project_types')
          .update({ is_active: false })
          .eq('id', id)
          .eq('company_code', company)

        if (typeDeleteError) throw typeDeleteError
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
}, ['PROJECT_CONFIG_WRITE']);
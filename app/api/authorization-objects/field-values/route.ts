import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { withAuth } from '@/lib/authMiddleware'

const ACTIVITY_CODES = [
  { value: '01', label: '01 - Create' },
  { value: '02', label: '02 - Change' },
  { value: '03', label: '03 - Display' },
  { value: '06', label: '06 - Delete' },
  { value: '*', label: '* - All' }
]

const FIELD_SOURCE_MAP: Record<string, { table: string; valueCol: string; displayCol: string }> = {
  'COMP_CODE': { table: 'company_codes', valueCol: 'company_code', displayCol: 'company_name' },
  'PLANT': { table: 'plants', valueCol: 'plant_code', displayCol: 'plant_name' },
  'STORAGE_LOC': { table: 'storage_locations', valueCol: 'sloc_code', displayCol: 'sloc_name' },
  'DEPT': { table: 'departments', valueCol: 'dept_code', displayCol: 'name' },
  'COST_CENTER': { table: 'cost_centers', valueCol: 'cost_center_code', displayCol: 'cost_center_name' },
  'PURCH_ORG': { table: 'purchasing_organizations', valueCol: 'porg_code', displayCol: 'porg_name' },
  'PROJ_TYPE': { table: 'projects', valueCol: 'project_type', displayCol: 'project_type' },
  'MR_TYPE': { table: 'material_requests', valueCol: 'mr_type', displayCol: 'mr_type' },
  'PR_TYPE': { table: 'purchase_requisitions', valueCol: 'pr_type', displayCol: 'pr_type' },
  'MAT_TYPE': { table: 'materials', valueCol: 'material_type', displayCol: 'material_type' }
}

const STATIC_VALUES: Record<string, Array<{ value: string; label: string }>> = {
  'ACTVT': ACTIVITY_CODES,
  'PO_TYPE': [
    { value: 'STANDARD', label: 'Standard PO' },
    { value: 'BLANKET', label: 'Blanket PO' },
    { value: 'CONTRACT', label: 'Contract PO' },
    { value: 'SUBCONTRACT', label: 'Subcontract PO' },
    { value: 'EMERGENCY', label: 'Emergency PO' },
    { value: '*', label: '* - All' }
  ]
}

export const GET = withAuth(async (request: NextRequest, context) => {
  try {
    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ success: false, error: 'Tenant required' }, { status: 400 })
    }
    
    const { searchParams } = new URL(request.url)
    const fieldName = searchParams.get('field_name')
    
    if (!fieldName) {
      return NextResponse.json({ success: false, error: 'field_name required' }, { status: 400 })
    }
    
    if (STATIC_VALUES[fieldName]) {
      return NextResponse.json({
        success: true,
        data: { fieldName, values: STATIC_VALUES[fieldName], source: 'static' }
      })
    }
    
    const sourceConfig = FIELD_SOURCE_MAP[fieldName]
    if (!sourceConfig) {
      return NextResponse.json({ success: false, error: `Unknown field: ${fieldName}` }, { status: 404 })
    }
    
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from(sourceConfig.table)
      .select(`${sourceConfig.valueCol}, ${sourceConfig.displayCol}`)
      .eq('tenant_id', tenantId)
      .eq('is_active', true)
      .order(sourceConfig.valueCol)
    
    if (error) throw error
    
    // For PROJ_TYPE, MR_TYPE, PR_TYPE, MAT_TYPE - get distinct enum values
    let values
    if (['PROJ_TYPE', 'MR_TYPE', 'PR_TYPE', 'MAT_TYPE'].includes(fieldName)) {
      const distinctTypes = Array.from(new Set(
        (data || []).map(row => row[sourceConfig.valueCol]).filter(Boolean)
      ))
      values = distinctTypes.map(type => ({
        value: type,
        label: type
      }))
    } else {
      values = (data || []).map(row => ({
        value: row[sourceConfig.valueCol],
        label: `${row[sourceConfig.valueCol]} - ${row[sourceConfig.displayCol]}`
      }))
    }
    
    values.push({ value: '*', label: '* - All' })
    
    return NextResponse.json({
      success: true,
      data: { fieldName, values, source: 'database', table: sourceConfig.table }
    })
  } catch (error) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 })
  }
})

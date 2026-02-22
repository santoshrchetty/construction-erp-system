import { createServiceClient } from '@/lib/supabase/server'

export interface AccountAssignmentType {
  code: string
  name: string
  description: string
  requires_cost_center: boolean
  requires_wbs_element: boolean
  requires_activity_code: boolean
  requires_asset_number: boolean
  requires_order_number: boolean
  is_active: boolean
}

export interface MRTypeMapping {
  mr_type: string
  account_assignment_code: string
  is_default: boolean
  is_allowed: boolean
  display_order: number
}

export class AccountAssignmentService {
  
  async getAccountAssignmentTypes() {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('account_assignment_types')
      .select('*')
      .eq('is_active', true)
      .order('display_order')

    if (error) throw error
    return data || []
  }

  async getDefaultAccountAssignment(mrType: string) {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('mr_type_account_assignment_mapping')
      .select('account_assignment_code')
      .eq('mr_type', mrType)
      .eq('is_default', true)
      .single()

    if (error) return null
    return data?.account_assignment_code || null
  }

  async getAllowedAccountAssignments(mrType: string) {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('mr_type_account_assignment_mapping')
      .select(`
        account_assignment_code,
        is_default,
        display_order,
        account_assignment_types (
          code,
          name,
          description,
          requires_cost_center,
          requires_wbs_element,
          requires_activity_code,
          requires_asset_number,
          requires_order_number
        )
      `)
      .eq('mr_type', mrType)
      .eq('is_allowed', true)
      .order('display_order')

    if (error) throw error
    
    return (data || []).map(item => ({
      code: item.account_assignment_code,
      is_default: item.is_default,
      ...(item.account_assignment_types as any)
    }))
  }

  async getMRTypes() {
    return [
      { code: 'PROJECT', name: 'Project Materials' },
      { code: 'MAINTENANCE', name: 'Maintenance' },
      { code: 'GENERAL', name: 'General Supplies' },
      { code: 'ASSET', name: 'Asset Purchase' },
      { code: 'OFFICE', name: 'Office Supplies' },
      { code: 'SAFETY', name: 'Safety Equipment' },
      { code: 'EQUIPMENT', name: 'Equipment' }
    ]
  }
}

export const accountAssignmentService = new AccountAssignmentService()

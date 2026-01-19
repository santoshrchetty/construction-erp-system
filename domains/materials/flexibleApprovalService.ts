import { createClient } from '@/lib/supabase/client'

export interface ApprovalLevel {
  id?: string
  level_number: number
  level_name: string
  approver_role: string
  amount_threshold_min: number
  amount_threshold_max?: number
  category_filter?: string
  department_filter?: string
  is_mandatory: boolean
  timeout_hours: number
  parallel_group_id?: number
}

export interface ApprovalTemplate {
  id?: string
  template_name: string
  template_description: string
  customer_type: string
  industry_type: string
  template_levels: ApprovalLevel[]
}

export interface ApprovalPath {
  level_number: number
  level_name: string
  approver_role: string
  is_required: boolean
  timeout_hours: number
  parallel_group_id?: number
}

class FlexibleApprovalService {
  private supabase = createClient()

  // Get available templates
  async getApprovalTemplates(customerType?: string, industryType?: string): Promise<{ success: boolean; data?: ApprovalTemplate[]; error?: string }> {
    try {
      let query = this.supabase
        .from('approval_level_templates')
        .select('*')
        .eq('is_public', true)
        .order('template_name')

      if (customerType) query = query.eq('customer_type', customerType)
      if (industryType) query = query.eq('industry_type', industryType)

      const { data, error } = await query

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error fetching templates:', error)
      return { success: false, error: error.message }
    }
  }

  // Apply template to customer
  async applyApprovalTemplate(
    customerId: string, 
    documentType: string, 
    templateId: string, 
    configName: string = 'Default Configuration'
  ): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      const { data, error } = await this.supabase.rpc('apply_approval_template', {
        p_customer_id: customerId,
        p_document_type: documentType,
        p_template_id: templateId,
        p_config_name: configName
      })

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error applying template:', error)
      return { success: false, error: error.message }
    }
  }

  // Get customer's approval levels for a document type
  async getCustomerApprovalLevels(customerId: string, documentType: string): Promise<{ success: boolean; data?: ApprovalLevel[]; error?: string }> {
    try {
      const { data, error } = await this.supabase
        .from('flexible_approval_levels')
        .select('*')
        .eq('customer_id', customerId)
        .eq('document_type', documentType)
        .eq('is_active', true)
        .order('level_number')

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error fetching approval levels:', error)
      return { success: false, error: error.message }
    }
  }

  // Create custom approval level
  async createCustomApprovalLevel(
    customerId: string,
    documentType: string,
    levelData: Omit<ApprovalLevel, 'id'>
  ): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      const { data, error } = await this.supabase.rpc('create_custom_approval_level', {
        p_customer_id: customerId,
        p_document_type: documentType,
        p_level_number: levelData.level_number,
        p_level_name: levelData.level_name,
        p_approver_role: levelData.approver_role,
        p_amount_min: levelData.amount_threshold_min,
        p_amount_max: levelData.amount_threshold_max,
        p_category_filter: levelData.category_filter,
        p_department_filter: levelData.department_filter
      })

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error creating approval level:', error)
      return { success: false, error: error.message }
    }
  }

  // Get approval path for a specific request
  async getApprovalPath(
    customerId: string,
    documentType: string,
    amount: number,
    category?: string,
    department?: string
  ): Promise<{ success: boolean; data?: ApprovalPath[]; error?: string }> {
    try {
      const { data, error } = await this.supabase.rpc('get_approval_path', {
        p_customer_id: customerId,
        p_document_type: documentType,
        p_amount: amount,
        p_category: category,
        p_department: department
      })

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error getting approval path:', error)
      return { success: false, error: error.message }
    }
  }

  // Update approval level
  async updateApprovalLevel(levelId: string, updates: Partial<ApprovalLevel>): Promise<{ success: boolean; error?: string }> {
    try {
      const { error } = await this.supabase
        .from('flexible_approval_levels')
        .update(updates)
        .eq('id', levelId)

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Error updating approval level:', error)
      return { success: false, error: error.message }
    }
  }

  // Delete approval level
  async deleteApprovalLevel(levelId: string): Promise<{ success: boolean; error?: string }> {
    try {
      const { error } = await this.supabase
        .from('flexible_approval_levels')
        .delete()
        .eq('id', levelId)

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Error deleting approval level:', error)
      return { success: false, error: error.message }
    }
  }

  // Get customer approval summary
  async getCustomerApprovalSummary(customerId: string): Promise<{ success: boolean; data?: any[]; error?: string }> {
    try {
      const { data, error } = await this.supabase
        .from('customer_approval_summary')
        .select('*')
        .eq('customer_id', customerId)
        .order('document_type')

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error fetching approval summary:', error)
      return { success: false, error: error.message }
    }
  }
}

export const flexibleApprovalService = new FlexibleApprovalService()
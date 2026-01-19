import { createClient } from '@/lib/supabase/client'

export interface MaterialRequestItem {
  line_number: number
  material_code: string
  material_name?: string
  description?: string
  requested_quantity: number
  base_uom: string
  estimated_price?: number
  currency_code?: string
  storage_location?: string
  preferred_vendor?: string
  delivery_date?: string
}

export interface MaterialRequest {
  id?: string
  request_number?: string
  request_type: 'RESERVATION' | 'PURCHASE_REQ' | 'MATERIAL_REQ'
  status?: string
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
  requested_by?: string
  required_date: string
  company_code: string
  plant_code?: string
  cost_center?: string
  wbs_element?: string
  project_code?: string
  purpose?: string
  justification?: string
  notes?: string
  items: MaterialRequestItem[]
}

export interface ApprovalWorkflow {
  id: string
  workflow_name: string
  request_type: string
  level_1_approver_role?: string
  level_1_amount_limit?: number
  level_2_approver_role?: string
  level_2_amount_limit?: number
}

export interface RequestTemplate {
  id: string
  template_name: string
  template_type: string
  default_priority: string
  default_purpose?: string
  template_items: any[]
}

class UnifiedMaterialRequestService {
  private supabase = createClient()

  // Generate request number based on type
  generateRequestNumber(type: string, companyCode: string): string {
    const timestamp = Date.now().toString().slice(-6)
    const random = Math.floor(Math.random() * 100).toString().padStart(2, '0')
    const prefix = {
      'RESERVATION': 'RES',
      'PURCHASE_REQ': 'PR',
      'MATERIAL_REQ': 'MR'
    }[type] || 'REQ'
    
    return `${prefix}-${companyCode}-${timestamp}-${random}`
  }

  // Create unified material request
  async createMaterialRequest(request: MaterialRequest, userId: string): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      // Generate request number if not provided
      if (!request.request_number) {
        request.request_number = this.generateRequestNumber(request.request_type, request.company_code)
      }

      // Determine approval workflow
      const workflow = await this.getApprovalWorkflow(request.request_type, request.company_code, this.calculateTotalAmount(request.items))
      
      // Create main request
      const { data: requestData, error: requestError } = await this.supabase
        .from('material_requests')
        .insert({
          request_number: request.request_number,
          request_type: request.request_type,
          priority: request.priority,
          required_date: request.required_date,
          company_code: request.company_code,
          plant_code: request.plant_code,
          cost_center: request.cost_center,
          wbs_element: request.wbs_element,
          project_code: request.project_code,
          purpose: request.purpose,
          justification: request.justification,
          notes: request.notes,
          requested_by: userId,
          created_by: userId,
          current_approver: workflow?.level_1_approver_role ? await this.getApproverByRole(workflow.level_1_approver_role, request.company_code) : null,
          status: workflow ? 'SUBMITTED' : 'APPROVED' // Auto-approve if no workflow
        })
        .select()
        .single()

      if (requestError) throw requestError

      // Create request items
      const itemsToInsert = request.items.map(item => ({
        request_id: requestData.id,
        line_number: item.line_number,
        material_code: item.material_code,
        material_name: item.material_name,
        description: item.description,
        requested_quantity: item.requested_quantity,
        base_uom: item.base_uom,
        estimated_price: item.estimated_price,
        currency_code: item.currency_code || 'USD',
        storage_location: item.storage_location,
        preferred_vendor: item.preferred_vendor,
        delivery_date: item.delivery_date
      }))

      const { error: itemsError } = await this.supabase
        .from('material_request_items')
        .insert(itemsToInsert)

      if (itemsError) throw itemsError

      // Auto-process based on type and availability
      if (request.request_type === 'RESERVATION') {
        await this.processReservation(requestData.id)
      }

      return { success: true, data: { ...requestData, items: request.items } }
    } catch (error) {
      console.error('Error creating material request:', error)
      return { success: false, error: error.message }
    }
  }

  // Get material requests with filters
  async getMaterialRequests(filters: {
    request_type?: string
    status?: string
    requested_by?: string
    company_code?: string
    date_from?: string
    date_to?: string
  }): Promise<{ success: boolean; data?: any[]; error?: string }> {
    try {
      let query = this.supabase
        .from('material_requests')
        .select(`
          *,
          material_request_items(*),
          requested_by_user:auth.users!requested_by(email),
          approved_by_user:auth.users!approved_by(email)
        `)
        .order('created_at', { ascending: false })

      if (filters.request_type) query = query.eq('request_type', filters.request_type)
      if (filters.status) query = query.eq('status', filters.status)
      if (filters.requested_by) query = query.eq('requested_by', filters.requested_by)
      if (filters.company_code) query = query.eq('company_code', filters.company_code)
      if (filters.date_from) query = query.gte('required_date', filters.date_from)
      if (filters.date_to) query = query.lte('required_date', filters.date_to)

      const { data, error } = await query

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error fetching material requests:', error)
      return { success: false, error: error.message }
    }
  }

  // Update request status (approval/rejection)
  async updateRequestStatus(requestId: string, status: string, userId: string, comments?: string): Promise<{ success: boolean; error?: string }> {
    try {
      const updateData: any = {
        status,
        updated_by: userId
      }

      if (status === 'APPROVED') {
        updateData.approved_by = userId
        updateData.approved_date = new Date().toISOString()
      } else if (status === 'REJECTED') {
        updateData.rejected_by = userId
        updateData.rejected_date = new Date().toISOString()
        updateData.rejection_reason = comments
      }

      const { error } = await this.supabase
        .from('material_requests')
        .update(updateData)
        .eq('id', requestId)

      if (error) throw error

      // Auto-process approved reservations
      if (status === 'APPROVED') {
        const { data: request } = await this.supabase
          .from('material_requests')
          .select('request_type')
          .eq('id', requestId)
          .single()

        if (request?.request_type === 'RESERVATION') {
          await this.processReservation(requestId)
        }
      }

      return { success: true }
    } catch (error) {
      console.error('Error updating request status:', error)
      return { success: false, error: error.message }
    }
  }

  // Get approval workflows
  async getApprovalWorkflows(): Promise<{ success: boolean; data?: ApprovalWorkflow[]; error?: string }> {
    try {
      const { data, error } = await this.supabase
        .from('approval_workflows')
        .select('*')
        .eq('is_active', true)
        .order('workflow_name')

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error fetching approval workflows:', error)
      return { success: false, error: error.message }
    }
  }

  // Get request templates
  async getRequestTemplates(templateType?: string): Promise<{ success: boolean; data?: RequestTemplate[]; error?: string }> {
    try {
      let query = this.supabase
        .from('request_templates')
        .select('*')
        .eq('is_active', true)
        .order('template_name')

      if (templateType) {
        query = query.eq('template_type', templateType)
      }

      const { data, error } = await query

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error fetching request templates:', error)
      return { success: false, error: error.message }
    }
  }

  // Smart defaults based on user profile and context
  async getSmartDefaults(userId: string): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      // Get user's default organizational assignments
      const { data: userProfile } = await this.supabase
        .from('user_profiles')
        .select('default_company_code, default_plant_code, default_cost_center')
        .eq('user_id', userId)
        .single()

      // Get frequently used materials by user
      const { data: frequentMaterials } = await this.supabase
        .from('material_request_items')
        .select('material_code, material_name, COUNT(*) as usage_count')
        .eq('material_requests.requested_by', userId)
        .group('material_code, material_name')
        .order('usage_count', { ascending: false })
        .limit(10)

      return {
        success: true,
        data: {
          organizational: userProfile,
          frequent_materials: frequentMaterials || []
        }
      }
    } catch (error) {
      console.error('Error getting smart defaults:', error)
      return { success: false, error: error.message }
    }
  }

  // Convert material request to purchase requisition
  async convertToPurchaseRequisition(requestId: string, userId: string): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      // Get original request
      const { data: originalRequest, error: fetchError } = await this.supabase
        .from('material_requests')
        .select('*, material_request_items(*)')
        .eq('id', requestId)
        .single()

      if (fetchError) throw fetchError

      // Create new PR
      const prData = {
        ...originalRequest,
        id: undefined,
        request_number: this.generateRequestNumber('PURCHASE_REQ', originalRequest.company_code),
        request_type: 'PURCHASE_REQ',
        status: 'DRAFT',
        created_by: userId,
        requested_by: userId
      }

      const newRequest = await this.createMaterialRequest(prData, userId)

      if (!newRequest.success) throw new Error(newRequest.error)

      // Update original request status
      await this.supabase
        .from('material_requests')
        .update({
          status: 'CONVERTED',
          converted_to_po: newRequest.data.request_number,
          converted_date: new Date().toISOString()
        })
        .eq('id', requestId)

      return { success: true, data: newRequest.data }
    } catch (error) {
      console.error('Error converting to PR:', error)
      return { success: false, error: error.message }
    }
  }

  // Private helper methods
  private calculateTotalAmount(items: MaterialRequestItem[]): number {
    return items.reduce((total, item) => {
      return total + (item.estimated_price || 0) * item.requested_quantity
    }, 0)
  }

  private async getApprovalWorkflow(requestType: string, companyCode: string, totalAmount: number): Promise<ApprovalWorkflow | null> {
    const { data } = await this.supabase
      .from('approval_workflows')
      .select('*')
      .eq('request_type', requestType)
      .eq('company_code', companyCode)
      .lte('amount_threshold', totalAmount)
      .eq('is_active', true)
      .order('amount_threshold', { ascending: false })
      .limit(1)
      .single()

    return data
  }

  private async getApproverByRole(role: string, companyCode: string): Promise<string | null> {
    // Implementation would query user roles table
    // For now, return null (auto-approve)
    return null
  }

  private async processReservation(requestId: string): Promise<void> {
    // Check material availability and create reservations
    // Update item status to 'RESERVED' if available
    // This would integrate with inventory management
  }
}

export const unifiedMaterialRequestService = new UnifiedMaterialRequestService()
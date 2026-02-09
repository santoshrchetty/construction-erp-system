import { createClient } from '@/lib/supabase/client'
import { documentNumberingService } from '@/lib/services/documentNumberingService'

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

  // Create unified material request
  async createMaterialRequest(request: any, userId: string, tenantId: string): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      // Validate required fields
      if (!request.company_code) {
        return { success: false, error: 'Company code is required' }
      }
      if (!request.items || request.items.length === 0) {
        return { success: false, error: 'At least one material item is required' }
      }
      if (!tenantId) {
        return { success: false, error: 'Tenant ID is required' }
      }

      // Generate request number using centralized service
      const documentTypeKey = request.request_type === 'PURCHASE_REQ' ? 'PURCHASE_REQ' : 'MATERIAL_REQ'
      const requestNumber = await documentNumberingService.generateDocumentNumber(
        documentTypeKey,
        request.company_code,
        tenantId
      )

      // Create main request
      const { data: requestData, error: requestError } = await this.supabase
        .from('material_requests')
        .insert({
          request_number: requestNumber,
          request_type: request.request_type || 'MATERIAL_REQ',
          priority: request.priority || 'MEDIUM',
          company_code: request.company_code,
          plant_code: request.plant_code,
          project_code: request.project_code,
          cost_center: request.cost_center,
          wbs_element: request.wbs_element,
          activity_code: request.activity_code,
          storage_location: request.storage_location,
          purpose: request.purpose,
          justification: request.justification,
          notes: request.notes,
          total_amount: request.total_amount || 0,
          currency_code: request.currency_code || 'USD',
          requested_by: userId,
          created_by: userId,
          tenant_id: tenantId,
          status: 'DRAFT'
        })
        .select()
        .single()

      if (requestError) throw requestError

      // Create request items
      if (request.items && request.items.length > 0) {
        const itemsToInsert = request.items.map((item: any, index: number) => ({
          request_id: requestData.id,
          line_number: item.line_number || index + 1,
          material_code: item.material_code,
          material_name: item.material_name,
          description: item.description,
          requested_quantity: item.requested_quantity || item.quantity,
          base_uom: item.base_uom || item.unit,
          estimated_price: item.estimated_price,
          currency_code: item.currency_code || 'USD',
          required_date: item.required_date, // Item-level required date
          priority: item.priority || 'MEDIUM', // Item-level priority
          delivery_date: item.delivery_date,
          notes: item.notes,
          storage_location: item.storage_location,
          tenant_id: tenantId
        }))

        const { error: itemsError } = await this.supabase
          .from('material_request_items')
          .insert(itemsToInsert)

        if (itemsError) throw itemsError
      }

      return { success: true, data: requestData }
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
    tenant_id: string
  }): Promise<{ success: boolean; data?: any[]; error?: string }> {
    try {
      if (!filters.tenant_id) {
        return { success: false, error: 'Tenant ID is required' }
      }

      let query = this.supabase
        .from('material_requests')
        .select('*')
        .eq('tenant_id', filters.tenant_id)
        .order('created_at', { ascending: false })

      if (filters.request_type) query = query.eq('request_type', filters.request_type)
      if (filters.status) query = query.eq('status', filters.status)
      if (filters.requested_by) query = query.eq('requested_by', filters.requested_by)
      if (filters.company_code) query = query.eq('company_code', filters.company_code)
      if (filters.date_from) query = query.gte('required_date', filters.date_from)
      if (filters.date_to) query = query.lte('required_date', filters.date_to)

      const { data, error } = await query

      if (error) throw error

      return { success: true, data: data || [] }
    } catch (error) {
      console.error('Error fetching material requests:', error)
      return { success: false, error: error.message }
    }
  }

  // Get single material request by ID with all details including line items
  async getMaterialRequestById(requestId: string, tenantId: string): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      if (!tenantId) {
        return { success: false, error: 'Tenant ID is required' }
      }

      // Fetch request
      const { data: request, error: requestError } = await this.supabase
        .from('material_requests')
        .select('*')
        .eq('id', requestId)
        .eq('tenant_id', tenantId)
        .single()

      if (requestError) throw requestError

      // Fetch line items
      const { data: items, error: itemsError } = await this.supabase
        .from('material_request_items')
        .select('*')
        .eq('request_id', requestId)
        .eq('tenant_id', tenantId)
        .order('line_number')

      if (itemsError) throw itemsError

      // Format the response
      const formattedRequest = {
        ...request,
        items: items || []
      }

      return { success: true, data: formattedRequest }
    } catch (error) {
      console.error('Error fetching material request by ID:', error)
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

  // Delete material request (only DRAFT status)
  async deleteMaterialRequest(requestId: string, tenantId: string): Promise<{ success: boolean; error?: string }> {
    try {
      if (!tenantId) {
        return { success: false, error: 'Tenant ID is required' }
      }

      // Check if request is in DRAFT status
      const { data: request, error: fetchError } = await this.supabase
        .from('material_requests')
        .select('status')
        .eq('id', requestId)
        .eq('tenant_id', tenantId)
        .single()

      if (fetchError) throw fetchError

      if (request.status !== 'DRAFT' && request.status !== 'SUBMITTED') {
        throw new Error('Only DRAFT or SUBMITTED requests can be deleted')
      }

      // Delete items first (foreign key constraint)
      const { error: itemsError } = await this.supabase
        .from('material_request_items')
        .delete()
        .eq('request_id', requestId)
        .eq('tenant_id', tenantId)

      if (itemsError) throw itemsError

      // Delete request
      const { error: deleteError } = await this.supabase
        .from('material_requests')
        .delete()
        .eq('id', requestId)
        .eq('tenant_id', tenantId)

      if (deleteError) throw deleteError

      return { success: true }
    } catch (error) {
      console.error('Error deleting material request:', error)
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
      // Table doesn't exist yet, return empty array
      return { success: true, data: [] }
      
      /* Uncomment when request_templates table is created
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
      */
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
  async convertToPurchaseRequisition(requestId: string, userId: string, tenantId: string): Promise<{ success: boolean; data?: any; error?: string }> {
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
        request_type: 'PURCHASE_REQ',
        status: 'DRAFT',
        created_by: userId,
        requested_by: userId
      }

      const newRequest = await this.createMaterialRequest(prData, userId, tenantId)

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
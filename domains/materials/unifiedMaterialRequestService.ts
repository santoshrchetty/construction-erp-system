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
  async createMaterialRequest(request: any, userId: string): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      // Use codes directly (VARCHAR only, no IDs)
      const companyCode = request.company_code || null
      const plantCode = request.plant_code || null
      const projectCode = request.project_code || null
      const costCenterCode = request.cost_center || null
      const wbsElementCode = request.wbs_element || null
      const activityCode = request.activity_code || null
      const storageLocationCode = request.storage_location || null

      // Validate required fields
      if (!companyCode) {
        return { success: false, error: 'Company code is required' }
      }
      if (!request.required_date) {
        return { success: false, error: 'Required date is required' }
      }

      // Generate request number using company code
      const requestNumber = this.generateRequestNumber(
        request.request_type || 'MATERIAL_REQ',
        companyCode
      )

      // Create main request with codes only (VARCHAR, no IDs)
      const { data: requestData, error: requestError } = await this.supabase
        .from('material_requests')
        .insert({
          request_number: requestNumber,
          request_type: request.request_type || 'MATERIAL_REQ',
          priority: request.priority,
          required_date: request.required_date,
          company_code: companyCode,
          plant_code: plantCode,
          project_code: projectCode,
          cost_center: costCenterCode,
          wbs_element: wbsElementCode,
          activity_code: activityCode,
          storage_location: storageLocationCode,
          purpose: request.purpose || null,
          justification: request.justification || null,
          notes: request.notes || null,
          requested_by: userId,
          created_by: userId,
          status: 'DRAFT'
        })
        .select()
        .single()

      if (requestError) throw requestError

      // Create request items
      if (request.items && request.items.length > 0) {
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
          delivery_date: item.delivery_date
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

  // Get material requests with filters - using codes only (VARCHAR, no IDs)
  async getMaterialRequests(filters: {
    request_type?: string
    status?: string
    requested_by?: string
    company_code?: string
    date_from?: string
    date_to?: string
  }): Promise<{ success: boolean; data?: any[]; error?: string }> {
    try {
      // Fetch requests with codes only
      let query = this.supabase
        .from('material_requests')
        .select('*')
        .order('created_at', { ascending: false })

      if (filters.request_type) query = query.eq('request_type', filters.request_type)
      if (filters.status) query = query.eq('status', filters.status)
      if (filters.requested_by) query = query.eq('requested_by', filters.requested_by)
      if (filters.company_code) query = query.eq('company_code', filters.company_code)
      if (filters.date_from) query = query.gte('required_date', filters.date_from)
      if (filters.date_to) query = query.lte('required_date', filters.date_to)

      const { data, error } = await query

      if (error) throw error

      // Fetch related data for display using codes
      const requestsWithDisplay = await Promise.all(
        (data || []).map(async (req) => {
          const [companyResult, plantResult, projectResult, costCenterResult] = await Promise.all([
            req.company_code ? this.supabase
              .from('company_codes')
              .select('company_code, company_name')
              .eq('company_code', req.company_code)
              .maybeSingle() : Promise.resolve({ data: null }),
            req.plant_code ? this.supabase
              .from('plants')
              .select('plant_code, plant_name')
              .eq('plant_code', req.plant_code)
              .maybeSingle() : Promise.resolve({ data: null }),
            req.project_code ? this.supabase
              .from('projects')
              .select('code, name')
              .eq('code', req.project_code)
              .maybeSingle() : Promise.resolve({ data: null }),
            req.cost_center ? this.supabase
              .from('cost_centers')
              .select('cost_center_code, cost_center_name')
              .eq('cost_center_code', req.cost_center)
              .maybeSingle() : Promise.resolve({ data: null })
          ])

          return {
            ...req,
            company_display: companyResult.data ? `${companyResult.data.company_code} - ${companyResult.data.company_name}` : req.company_code,
            plant_display: plantResult.data ? `${plantResult.data.plant_code} - ${plantResult.data.plant_name}` : req.plant_code,
            project_display: projectResult.data ? `${projectResult.data.code} - ${projectResult.data.name}` : req.project_code,
            cost_center_display: costCenterResult.data ? `${costCenterResult.data.cost_center_code} - ${costCenterResult.data.cost_center_name}` : req.cost_center
          }
        })
      )

      return { success: true, data: requestsWithDisplay }
    } catch (error) {
      console.error('Error fetching material requests:', error)
      return { success: false, error: error.message }
    }
  }

  // Get single material request by ID with all details including line items
  async getMaterialRequestById(requestId: string): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      // Fetch request (table uses VARCHAR codes, not IDs)
      const { data: request, error: requestError } = await this.supabase
        .from('material_requests')
        .select('*')
        .eq('id', requestId)
        .single()

      if (requestError) throw requestError

      // Debug: Log what codes are stored
      console.log('Request data from DB:', {
        id: request.id,
        request_number: request.request_number,
        company_code: request.company_code,
        plant_code: request.plant_code,
        project_code: request.project_code,
        cost_center: request.cost_center,
        wbs_element: request.wbs_element,
        storage_location: request.storage_location,
        activity_code: request.activity_code
      })

      // Fetch line items (using request_id)
      const { data: items, error: itemsError } = await this.supabase
        .from('material_request_items')
        .select('*')
        .eq('request_id', requestId)
        .order('line_number')

      if (itemsError) throw itemsError

      // Map line item fields to match component expectations
      const mappedItems = (items || []).map(item => ({
        ...item,
        requested_quantity: item.quantity || item.requested_quantity,
        base_uom: item.unit || item.base_uom,
        material_name: item.material_name || item.description || '-'
      }))

      // Fetch related data using codes only (VARCHAR, no IDs)

      const [companyResult, plantResult, storageLocationResult, projectResult, costCenterResult, wbsResult, activityResult] = await Promise.all([
        request.company_code ? this.supabase
          .from('company_codes')
          .select('company_code, company_name')
          .eq('company_code', request.company_code)
          .maybeSingle() : Promise.resolve({ data: null, error: null }),
        request.plant_code ? this.supabase
          .from('plants')
          .select('plant_code, plant_name')
          .eq('plant_code', request.plant_code)
          .maybeSingle() : Promise.resolve({ data: null, error: null }),
        request.storage_location ? this.supabase
          .from('storage_locations')
          .select('storage_location_code, storage_location_name')
          .eq('storage_location_code', request.storage_location)
          .maybeSingle() : Promise.resolve({ data: null, error: null }),
        request.project_code ? this.supabase
          .from('projects')
          .select('code, name')
          .eq('code', request.project_code)
          .maybeSingle() : Promise.resolve({ data: null, error: null }),
        request.cost_center ? this.supabase
          .from('cost_centers')
          .select('cost_center_code, cost_center_name')
          .eq('cost_center_code', request.cost_center)
          .maybeSingle() : Promise.resolve({ data: null, error: null }),
        request.wbs_element ? this.supabase
          .from('wbs_elements')
          .select('wbs_element, wbs_description')
          .eq('wbs_element', request.wbs_element)
          .maybeSingle() : Promise.resolve({ data: null, error: null }),
        request.activity_code ? this.supabase
          .from('activities')
          .select('code, name')
          .eq('code', request.activity_code)
          .maybeSingle() : Promise.resolve({ data: null, error: null })
      ])


      // Format the response with display values
      const formattedRequest = {
        ...request,
        items: mappedItems || [],
        // Add display values for better UI rendering
        company_display: companyResult.data 
          ? `${companyResult.data.company_code} - ${companyResult.data.company_name}` 
          : (request.company_code || '-'),
        plant_display: plantResult.data 
          ? `${plantResult.data.plant_code} - ${plantResult.data.plant_name}` 
          : (request.plant_code || '-'),
        storage_location_display: storageLocationResult.data 
          ? `${storageLocationResult.data.storage_location_code} - ${storageLocationResult.data.storage_location_name}` 
          : (request.storage_location || '-'),
        project_display: projectResult.data 
          ? `${projectResult.data.code} - ${projectResult.data.name}` 
          : (request.project_code || '-'),
        cost_center_display: costCenterResult.data 
          ? `${costCenterResult.data.cost_center_code} - ${costCenterResult.data.cost_center_name}` 
          : (request.cost_center || '-'),
        wbs_display: wbsResult.data 
          ? `${wbsResult.data.wbs_element} - ${wbsResult.data.wbs_description}` 
          : (request.wbs_element || '-'),
        activity_display: activityResult.data 
          ? `${activityResult.data.code} - ${activityResult.data.name}` 
          : (request.activity_code || '-'),
        requested_by_display: request.requested_by || null
      }

      // Fetch user name for requested_by_display
      if (formattedRequest.requested_by) {
        try {
          const { data: userProfile } = await this.supabase
            .from('users')
            .select('email, first_name, last_name')
            .eq('id', formattedRequest.requested_by)
            .maybeSingle()
          
          if (userProfile) {
            const fullName = userProfile.first_name && userProfile.last_name 
              ? `${userProfile.first_name} ${userProfile.last_name}`
              : userProfile.email
            formattedRequest.requested_by_display = fullName || formattedRequest.requested_by
          }
        } catch (userError) {
          // Silently fail - just use the ID if we can't get user info
          console.warn('Could not fetch user profile:', userError)
        }
      }

      // Debug: Log lookup results
      console.log('Lookup results:', {
        company: { code: request.company_code, found: !!companyResult.data, error: companyResult.error?.message, display: formattedRequest.company_display },
        plant: { code: request.plant_code, found: !!plantResult.data, error: plantResult.error?.message, display: formattedRequest.plant_display },
        project: { code: request.project_code, found: !!projectResult.data, error: projectResult.error?.message, display: formattedRequest.project_display },
        costCenter: { code: request.cost_center, found: !!costCenterResult.data, error: costCenterResult.error?.message, display: formattedRequest.cost_center_display },
        wbs: { code: request.wbs_element, found: !!wbsResult.data, error: wbsResult.error?.message, display: formattedRequest.wbs_display },
        storageLocation: { code: request.storage_location, found: !!storageLocationResult.data, error: storageLocationResult.error?.message, display: formattedRequest.storage_location_display },
        activity: { code: request.activity_code, found: !!activityResult.data, error: activityResult.error?.message, display: formattedRequest.activity_display }
      })

      // Log final formatted request for debugging
      console.log('Final formatted request:', {
        id: formattedRequest.id,
        request_number: formattedRequest.request_number,
        company_display: formattedRequest.company_display,
        plant_display: formattedRequest.plant_display,
        project_display: formattedRequest.project_display,
        cost_center_display: formattedRequest.cost_center_display,
        wbs_display: formattedRequest.wbs_display,
        storage_location_display: formattedRequest.storage_location_display,
        activity_display: formattedRequest.activity_display,
        required_date: formattedRequest.required_date,
        justification: formattedRequest.justification,
        itemsCount: formattedRequest.items?.length || 0
      })

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
  async deleteMaterialRequest(requestId: string): Promise<{ success: boolean; error?: string }> {
    try {
      // Check if request is in DRAFT status
      const { data: request, error: fetchError } = await this.supabase
        .from('material_requests')
        .select('status')
        .eq('id', requestId)
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

      if (itemsError) throw itemsError

      // Delete request
      const { error: deleteError } = await this.supabase
        .from('material_requests')
        .delete()
        .eq('id', requestId)

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
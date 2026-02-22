import { createClient } from '@/lib/supabase/client'
import { documentNumberingService } from '@/lib/services/documentNumberingService'
import { FlexibleApprovalService } from '@/domains/approval/FlexibleApprovalService'

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
  required_date?: string
  priority?: string
  // Account Assignment
  account_assignment_code?: string
  cost_center?: string
  wbs_element?: string
  activity_code?: string
  asset_number?: string
  order_number?: string
}

export interface MaterialRequest {
  id?: string
  request_number?: string
  mr_type?: string
  status?: string
  priority: string
  company_code: string
  plant_code?: string
  project_code?: string
  purpose?: string
  justification?: string
  notes?: string
  items: MaterialRequestItem[]
}

class MaterialRequestService {
  private supabase = createClient()

  async createMaterialRequest(request: any, userId: string, tenantId: string) {
    if (!request.company_code || !request.items?.length || !tenantId) {
      return { success: false, error: 'Missing required fields' }
    }

    try {
      console.log('Generating document number for company:', request.company_code, 'tenant:', tenantId)
      let requestNumber
      try {
        requestNumber = await documentNumberingService.generateDocumentNumber(
          'MATERIAL_REQ',
          request.company_code,
          tenantId
        )
        console.log('Generated request number:', requestNumber)
      } catch (numError: any) {
        console.error('Document number generation failed:', numError)
        return { success: false, error: `Failed to generate document number: ${numError.message}` }
      }
      
      if (!requestNumber) {
        return { success: false, error: 'Document number generation returned null' }
      }

      const status = request.submit ? 'SUBMITTED' : 'DRAFT'

      const { data: requestData, error: requestError } = await this.supabase
        .from('material_requests')
        .insert({
          request_number: requestNumber,
          request_type: request.mr_type,
          priority: request.priority || 'MEDIUM',
          company_code: request.company_code,
          requested_by: request.requested_by || userId,
          created_by: userId,
          tenant_id: tenantId,
          status: status
        })
        .select()
        .single()

      if (requestError) throw requestError

      const itemsToInsert = request.items.map((item: any, index: number) => ({
        request_id: requestData.id,
        line_number: item.line_number || index + 1,
        material_code: item.material_code,
        material_name: item.material_name,
        requested_quantity: item.requested_quantity,
        base_uom: item.base_uom,
        required_date: item.required_date,
        priority: item.priority,
        account_assignment_code: item.account_assignment_code,
        cost_center: item.cost_center,
        wbs_element: item.wbs_element,
        wbs_element_id: item.wbs_element_id,
        activity_code: item.activity_code,
        asset_number: item.asset_number,
        order_number: item.order_number,
        plant_code: item.plant_code,
        storage_location: item.storage_location,
        department_code: item.department_code,
        delivery_location: item.delivery_location,
        notes: item.notes,
        production_order_number: item.production_order_number,
        operation_number: item.operation_number,
        quality_order_number: item.quality_order_number,
        inspection_lot: item.inspection_lot,
        project_id: item.project_id,
        tenant_id: tenantId
      }))

      const { error: itemsError } = await this.supabase
        .from('material_request_items')
        .insert(itemsToInsert)

      if (itemsError) throw itemsError

      // Trigger workflow if submitted
      if (status === 'SUBMITTED') {
        // Get requester's department from org_hierarchy
        const { data: orgData } = await this.supabase
          .from('org_hierarchy')
          .select('department_code')
          .eq('employee_id', userId)
          .single()
        
        const workflowResult = await FlexibleApprovalService.createWorkflowInstance({
          object_type: 'MATERIAL_REQUEST',
          object_id: requestData.id,
          requester_id: userId,
          tenant_id: tenantId,
          context_data: {
            request_number: requestNumber,
            company_code: request.company_code,
            mr_type: request.mr_type,
            department_code: orgData?.department_code,
            amount: itemsToInsert.reduce((sum: number, item: any) => sum + (item.requested_quantity || 0), 0)
          }
        })
        
        if (!workflowResult.success) {
          console.error('Failed to create workflow:', workflowResult.message)
        }
      }

      return { success: true, data: requestData }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async getMaterialRequests(filters: any) {
    if (!filters.tenant_id) {
      return { success: false, error: 'Tenant ID required' }
    }

    try {
      let query = this.supabase
        .from('material_requests')
        .select('*')
        .eq('tenant_id', filters.tenant_id)
        .order('created_at', { ascending: false })

      if (filters.status) query = query.eq('status', filters.status)
      if (filters.mr_type) query = query.eq('request_type', filters.mr_type)

      const { data, error } = await query

      if (error) throw error

      return { success: true, data: data || [] }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async getMaterialRequestById(requestId: string, tenantId: string) {
    if (!tenantId) {
      return { success: false, error: 'Tenant ID required' }
    }

    try {
      const { data: request, error: requestError } = await this.supabase
        .from('material_requests')
        .select('*')
        .eq('id', requestId)
        .eq('tenant_id', tenantId)
        .single()

      if (requestError) throw requestError

      const { data: items, error: itemsError } = await this.supabase
        .from('material_request_items')
        .select('*')
        .eq('request_id', requestId)
        .eq('tenant_id', tenantId)
        .order('line_number')

      if (itemsError) throw itemsError

      return { success: true, data: { ...request, items: items || [] } }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async deleteMaterialRequest(requestId: string, tenantId: string) {
    if (!tenantId) {
      return { success: false, error: 'Tenant ID required' }
    }

    try {
      const { data: request, error: fetchError } = await this.supabase
        .from('material_requests')
        .select('status')
        .eq('id', requestId)
        .eq('tenant_id', tenantId)
        .single()

      if (fetchError) throw fetchError

      if (request.status !== 'DRAFT') {
        throw new Error('Only DRAFT requests can be deleted')
      }

      await this.supabase
        .from('material_request_items')
        .delete()
        .eq('request_id', requestId)
        .eq('tenant_id', tenantId)

      const { error: deleteError } = await this.supabase
        .from('material_requests')
        .delete()
        .eq('id', requestId)
        .eq('tenant_id', tenantId)

      if (deleteError) throw deleteError

      return { success: true }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async updateMaterialRequest(requestId: string, request: any, userId: string, tenantId: string) {
    if (!tenantId) {
      return { success: false, error: 'Tenant ID required' }
    }

    try {
      const { data: existingRequest, error: fetchError } = await this.supabase
        .from('material_requests')
        .select('status, request_number')
        .eq('id', requestId)
        .eq('tenant_id', tenantId)
        .single()

      if (fetchError) throw fetchError

      if (existingRequest.status !== 'DRAFT') {
        throw new Error('Only DRAFT requests can be edited')
      }

      const status = request.submit ? 'SUBMITTED' : 'DRAFT'

      const { data: requestData, error: requestError } = await this.supabase
        .from('material_requests')
        .update({
          request_type: request.mr_type,
          priority: request.priority || 'MEDIUM',
          company_code: request.company_code,
          requested_by: request.requested_by || userId,
          updated_by: userId,
          status: status
        })
        .eq('id', requestId)
        .eq('tenant_id', tenantId)
        .select()
        .single()

      if (requestError) throw requestError

      await this.supabase
        .from('material_request_items')
        .delete()
        .eq('request_id', requestId)
        .eq('tenant_id', tenantId)

      const itemsToInsert = request.items.map((item: any, index: number) => ({
        request_id: requestId,
        line_number: item.line_number || index + 1,
        material_code: item.material_code,
        material_name: item.material_name,
        requested_quantity: item.requested_quantity,
        base_uom: item.base_uom,
        required_date: item.required_date,
        priority: item.priority,
        account_assignment_code: item.account_assignment_code,
        cost_center: item.cost_center,
        wbs_element: item.wbs_element,
        wbs_element_id: item.wbs_element_id,
        activity_code: item.activity_code,
        asset_number: item.asset_number,
        order_number: item.order_number,
        plant_code: item.plant_code,
        storage_location: item.storage_location,
        department_code: item.department_code,
        delivery_location: item.delivery_location,
        notes: item.notes,
        production_order_number: item.production_order_number,
        operation_number: item.operation_number,
        quality_order_number: item.quality_order_number,
        inspection_lot: item.inspection_lot,
        project_id: item.project_id,
        tenant_id: tenantId
      }))

      const { error: itemsError } = await this.supabase
        .from('material_request_items')
        .insert(itemsToInsert)

      if (itemsError) throw itemsError

      // Trigger workflow if submitted
      if (status === 'SUBMITTED' && existingRequest.status === 'DRAFT') {
        // Get requester's department from org_hierarchy
        const { data: orgData } = await this.supabase
          .from('org_hierarchy')
          .select('department_code')
          .eq('employee_id', userId)
          .single()
        
        const workflowResult = await FlexibleApprovalService.createWorkflowInstance({
          object_type: 'MATERIAL_REQUEST',
          object_id: requestId,
          requester_id: userId,
          tenant_id: tenantId,
          context_data: {
            request_number: existingRequest.request_number,
            company_code: request.company_code,
            mr_type: request.mr_type,
            department_code: orgData?.department_code,
            amount: itemsToInsert.reduce((sum: number, item: any) => sum + (item.requested_quantity || 0), 0)
          }
        })
        
        if (!workflowResult.success) {
          console.error('Failed to create workflow:', workflowResult.message)
        }
      }

      return { success: true, data: { ...requestData, request_number: existingRequest.request_number } }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }

  async updateMaterialRequestStatus(requestId: string, status: string, userId: string, comments?: string, tenantId?: string) {
    try {
      const { error } = await this.supabase
        .from('material_requests')
        .update({
          status: status,
          updated_by: userId
        })
        .eq('id', requestId)

      if (error) throw error

      return { success: true }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  }
}

export const materialRequestService = new MaterialRequestService()

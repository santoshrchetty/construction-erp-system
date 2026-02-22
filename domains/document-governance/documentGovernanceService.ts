import { createClient } from '@/lib/supabase/server'

export interface DocumentRecord {
  id?: string
  document_number: string
  title: string
  description?: string
  document_type: 'DRAWING' | 'SPECIFICATION' | 'CONTRACT' | 'RFI' | 'SUBMITTAL' | 'CHANGE_ORDER' | 'OTHER'
  status: 'DRAFT' | 'UNDER_REVIEW' | 'APPROVED' | 'REJECTED' | 'SUPERSEDED'
  version: string
  revision?: string
  project_id?: string
  created_by: string
  created_at?: string
  updated_at?: string
  tenant_id: string
}

export interface DocumentSearchFilters {
  document_number?: string
  title?: string
  document_type?: string
  status?: string
  project_id?: string
  created_by?: string
  date_from?: string
  date_to?: string
}

export class DocumentGovernanceService {
  private supabase

  constructor() {
    this.supabase = createClient()
  }

  /**
   * Search and retrieve document records
   */
  async findDocuments(filters: DocumentSearchFilters = {}, tenantId: string) {
    try {
      let query = this.supabase
        .from('document_records')
        .select(`
          *,
          projects(project_name),
          users!created_by(email)
        `)
        .eq('tenant_id', tenantId)
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters.document_number) {
        query = query.ilike('document_number', `%${filters.document_number}%`)
      }
      if (filters.title) {
        query = query.ilike('title', `%${filters.title}%`)
      }
      if (filters.document_type) {
        query = query.eq('document_type', filters.document_type)
      }
      if (filters.status) {
        query = query.eq('status', filters.status)
      }
      if (filters.project_id) {
        query = query.eq('project_id', filters.project_id)
      }
      if (filters.created_by) {
        query = query.eq('created_by', filters.created_by)
      }
      if (filters.date_from) {
        query = query.gte('created_at', filters.date_from)
      }
      if (filters.date_to) {
        query = query.lte('created_at', filters.date_to)
      }

      const { data, error } = await query

      if (error) {
        throw new Error(`Failed to find documents: ${error.message}`)
      }

      return {
        success: true,
        data: data || [],
        count: data?.length || 0
      }
    } catch (error) {
      console.error('DocumentGovernanceService.findDocuments error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred',
        data: [],
        count: 0
      }
    }
  }

  /**
   * Create a new document record
   */
  async createDocument(documentData: Omit<DocumentRecord, 'id' | 'created_at' | 'updated_at'>) {
    try {
      // Generate document number if not provided
      if (!documentData.document_number) {
        documentData.document_number = await this.generateDocumentNumber(documentData.document_type, documentData.tenant_id)
      }

      const { data, error } = await this.supabase
        .from('document_records')
        .insert([{
          ...documentData,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }])
        .select()
        .single()

      if (error) {
        throw new Error(`Failed to create document: ${error.message}`)
      }

      return {
        success: true,
        data: data,
        message: `Document ${data.document_number} created successfully`
      }
    } catch (error) {
      console.error('DocumentGovernanceService.createDocument error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred'
      }
    }
  }

  /**
   * Update an existing document record
   */
  async changeDocument(id: string, updates: Partial<DocumentRecord>, tenantId: string) {
    try {
      const { data, error } = await this.supabase
        .from('document_records')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', id)
        .eq('tenant_id', tenantId)
        .select()
        .single()

      if (error) {
        throw new Error(`Failed to update document: ${error.message}`)
      }

      return {
        success: true,
        data: data,
        message: `Document ${data.document_number} updated successfully`
      }
    } catch (error) {
      console.error('DocumentGovernanceService.changeDocument error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred'
      }
    }
  }

  /**
   * Get a single document by ID
   */
  async getDocumentById(id: string, tenantId: string) {
    try {
      const { data, error } = await this.supabase
        .from('document_records')
        .select(`
          *,
          projects(project_name),
          users!created_by(email)
        `)
        .eq('id', id)
        .eq('tenant_id', tenantId)
        .single()

      if (error) {
        throw new Error(`Failed to get document: ${error.message}`)
      }

      return {
        success: true,
        data: data
      }
    } catch (error) {
      console.error('DocumentGovernanceService.getDocumentById error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred'
      }
    }
  }

  /**
   * Generate document number based on type and tenant
   */
  private async generateDocumentNumber(documentType: string, tenantId: string): Promise<string> {
    try {
      // Get the next number from sequence
      const { data, error } = await this.supabase
        .rpc('get_next_document_number', {
          p_document_type: documentType,
          p_tenant_id: tenantId
        })

      if (error) {
        // Fallback to timestamp-based number if RPC fails
        const timestamp = Date.now().toString().slice(-6)
        return `${documentType}-${timestamp}`
      }

      return data || `${documentType}-${Date.now().toString().slice(-6)}`
    } catch (error) {
      // Fallback to timestamp-based number
      const timestamp = Date.now().toString().slice(-6)
      return `${documentType}-${timestamp}`
    }
  }

  /**
   * Get document types for dropdown
   */
  getDocumentTypes() {
    return [
      { value: 'DRAWING', label: 'Drawing' },
      { value: 'SPECIFICATION', label: 'Specification' },
      { value: 'CONTRACT', label: 'Contract' },
      { value: 'RFI', label: 'RFI (Request for Information)' },
      { value: 'SUBMITTAL', label: 'Submittal' },
      { value: 'CHANGE_ORDER', label: 'Change Order' },
      { value: 'OTHER', label: 'Other' }
    ]
  }

  /**
   * Get document statuses for dropdown
   */
  getDocumentStatuses() {
    return [
      { value: 'DRAFT', label: 'Draft' },
      { value: 'UNDER_REVIEW', label: 'Under Review' },
      { value: 'APPROVED', label: 'Approved' },
      { value: 'REJECTED', label: 'Rejected' },
      { value: 'SUPERSEDED', label: 'Superseded' }
    ]
  }
}

export const documentGovernanceService = new DocumentGovernanceService()
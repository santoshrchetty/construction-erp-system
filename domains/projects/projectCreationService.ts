// Domain Layer - Project Creation Service
import { createClient } from '@/lib/supabase/client'

export interface CreateProjectRequest {
  name: string
  description?: string
  project_type: string
  start_date: string
  planned_end_date: string
  budget: number
  location?: string
  category: string
  company_code: string
  person_responsible_id: string
  cost_center_id: string
  profit_center_id: string
  plant_id: string
  working_days: number[]
  holidays: string[]
  selected_pattern: string
}

export interface ProjectNumberingRequest {
  entity_type: 'PROJECT' | 'WBS_ELEMENT' | 'ACTIVITY' | 'TASK'
  company_code?: string
  context?: Record<string, any>
}

export class ProjectCreationService {
  private supabase = createClient()
  private reservedSessionId?: string
  private reservedCode?: string

  async getNumberingPatterns(entityType: string, companyCode?: string): Promise<Array<{ id: string; pattern: string; description: string; entity_type: string }>> {
    let query = this.supabase
      .from('project_numbering_rules')
      .select('id, pattern, description, entity_type')
      .eq('entity_type', entityType)
      .eq('is_active', true)
      .order('created_at')
    
    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }
    
    const { data, error } = await query
    
    if (error) {
      throw new Error(`Failed to fetch numbering patterns: ${error.message}`)
    }
    
    return data || []
  }

  // COMMENTED OUT - Replaced by reserveProjectNumberWithPattern for actual creation
  // This method now only used for preview in forms
  async generateProjectNumberWithPattern(request: { entity_type: string; company_code: string; pattern: string }): Promise<string> {
    // Generate session ID for reservation
    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const { data, error } = await this.supabase
      .rpc('reserve_project_number_with_pattern', {
        p_entity_type: request.entity_type,
        p_company_code: request.company_code,
        p_pattern: request.pattern,
        p_session_id: sessionId
      })
    
    if (error) {
      throw new Error(`Failed to reserve project number: ${error.message}`)
    }
    
    // Store session ID for later consumption
    this.reservedSessionId = sessionId;
    this.reservedCode = data;
    
    return data
  }

  async reserveProjectNumberWithPattern(request: { entity_type: string; company_code: string; pattern: string }): Promise<string> {
    const { data, error } = await this.supabase
      .rpc('generate_project_number_with_pattern', {
        p_entity_type: request.entity_type,
        p_company_code: request.company_code,
        p_pattern: request.pattern
      })
    
    if (error) {
      throw new Error(`Failed to reserve project number: ${error.message}`)
    }
    
    return data
  }

  async createProject(request: CreateProjectRequest): Promise<{ id: string; code: string }> {
    try {
      // Use server-side API call with proper authentication
      const response = await fetch('/api/projects?action=create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          // Forward cookies for authentication
          'Cookie': typeof document !== 'undefined' ? document.cookie : ''
        },
        body: JSON.stringify({
          ...request,
          selected_pattern: request.selected_pattern
        }),
        credentials: 'include' // Include cookies
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.details || 'Failed to create project')
      }

      const result = await response.json()
      return result.data
    } catch (error) {
      throw error
    }
  }

  async getProjectCategories(): Promise<Array<{ category: string; prefix: string; description: string }>> {
    const { data, error } = await this.supabase
      .from('project_categories')
      .select('category_code, category_name')
      .eq('is_active', true)
      .order('sort_order')
    
    if (error) {
      throw new Error(`Failed to fetch project categories: ${error.message}`)
    }
    
    return (data || []).map(item => ({
      category: item.category_code,
      prefix: item.category_name,
      description: item.category_name
    }))
  }

  async getProjectTypes(categoryCode?: string): Promise<Array<{ type_code: string; type_name: string; category_code: string; description: string }>> {
    let query = this.supabase
      .from('project_types')
      .select('type_code, type_name, category_code, description')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })
    
    if (categoryCode) {
      query = query.eq('category_code', categoryCode)
    }
    
    const { data, error } = await query
    
    if (error) {
      throw new Error(`Failed to fetch project types: ${error.message}`)
    }
    
    return data || []
  }

  async getCompanyCodes(): Promise<Array<{ id: string; company_code: string; company_name: string }>> {
    const { data, error } = await this.supabase
      .from('company_codes')
      .select('id, company_code, company_name')
      .eq('is_active', true)
      .order('company_code')
    
    if (error) {
      throw new Error(`Failed to fetch company codes: ${error.message}`)
    }
    
    return data || []
  }

  async getPersonsResponsible(): Promise<Array<{ id: string; name: string; role: string; email?: string }>> {
    const { data, error } = await this.supabase
      .from('persons_responsible')
      .select('id, name, role, email')
      .order('name')
    
    if (error) {
      throw new Error(`Failed to fetch persons responsible: ${error.message}`)
    }
    
    return data || []
  }

  async getCostCenters(companyCode?: string): Promise<Array<{ id: string; cost_center_code: string; cost_center_name: string; department: string }>> {
    let query = this.supabase
      .from('cost_centers')
      .select('id, cost_center_code, cost_center_name, cost_center_type')
      .eq('is_active', true)
      .order('cost_center_code')
    
    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }
    
    const { data, error } = await query
    
    if (error) {
      throw new Error(`Failed to fetch cost centers: ${error.message}`)
    }
    
    return (data || []).map(item => ({
      id: item.id,
      cost_center_code: item.cost_center_code,
      cost_center_name: item.cost_center_name,
      department: item.cost_center_type || item.cost_center_name
    }))
  }

  async getProfitCenters(companyCode?: string): Promise<Array<{ id: string; profit_center_code: string; profit_center_name: string; division: string }>> {
    let query = this.supabase
      .from('profit_centers')
      .select('id, profit_center_code, profit_center_name, profit_center_type')
      .eq('is_active', true)
      .order('profit_center_code')
    
    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }
    
    const { data, error } = await query
    
    if (error) {
      throw new Error(`Failed to fetch profit centers: ${error.message}`)
    }
    
    return (data || []).map(item => ({
      id: item.id,
      profit_center_code: item.profit_center_code,
      profit_center_name: item.profit_center_name,
      division: item.profit_center_type || item.profit_center_name
    }))
  }

  async getPlants(companyCode?: string): Promise<Array<{ id: string; plant_code: string; plant_name: string; location: string }>> {
    let query = this.supabase
      .from('plants')
      .select('id, plant_code, plant_name, address')
      .eq('is_active', true)
      .order('plant_code')
    
    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }
    
    const { data, error } = await query
    
    if (error) {
      throw new Error(`Failed to fetch plants: ${error.message}`)
    }
    
    return (data || []).map(plant => ({
      id: plant.id,
      plant_code: plant.plant_code,
      plant_name: plant.plant_name,
      location: plant.address || ''
    }))
  }

  async addPersonResponsible(person: { first_name: string; last_name: string; email: string; role: string; company_code: string }): Promise<{ id: string; name: string; role: string; email: string }> {
    // Create user first
    const { data: userData, error: userError } = await this.supabase
      .from('users')
      .insert({
        first_name: person.first_name,
        last_name: person.last_name,
        email: person.email,
        is_active: true
      })
      .select('id')
      .single()
    
    if (userError) {
      throw new Error(`Failed to create user: ${userError.message}`)
    }
    
    // Get project_manager role ID
    const { data: roleData, error: roleError } = await this.supabase
      .from('roles')
      .select('id')
      .eq('name', 'project_manager')
      .single()
    
    if (roleError) {
      throw new Error(`Failed to get role: ${roleError.message}`)
    }
    
    // Assign role to user
    const { error: userRoleError } = await this.supabase
      .from('user_roles')
      .insert({
        user_id: userData.id,
        role_id: roleData.id
      })
    
    if (userRoleError) {
      throw new Error(`Failed to assign role: ${userRoleError.message}`)
    }
    
    return {
      id: userData.id,
      name: `${person.first_name} ${person.last_name}`,
      role: person.role,
      email: person.email
    }
  }
}
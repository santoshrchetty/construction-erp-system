// Repository Layer - WBS Data Access
import { createServiceClient } from '@/lib/supabase/server'

export class WBSRepository {
  // WBS Nodes
  async getWBSNodes(projectId: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('wbs_elements')
      .select('id, wbs_element, wbs_description, company_code, wbs_level, parent_wbs')
      .eq('project_code', projectId)
      .eq('is_active', true)
      .order('wbs_level', { ascending: true })
      .order('wbs_element', { ascending: true })
    
    if (error) throw error
    return (data || []).map(item => ({
      id: item.id,
      code: item.wbs_element,
      name: item.wbs_description,
      company_code: item.company_code,
      level: item.wbs_level,
      parent_id: item.parent_wbs
    }))
  }

  async createWBSNode(nodeData: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('wbs_nodes')
      .insert(nodeData)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async updateWBSNode(id: string, nodeData: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('wbs_nodes')
      .update(nodeData)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async deleteWBSNode(id: string) {
    const supabase = await createServiceClient()
    const { error } = await supabase
      .from('wbs_nodes')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }

  async getProjectCode(projectId: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('projects')
      .select('project_code')
      .eq('id', projectId)
      .single()
    
    if (error) throw error
    return data.project_code
  }

  async getProjectIdByCode(projectCode: string) {
    // Return the project code directly since wbs_elements uses project_code
    return projectCode
  }

  // Activities
  async getActivities(projectId: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('activities')
      .select('*')
      .eq('project_id', projectId)
      .order('created_at')
    
    if (error) throw error
    return data || []
  }

  async createActivity(activityData: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('activities')
      .insert(activityData)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async updateActivity(id: string, activityData: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('activities')
      .update(activityData)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async deleteActivity(id: string) {
    const supabase = await createServiceClient()
    const { error } = await supabase
      .from('activities')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }

  // Tasks
  async getTasks(projectId: string, activityId?: string) {
    const supabase = await createServiceClient()
    const query = supabase
      .from('tasks')
      .select('*')
      .eq('project_id', projectId)
    
    if (activityId) {
      query.eq('activity_id', activityId)
    }
    
    const { data, error } = await query.order('created_at')
    if (error) throw error
    return data || []
  }

  async createTask(taskData: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('tasks')
      .insert(taskData)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async updateTask(id: string, taskData: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('tasks')
      .update(taskData)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async deleteTask(id: string) {
    const supabase = await createServiceClient()
    const { error } = await supabase
      .from('tasks')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }

  // Vendors
  async getVendors() {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('vendors')
      .select('id, vendor_name, vendor_code')
      .eq('is_active', true)
    
    if (error) throw error
    return (data || []).map(v => ({ id: v.id, name: v.vendor_name, code: v.vendor_code }))
  }

  // Code Generation Helpers
  async getWBSNodeById(id: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('wbs_nodes')
      .select('code')
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data
  }

  async getWBSNodesByParent(projectId: string, parentId: string | null) {
    const supabase = await createServiceClient()
    const query = supabase
      .from('wbs_nodes')
      .select('id')
      .eq('project_id', projectId)
    
    if (parentId) {
      query.eq('parent_id', parentId)
    } else {
      query.is('parent_id', null)
    }
    
    const { data, error } = await query
    if (error) throw error
    return data || []
  }

  async getActivitiesByWBSNode(wbsNodeId: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('activities')
      .select('*')
      .eq('wbs_node_id', wbsNodeId)
      .order('code')
    
    if (error) throw error
    return data || []
  }
}

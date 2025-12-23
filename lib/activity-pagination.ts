// Activity pagination for large projects
import { supabase } from './supabase'

export interface ActivityFilters {
  status?: string
  priority?: string
  wbs_node_id?: string
  activity_type?: string
}

export async function getActivitiesPaginated(
  projectId: string,
  page: number = 1,
  pageSize: number = 50,
  filters: ActivityFilters = {}
) {
  let query = supabase
    .from('activities')
    .select(`
      *, 
      wbs_nodes(name),
      vendors(name)
    `, { count: 'exact' })
    .eq('project_id', projectId)

  // Apply filters
  if (filters.status) query = query.eq('status', filters.status)
  if (filters.priority) query = query.eq('priority', filters.priority)
  if (filters.wbs_node_id) query = query.eq('wbs_node_id', filters.wbs_node_id)
  if (filters.activity_type) query = query.eq('activity_type', filters.activity_type)

  // Pagination
  const from = (page - 1) * pageSize
  const to = from + pageSize - 1

  const { data, error, count } = await query
    .range(from, to)
    .order('planned_start_date')

  return {
    data: data || [],
    error,
    totalCount: count || 0,
    totalPages: Math.ceil((count || 0) / pageSize),
    currentPage: page
  }
}
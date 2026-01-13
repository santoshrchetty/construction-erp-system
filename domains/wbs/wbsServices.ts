// WBS Services - Domain Layer
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing Supabase environment variables')
}

const supabase = createClient(supabaseUrl, supabaseKey)

export async function getProjects(companyCode: string = 'C001') {
  try {
    const { data, error } = await supabase
      .from('projects')
      .select('id, code, name, status')
      .order('code')

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error getting projects:', error)
    return []
  }
}

export async function getWBSElements(projectCode: string, companyCode: string = 'C001') {
  try {
    const { data, error } = await supabase
      .from('universal_journal')
      .select(`
        wbs_element,
        debit_credit,
        company_amount,
        posting_date
      `)
      .eq('company_code', companyCode)
      .eq('project_code', projectCode)
      .not('wbs_element', 'is', null)
      .order('posting_date', { ascending: false })

    if (error) throw error

    // Group by WBS element
    const wbsSummary = data.reduce((acc, entry) => {
      const wbs = entry.wbs_element
      if (!acc[wbs]) {
        acc[wbs] = {
          wbs_element: wbs,
          wbs_description: null,
          total_debits: 0,
          total_credits: 0,
          net_amount: 0,
          transaction_count: 0,
          last_posting_date: entry.posting_date
        }
      }

      acc[wbs].transaction_count++
      if (entry.debit_credit === 'D') {
        acc[wbs].total_debits += parseFloat(entry.company_amount)
      } else {
        acc[wbs].total_credits += parseFloat(entry.company_amount)
      }
      acc[wbs].net_amount = acc[wbs].total_debits - acc[wbs].total_credits

      return acc
    }, {})

    return Object.values(wbsSummary)
  } catch (error) {
    console.error('Error getting WBS elements:', error)
    return []
  }
}

// WBS Nodes CRUD
export async function getWBSNodes(projectId: string) {
  try {
    const { data, error } = await supabase
      .from('wbs_nodes')
      .select('*')
      .eq('project_id', projectId)
      .order('level', { ascending: true })
      .order('sequence_order', { ascending: true })

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error getting WBS nodes:', error)
    return []
  }
}

export async function createWBSNode(nodeData: any) {
  try {
    const { data, error } = await supabase
      .from('wbs_nodes')
      .insert(nodeData)
      .select()
      .single()

    if (error) throw error
    return data
  } catch (error) {
    console.error('Error creating WBS node:', error)
    throw error
  }
}

export async function updateWBSNode(id: string, nodeData: any) {
  try {
    const { data, error } = await supabase
      .from('wbs_nodes')
      .update(nodeData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  } catch (error) {
    console.error('Error updating WBS node:', error)
    throw error
  }
}

export async function deleteWBSNode(id: string) {
  try {
    const { error } = await supabase
      .from('wbs_nodes')
      .delete()
      .eq('id', id)

    if (error) throw error
    return { success: true }
  } catch (error) {
    console.error('Error deleting WBS node:', error)
    throw error
  }
}

// Activities CRUD
export async function getActivities(projectId: string) {
  try {
    const { data, error } = await supabase
      .from('activities')
      .select('*')
      .eq('project_id', projectId)
      .order('created_at')

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error getting activities:', error)
    return []
  }
}

export async function createActivity(activityData: any) {
  try {
    const { data, error } = await supabase
      .from('activities')
      .insert(activityData)
      .select()
      .single()

    if (error) throw error
    return data
  } catch (error) {
    console.error('Error creating activity:', error)
    throw error
  }
}

export async function updateActivity(id: string, activityData: any) {
  try {
    const { data, error } = await supabase
      .from('activities')
      .update(activityData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  } catch (error) {
    console.error('Error updating activity:', error)
    throw error
  }
}

export async function deleteActivity(id: string) {
  try {
    const { error } = await supabase
      .from('activities')
      .delete()
      .eq('id', id)

    if (error) throw error
    return { success: true }
  } catch (error) {
    console.error('Error deleting activity:', error)
    throw error
  }
}

// Tasks CRUD
export async function getTasks(projectId: string) {
  try {
    const { data, error } = await supabase
      .from('tasks')
      .select('*')
      .eq('project_id', projectId)
      .order('created_at')

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error getting tasks:', error)
    return []
  }
}

export async function createTask(taskData: any) {
  try {
    const { data, error } = await supabase
      .from('tasks')
      .insert(taskData)
      .select()
      .single()

    if (error) throw error
    return data
  } catch (error) {
    console.error('Error creating task:', error)
    throw error
  }
}

export async function updateTask(id: string, taskData: any) {
  try {
    const { data, error } = await supabase
      .from('tasks')
      .update(taskData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  } catch (error) {
    console.error('Error updating task:', error)
    throw error
  }
}

export async function deleteTask(id: string) {
  try {
    const { error } = await supabase
      .from('tasks')
      .delete()
      .eq('id', id)

    if (error) throw error
    return { success: true }
  } catch (error) {
    console.error('Error deleting task:', error)
    throw error
  }
}

// Vendors
export async function getVendors() {
  try {
    const { data, error } = await supabase
      .from('vendors')
      .select('id, vendor_name as name, vendor_code as code')
      .eq('is_active', true)
      .order('vendor_name')

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error getting vendors:', error)
    return []
  }
}
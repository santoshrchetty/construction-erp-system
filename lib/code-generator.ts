// Code Generator Utilities
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing Supabase environment variables')
}

const supabase = createClient(supabaseUrl, supabaseKey)

export async function generateActivityCode(projectId: string, wbsNodeId: string): Promise<string> {
  try {
    // Get WBS node code
    const { data: wbsNode } = await supabase
      .from('wbs_nodes')
      .select('code')
      .eq('id', wbsNodeId)
      .single()

    if (!wbsNode) {
      throw new Error('WBS node not found')
    }

    // Get existing activities for this WBS node
    const { data: activities } = await supabase
      .from('activities')
      .select('code')
      .eq('wbs_node_id', wbsNodeId)
      .order('code')

    // Generate next activity code
    const activityCount = activities?.length || 0
    const nextSequence = activityCount + 1
    
    return `${wbsNode.code}-A${nextSequence.toString().padStart(2, '0')}`
  } catch (error) {
    console.error('Error generating activity code:', error)
    return 'ACT-001'
  }
}

export async function generateWBSCode(projectId: string, parentId?: string): Promise<string> {
  try {
    // Get project code
    const { data: project } = await supabase
      .from('projects')
      .select('code')
      .eq('id', projectId)
      .single()

    if (!project) {
      throw new Error('Project not found')
    }

    if (parentId) {
      // Child node: use parent code + sequence
      const { data: parentNode } = await supabase
        .from('wbs_nodes')
        .select('code')
        .eq('id', parentId)
        .single()

      if (!parentNode) {
        throw new Error('Parent WBS node not found')
      }

      const { data: siblings } = await supabase
        .from('wbs_nodes')
        .select('id')
        .eq('parent_id', parentId)

      const nextSequence = (siblings?.length || 0) + 1
      return `${parentNode.code}.${nextSequence.toString().padStart(2, '0')}`
    } else {
      // Root node: use project code + sequence
      const { data: rootNodes } = await supabase
        .from('wbs_nodes')
        .select('id')
        .eq('project_id', projectId)
        .is('parent_id', null)

      const nextSequence = (rootNodes?.length || 0) + 1
      return `${project.code}.${nextSequence.toString().padStart(2, '0')}`
    }
  } catch (error) {
    console.error('Error generating WBS code:', error)
    return 'WBS-001'
  }
}
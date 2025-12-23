// Activity code generation utilities
import { supabase } from './supabase'

export interface CodeGenerationOptions {
  format?: 'hierarchical' | 'sequential' | 'primavera' | 'sap'
  includePhase?: boolean
  maxLength?: number
}

export async function generateActivityCode(
  projectId: string, 
  wbsNodeId: string, 
  options: CodeGenerationOptions = { format: 'hierarchical' }
): Promise<string> {
  try {
    // Get project code
    const { data: project } = await supabase
      .from('projects')
      .select('code')
      .eq('id', projectId)
      .single()

    // Get WBS node code
    const { data: wbsNode } = await supabase
      .from('wbs_nodes')
      .select('code')
      .eq('id', wbsNodeId)
      .single()

    // Get next activity sequence for this WBS node - count all activities for this WBS node
    const { data: activities } = await supabase
      .from('activities')
      .select('code')
      .eq('wbs_node_id', wbsNodeId)

    // Count existing activities and generate next sequence
    const nextSequence = (activities?.length || 0) + 1
    
    console.log(`Generating code for WBS ${wbsNode?.code}: Found ${activities?.length || 0} existing activities, next sequence: ${nextSequence}`)
    
    switch (options.format) {
      case 'primavera':
        return generatePrimaveraCode(project?.code || 'PROJ', nextSequence)
      
      case 'sap':
        return generateSAPCode(project?.code || 'PROJ', wbsNode?.code || '001', nextSequence)
      
      case 'sequential':
        return generateSequentialCode(project?.code || 'PROJ', nextSequence)
      
      default: // hierarchical
        const sequenceStr = nextSequence.toString().padStart(3, '0')
        // Check if WBS code already contains project code to avoid duplication
        const wbsCode = wbsNode?.code || '001'
        if (wbsCode.startsWith(project?.code || '')) {
          // WBS code already has project code: AIR-25-03.02
          return `${wbsCode}-A${sequenceStr}`
        } else {
          // WBS code is just the node part: 03.02
          return `${project?.code}-${wbsCode}-A${sequenceStr}`
        }
    }
  } catch (error) {
    console.error('Error generating activity code:', error)
    return options.format === 'sap' ? 'PROJ.001.001' : 
           options.format === 'primavera' ? 'PROJ001' :
           options.format === 'sequential' ? 'PROJ-001' : 'ACT-001'
  }
}

function generatePrimaveraCode(projectCode: string, sequence: number): string {
  // Primavera style: PROJ001, PROJ002
  return `${projectCode}${sequence.toString().padStart(3, '0')}`
}

function generateSAPCode(projectCode: string, wbsCode: string, sequence: number): string {
  // SAP style: PROJ.001.001
  const networkCode = wbsCode.replace(/[.-]/g, '').padStart(3, '0')
  const activityCode = sequence.toString().padStart(3, '0')
  return `${projectCode}.${networkCode}.${activityCode}`
}

function generateSequentialCode(projectCode: string, sequence: number): string {
  // Simple sequential: PROJ-001
  return `${projectCode}-${sequence.toString().padStart(3, '0')}`
}

export function validateActivityCode(code: string, format: string = 'hierarchical'): boolean {
  switch (format) {
    case 'primavera':
      return /^[A-Z0-9]+[0-9]{3}$/.test(code)
    case 'sap':
      return /^[A-Z0-9]+\.[0-9]{3}\.[0-9]{3}$/.test(code)
    case 'sequential':
      return /^[A-Z0-9]+-[0-9]{3}$/.test(code)
    default:
      return /^[A-Z0-9]+-[0-9.]+[A-Z]*-A[0-9]{3}$/.test(code)
  }
}

// Get max activities based on format
export function getMaxActivitiesPerNode(format: string): number {
  switch (format) {
    case 'primavera': return 999999 // Very high limit
    case 'sap': return 999 // Per network
    case 'sequential': return 999
    default: return 999 // Per WBS node
  }
}
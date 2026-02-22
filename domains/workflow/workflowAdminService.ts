// Layer 2: Business Logic - domains/workflow/workflowAdminService.ts
import { WorkflowRepository } from './workflowRepository'

export class WorkflowAdminService {
  static async createWorkflowStep(data: {
    workflow_id: string
    step_sequence: number
    step_code: string
    step_name: string
    completion_rule: 'ANY' | 'ALL' | 'MIN_N'
    min_approvals?: number
  }) {
    if (!data.workflow_id || !data.step_sequence || !data.step_code || !data.step_name) {
      throw new Error('Missing required fields')
    }

    return await WorkflowRepository.createWorkflowStep(data)
  }

  static async updateWorkflowStep(stepId: string, updates: {
    step_name?: string
    completion_rule?: 'ANY' | 'ALL' | 'MIN_N'
    min_approvals?: number
  }) {
    if (!stepId) {
      throw new Error('Step ID required')
    }

    return await WorkflowRepository.updateWorkflowStep(stepId, updates)
  }

  static async addStepAgent(data: {
    workflow_step_id: string
    agent_rule_code: string
  }) {
    if (!data.workflow_step_id || !data.agent_rule_code) {
      throw new Error('Missing required fields')
    }

    return await WorkflowRepository.createStepAgent(data)
  }

  static async removeStepAgent(stepAgentId: string) {
    if (!stepAgentId) {
      throw new Error('Step agent ID required')
    }

    return await WorkflowRepository.deleteStepAgent(stepAgentId)
  }
}

// Layer 2: Business Logic - domains/workflow/roleAssignmentService.ts
import { WorkflowRepository } from './workflowRepository'

export class RoleAssignmentService {
  static async getRoleAssignments(roleCode?: string) {
    return await WorkflowRepository.getRoleAssignments(roleCode)
  }

  static async createRoleAssignment(data: {
    employee_id: string
    role_code: string
    scope_type?: string
    scope_value?: string
    tenant_id: string
  }) {
    if (!data.employee_id || !data.role_code || !data.tenant_id) {
      throw new Error('Missing required fields')
    }
    return await WorkflowRepository.createRoleAssignment(data)
  }

  static async deleteRoleAssignment(id: string) {
    if (!id) throw new Error('ID required')
    return await WorkflowRepository.deleteRoleAssignment(id)
  }
}

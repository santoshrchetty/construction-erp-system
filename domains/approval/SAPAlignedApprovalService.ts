// Layer 2: Business Logic Layer - domains/approval/FlexibleApprovalService.ts
import { WorkflowRepository } from '../../data/WorkflowRepository';

export class FlexibleApprovalService {
  private static validateInput(input: any): void {
    if (!input || typeof input !== 'object') {
      throw new Error('Invalid input data');
    }
  }

  private static sanitizeInput(input: any): any {
    if (typeof input === 'string') {
      return input.trim().substring(0, 1000);
    }
    if (typeof input === 'object' && input !== null) {
      const sanitized: any = {};
      Object.keys(input).forEach(key => {
        if (typeof input[key] === 'string') {
          sanitized[key] = input[key].trim().substring(0, 1000);
        } else {
          sanitized[key] = input[key];
        }
      });
      return sanitized;
    }
    return input;
  }

  // Business logic: Get workflow definitions with validation
  static async getWorkflowDefinitions(objectType?: string) {
    console.log('Business layer: Getting workflow definitions for object type:', objectType);
    
    try {
      if (objectType && typeof objectType !== 'string') {
        throw new Error('Invalid object type');
      }

      const workflows = await WorkflowRepository.getWorkflowDefinitions(objectType);
      return workflows;
    } catch (error) {
      console.error('Business layer error fetching workflow definitions:', error);
      throw new Error(error instanceof Error ? error.message : 'Failed to fetch workflow definitions');
    }
  }

  // Business logic: Get workflow steps with agent resolution
  static async getWorkflowSteps(workflowId: string) {
    console.log('Business layer: Getting workflow steps for workflow:', workflowId);
    
    try {
      if (!workflowId || typeof workflowId !== 'string') {
        throw new Error('Invalid workflow ID');
      }

      const steps = await WorkflowRepository.getWorkflowSteps(workflowId);
      return steps;
    } catch (error) {
      console.error('Business layer error fetching workflow steps:', error);
      throw new Error(error instanceof Error ? error.message : 'Failed to fetch workflow steps');
    }
  }

  // Business logic: Create workflow instance with policy selection
  static async createWorkflowInstance(data: {
    object_type: string;
    object_id: string;
    requester_id: string;
    context_data: any;
  }): Promise<{ success: boolean; instance?: any; message?: string }> {
    console.log('Business layer: Creating workflow instance:', data);
    
    try {
      this.validateInput(data);
      const sanitizedData = this.sanitizeInput(data);
      
      if (!sanitizedData.object_type || !sanitizedData.object_id || !sanitizedData.requester_id) {
        return { success: false, message: 'Missing required fields: object_type, object_id, requester_id' };
      }

      // 1. Find matching workflow
      const workflows = await WorkflowRepository.getWorkflowDefinitions(sanitizedData.object_type);
      const workflow = this.selectWorkflow(workflows, sanitizedData.context_data);
      
      if (!workflow) {
        return { success: false, message: 'No matching workflow found' };
      }

      // 2. Create workflow instance
      const instance = await WorkflowRepository.createWorkflowInstance({
        workflow_id: workflow.id,
        object_type: sanitizedData.object_type,
        object_id: sanitizedData.object_id,
        requester_id: sanitizedData.requester_id,
        context_data: sanitizedData.context_data
      });

      // 3. Initialize first step
      await this.initializeStep(instance.id, 1);

      return { success: true, instance };
    } catch (error) {
      console.error('Business layer error creating workflow instance:', error);
      return { success: false, message: error instanceof Error ? error.message : 'Failed to create workflow instance' };
    }
  }

  // Business logic: Select best matching workflow based on activation conditions
  private static selectWorkflow(workflows: any[], contextData: any): any | null {
    if (workflows.length === 0) return null;
    if (workflows.length === 1) return workflows[0];

    // Score workflows based on activation conditions
    const scoredWorkflows = workflows.map(workflow => ({
      workflow,
      score: this.scoreWorkflow(workflow, contextData)
    }));

    scoredWorkflows.sort((a, b) => b.score - a.score);
    return scoredWorkflows[0].workflow;
  }

  // Business logic: Score workflow based on how well it matches context
  private static scoreWorkflow(workflow: any, contextData: any): number {
    if (!workflow.activation_conditions) return 1; // Default workflow

    let score = 0;
    const conditions = workflow.activation_conditions;

    // Amount-based scoring
    if (conditions.amount_min !== undefined && contextData.amount >= conditions.amount_min) score += 10;
    if (conditions.amount_max !== undefined && contextData.amount <= conditions.amount_max) score += 10;

    // Material type scoring
    if (conditions.material_type && contextData.material_type === conditions.material_type) score += 20;

    // Emergency priority
    if (conditions.priority === 'EMERGENCY' && contextData.material_type === 'EMERGENCY') score += 50;

    return score;
  }

  // Business logic: Initialize workflow step with agent resolution
  private static async initializeStep(instanceId: string, stepSequence: number): Promise<void> {
    try {
      // Get workflow instance
      const activeWorkflows = await SAPWorkflowRepository.getActiveWorkflows();
      const instance = activeWorkflows.find(w => w.id === instanceId);
      
      if (!instance) return;

      // Get step definition
      const steps = await SAPWorkflowRepository.getWorkflowSteps(instance.workflow_id);
      const step = steps.find(s => s.step_sequence === stepSequence);
      
      if (!step) return;

      // Resolve agents for this step
      const agents = await this.resolveStepAgents(step, instance.context_data);

      // Create step instances for each agent
      for (const agent of agents) {
        await SAPWorkflowRepository.createStepInstance({
          workflow_instance_id: instanceId,
          workflow_step_id: step.id,
          step_sequence: stepSequence,
          assigned_agent_id: agent.agent_id,
          assigned_agent_name: agent.agent_name,
          assigned_agent_role: agent.agent_role,
          timeout_at: new Date(Date.now() + 48 * 60 * 60 * 1000) // 48 hours
        });
      }
    } catch (error) {
      console.error('Business layer error initializing step:', error);
    }
  }

  // Business logic: Resolve agents for a workflow step
  private static async resolveStepAgents(step: any, contextData: any): Promise<any[]> {
    const agents = [];

    for (const stepAgent of step.step_agents || []) {
      const rule = stepAgent.agent_rules;
      if (rule) {
        const resolvedAgents = await this.applyAgentRule(rule, contextData);
        agents.push(...resolvedAgents);
      }
    }

    return agents;
  }

  // Business logic: Apply agent resolution rule
  private static async applyAgentRule(rule: any, contextData: any): Promise<any[]> {
    try {
      switch (rule.rule_type) {
        case 'HIERARCHY':
          return await this.resolveHierarchyRule(rule, contextData);
        case 'ROLE':
          return await this.resolveRoleRule(rule, contextData);
        case 'RESPONSIBILITY':
          return await this.resolveResponsibilityRule(rule, contextData);
        default:
          return [];
      }
    } catch (error) {
      console.error('Business layer error applying agent rule:', error);
      return [];
    }
  }

  // Business logic: Resolve hierarchy-based agents
  private static async resolveHierarchyRule(rule: any, contextData: any): Promise<any[]> {
    const hierarchy = await SAPWorkflowRepository.getOrganizationalHierarchy();

    // Find requester
    const requester = hierarchy.find(emp => emp.employee_id === contextData.requester_id);
    if (!requester) return [];

    // Get manager
    const manager = hierarchy.find(emp => emp.employee_id === requester.manager_id);
    if (!manager) return [];

    return [{
      agent_id: manager.employee_id,
      agent_name: manager.employee_name,
      agent_role: manager.position_title
    }];
  }

  // Business logic: Resolve role-based agents
  private static async resolveRoleRule(rule: any, contextData: any): Promise<any[]> {
    const logic = rule.resolution_logic;
    const roleAssignments = await SAPWorkflowRepository.getRoleAssignments(logic.role_code);

    // Filter by scope if specified
    let filteredAssignments = roleAssignments;
    if (logic.scope_filter) {
      filteredAssignments = roleAssignments.filter(assignment => {
        if (logic.scope_filter.plant_code && assignment.scope_value !== contextData.plant_code) return false;
        if (logic.scope_filter.department_code && assignment.scope_value !== contextData.department_code) return false;
        return true;
      });
    }

    return filteredAssignments.map(assignment => ({
      agent_id: assignment.employee_id,
      agent_name: assignment.org_hierarchy?.employee_name,
      agent_role: assignment.role_code
    }));
  }

  // Business logic: Resolve responsibility-based agents
  private static async resolveResponsibilityRule(rule: any, contextData: any): Promise<any[]> {
    const logic = rule.resolution_logic;
    const responsibilities = await SAPWorkflowRepository.getResponsibilityAssignments(logic.responsibility_code);

    return responsibilities.map(resp => ({
      agent_id: resp.employee_id,
      agent_name: resp.org_hierarchy?.employee_name,
      agent_role: resp.responsibility_code
    }));
  }

  // Business logic: Get active workflows with filtering
  static async getActiveWorkflows(filters?: any) {
    console.log('Business layer: Getting active workflows with filters:', filters);
    
    try {
      const sanitizedFilters = filters ? this.sanitizeInput(filters) : {};
      const workflows = await SAPWorkflowRepository.getActiveWorkflows(sanitizedFilters);
      return workflows;
    } catch (error) {
      console.error('Business layer error fetching active workflows:', error);
      throw new Error(error instanceof Error ? error.message : 'Failed to fetch active workflows');
    }
  }

  // Business logic: Get pending approvals for agent
  static async getPendingApprovals(agentId: string) {
    console.log('Business layer: Getting pending approvals for agent:', agentId);
    
    try {
      if (!agentId || typeof agentId !== 'string') {
        throw new Error('Invalid agent ID');
      }

      const approvals = await SAPWorkflowRepository.getPendingApprovals(agentId);
      return approvals;
    } catch (error) {
      console.error('Business layer error fetching pending approvals:', error);
      throw new Error(error instanceof Error ? error.message : 'Failed to fetch pending approvals');
    }
  }

  // Business logic: Process approval action with step completion check
  static async processApproval(
    stepInstanceId: string, 
    action: 'APPROVE' | 'REJECT', 
    comments?: string
  ): Promise<{ success: boolean; message?: string }> {
    console.log('Business layer: Processing approval:', { stepInstanceId, action, comments });
    
    try {
      if (!stepInstanceId || !action) {
        return { success: false, message: 'Missing required parameters' };
      }

      // Update step instance
      const stepInstance = await SAPWorkflowRepository.updateStepInstance(stepInstanceId, {
        status: action === 'APPROVE' ? 'APPROVED' : 'REJECTED',
        comments: comments?.substring(0, 500)
      });

      // Check if step is complete
      const stepComplete = await this.checkStepCompletion(
        stepInstance.workflow_instance_id,
        stepInstance.step_sequence
      );

      if (stepComplete) {
        await this.advanceWorkflow(stepInstance.workflow_instance_id);
      }

      return { success: true, message: `Request ${action.toLowerCase()}d successfully` };
    } catch (error) {
      console.error('Business layer error processing approval:', error);
      return { success: false, message: error instanceof Error ? error.message : 'Failed to process approval' };
    }
  }

  // Business logic: Check if workflow step is complete based on completion rule
  private static async checkStepCompletion(instanceId: string, stepSequence: number): Promise<boolean> {
    try {
      const stepInstances = await SAPWorkflowRepository.getStepInstances(instanceId, stepSequence);
      
      if (!stepInstances || stepInstances.length === 0) return false;

      const step = stepInstances[0].workflow_steps;
      const approvedCount = stepInstances.filter(si => si.status === 'APPROVED').length;
      const rejectedCount = stepInstances.filter(si => si.status === 'REJECTED').length;
      const totalCount = stepInstances.length;

      switch (step.completion_rule) {
        case 'ALL':
          return approvedCount === totalCount;
        case 'ANY':
          return approvedCount > 0 || rejectedCount > 0;
        case 'MIN_N':
          return approvedCount >= (step.min_approvals || 1);
        default:
          return approvedCount > 0;
      }
    } catch (error) {
      console.error('Business layer error checking step completion:', error);
      return false;
    }
  }

  // Business logic: Advance workflow to next step
  private static async advanceWorkflow(instanceId: string): Promise<void> {
    try {
      const activeWorkflows = await SAPWorkflowRepository.getActiveWorkflows();
      const instance = activeWorkflows.find(w => w.id === instanceId);
      
      if (!instance) return;

      const nextStep = instance.current_step_sequence + 1;

      // Check if next step exists
      const steps = await SAPWorkflowRepository.getWorkflowSteps(instance.workflow_id);
      const nextStepDef = steps.find(s => s.step_sequence === nextStep);

      if (nextStepDef) {
        // Initialize next step
        await SAPWorkflowRepository.updateWorkflowInstance(instanceId, {
          current_step_sequence: nextStep
        });

        await this.initializeStep(instanceId, nextStep);
      } else {
        // Workflow complete
        await SAPWorkflowRepository.updateWorkflowInstance(instanceId, {
          status: 'COMPLETED'
        });
      }
    } catch (error) {
      console.error('Business layer error advancing workflow:', error);
    }
  }
}
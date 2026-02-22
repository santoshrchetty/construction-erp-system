// Layer 2: Business Logic Layer - domains/approval/FlexibleApprovalService.ts
import { WorkflowRepository } from '../workflow/workflowRepository';

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
    tenant_id?: string;
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
        tenant_id: sanitizedData.tenant_id,
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
      console.log('=== INITIALIZE STEP START ===', { instanceId, stepSequence });
      
      // Get workflow instance
      const activeWorkflows = await WorkflowRepository.getActiveWorkflows();
      const instance = activeWorkflows.find(w => w.id === instanceId);
      
      console.log('Found workflow instance:', instance ? 'YES' : 'NO');
      if (!instance) {
        console.error('Workflow instance not found:', instanceId);
        return;
      }

      // Get step definition
      const steps = await WorkflowRepository.getWorkflowSteps(instance.workflow_id);
      console.log('Loaded workflow steps:', steps.length);
      
      const step = steps.find(s => s.step_sequence === stepSequence);
      console.log('Found step definition:', step ? 'YES' : 'NO', step?.step_name);
      
      if (!step) {
        console.error('Step definition not found:', { workflowId: instance.workflow_id, stepSequence });
        return;
      }

      console.log('Step agents array:', step.step_agents);
      console.log('Step agents count:', step.step_agents?.length || 0);

      // Add requester_id to context_data for agent resolution
      const enrichedContext = {
        ...instance.context_data,
        requester_id: instance.requester_id
      };

      // Resolve agents for this step
      const agents = await this.resolveStepAgents(step, enrichedContext);
      console.log('Resolved agents:', agents.length, agents);

      if (agents.length === 0) {
        const errorMsg = `No agents resolved for step: ${stepSequence} (${step.step_name}). Check agent rules and context data.`;
        console.error(errorMsg);
        throw new Error(errorMsg);
      }

      // Create step instances for each agent
      for (const agent of agents) {
        console.log('Creating step instance for agent:', agent);
        await WorkflowRepository.createStepInstance({
          workflow_instance_id: instanceId,
          workflow_step_id: step.id,
          step_sequence: stepSequence,
          assigned_agent_id: agent.agent_id,
          assigned_agent_name: agent.agent_name,
          assigned_agent_role: agent.agent_role,
          timeout_at: new Date(Date.now() + 48 * 60 * 60 * 1000) // 48 hours
        });
        console.log('Step instance created successfully');
      }
      
      console.log('=== INITIALIZE STEP END ===');
    } catch (error) {
      console.error('Business layer error initializing step:', error);
      throw error;
    }
  }

  // Business logic: Resolve agents for a workflow step
  private static async resolveStepAgents(step: any, contextData: any): Promise<any[]> {
    console.log('=== RESOLVE STEP AGENTS START ===');
    console.log('Step:', step.step_name);
    console.log('Context data:', contextData);
    
    const agents = [];

    for (const stepAgent of step.step_agents || []) {
      console.log('Processing step agent:', stepAgent);
      const rule = stepAgent.agent_rules;
      console.log('Agent rule:', rule);
      
      if (rule) {
        const resolvedAgents = await this.applyAgentRule(rule, contextData);
        console.log('Resolved agents from rule:', resolvedAgents);
        agents.push(...resolvedAgents);
      } else {
        console.warn('No agent rule found for step agent:', stepAgent);
      }
    }

    console.log('=== RESOLVE STEP AGENTS END ===', agents);
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
    const hierarchy = await WorkflowRepository.getOrganizationalHierarchy();

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
    console.log('=== RESOLVE ROLE RULE START ===');
    console.log('Rule logic:', rule.resolution_logic);
    console.log('Context data:', contextData);
    
    const logic = rule.resolution_logic;
    const roleAssignments = await WorkflowRepository.getRoleAssignments(logic.role_code);
    console.log('Role assignments fetched:', roleAssignments.length);
    console.log('Sample assignment:', roleAssignments[0]);

    // Filter by scope if specified
    let filteredAssignments = roleAssignments;
    if (logic.scope_filter) {
      console.log('Applying scope filter:', logic.scope_filter);
      filteredAssignments = roleAssignments.filter(assignment => {
        if (logic.scope_filter.plant_code && assignment.scope_value !== contextData.plant_code) return false;
        if (logic.scope_filter.department_code && assignment.scope_value !== contextData.department_code) return false;
        return true;
      });
      console.log('Filtered assignments:', filteredAssignments.length);
    }

    const agents = filteredAssignments.map(assignment => ({
      agent_id: assignment.employee_id,
      agent_name: assignment.org_hierarchy?.employee_name,
      agent_role: assignment.role_code
    }));
    console.log('=== RESOLVE ROLE RULE END ===', agents);
    return agents;
  }

  // Business logic: Get active workflows with filtering
  static async getActiveWorkflows(filters?: any) {
    console.log('Business layer: Getting active workflows with filters:', filters);
    
    try {
      const sanitizedFilters = filters ? this.sanitizeInput(filters) : {};
      const workflows = await WorkflowRepository.getActiveWorkflows(sanitizedFilters);
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

      const approvals = await WorkflowRepository.getPendingApprovals(agentId);
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
      const stepInstance = await WorkflowRepository.updateStepInstance(stepInstanceId, {
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
      const stepInstances = await WorkflowRepository.getStepInstances(instanceId, stepSequence);
      
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
      const activeWorkflows = await WorkflowRepository.getActiveWorkflows();
      const instance = activeWorkflows.find(w => w.id === instanceId);
      
      if (!instance) {
        console.error('Workflow instance not found:', instanceId);
        return;
      }

      const nextStep = instance.current_step_sequence + 1;

      // Check if next step exists
      const steps = await WorkflowRepository.getWorkflowSteps(instance.workflow_id);
      const nextStepDef = steps.find(s => s.step_sequence === nextStep);

      if (nextStepDef) {
        // Initialize next step
        await WorkflowRepository.updateWorkflowInstance(instanceId, {
          current_step_sequence: nextStep
        });

        await this.initializeStep(instanceId, nextStep);
      } else {
        // Workflow complete - update material request status
        await WorkflowRepository.updateWorkflowInstance(instanceId, {
          status: 'COMPLETED'
        });
        
        // Update material request status to APPROVED
        if (instance.object_type === 'MATERIAL_REQUEST') {
          await this.updateMaterialRequestStatus(instance.object_id, 'APPROVED');
        }
      }
    } catch (error) {
      console.error('Business layer error advancing workflow:', { instanceId, error });
      throw error;
    }
  }

  // Update material request status after workflow completion
  private static async updateMaterialRequestStatus(requestId: string, status: string): Promise<void> {
    try {
      await WorkflowRepository.updateMaterialRequestStatus(requestId, status);
    } catch (error) {
      console.error('Failed to update material request status:', error);
    }
  }
}
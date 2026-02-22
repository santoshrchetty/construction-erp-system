// Layer 3: Data Access Layer - data/WorkflowRepository.ts
import { createClient } from '@supabase/supabase-js';

if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
  throw new Error('Missing required Supabase environment variables');
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

export interface WorkflowDefinition {
  id: string;
  workflow_code: string;
  workflow_name: string;
  object_type: string;
  activation_conditions: any;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface WorkflowStep {
  id: string;
  workflow_id: string;
  step_sequence: number;
  step_code: string;
  step_name: string;
  completion_rule: 'ALL' | 'ANY' | 'MIN_N';
  min_approvals?: number;
  is_active: boolean;
}

export interface WorkflowInstance {
  id: string;
  workflow_id: string;
  object_type: string;
  object_id: string;
  requester_id: string;
  tenant_id?: string;
  context_data: any;
  status: 'ACTIVE' | 'COMPLETED' | 'CANCELLED';
  current_step_sequence: number;
  created_at: string;
  updated_at?: string;
  completed_at?: string;
}

export class WorkflowRepository {
  // Data layer: Direct Supabase operations with validation
  static async getWorkflowDefinitions(objectType?: string): Promise<WorkflowDefinition[]> {
    try {
      let query = supabase
        .from('workflow_definitions')
        .select('*')
        .eq('is_active', true);
      
      if (objectType) {
        query = query.eq('object_type', objectType);
      }
      
      const { data, error } = await query
        .order('workflow_code')
        .limit(100);
      
      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get workflow definitions:', error);
      return [];
    }
  }

  static async getWorkflowSteps(workflowId: string): Promise<any[]> {
    if (!workflowId || typeof workflowId !== 'string') {
      throw new Error('Invalid workflow ID');
    }

    try {
      const { data, error } = await supabase
        .from('workflow_steps')
        .select(`
          *,
          step_agents (
            id,
            agent_rule_code,
            agent_rules (
              rule_name,
              rule_type,
              resolution_logic,
              description
            )
          )
        `)
        .eq('workflow_id', workflowId)
        .eq('is_active', true)
        .order('step_sequence');
      
      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get workflow steps:', error);
      return [];
    }
  }

  static async createWorkflowInstance(instance: Partial<WorkflowInstance>): Promise<WorkflowInstance> {
    if (!instance.workflow_id || !instance.object_type || !instance.object_id) {
      throw new Error('Missing required workflow instance fields');
    }

    const sanitizedInstance = {
      ...instance,
      status: 'ACTIVE',
      current_step_sequence: 1,
      created_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('workflow_instances')
      .insert(sanitizedInstance)
      .select()
      .single();
    
    if (error) throw new Error(`Failed to create workflow instance: ${error.message}`);
    return data;
  }

  static async getActiveWorkflows(filters?: any): Promise<any[]> {
    try {
      let query = supabase
        .from('workflow_instances')
        .select(`
          *,
          workflow_definitions (workflow_name, object_type)
        `)
        .eq('status', 'ACTIVE');

      if (filters?.object_type) {
        query = query.eq('object_type', filters.object_type);
      }

      const { data, error } = await query
        .order('created_at', { ascending: false })
        .limit(50);

      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get active workflows:', error);
      return [];
    }
  }

  static async createRoleAssignment(data: any): Promise<any> {
    const { data: assignment, error } = await supabase
      .from('role_assignments')
      .insert({ ...data, is_active: true })
      .select()
      .single()
    
    if (error) throw new Error(`Failed to create role assignment: ${error.message}`)
    return assignment
  }

  static async deleteRoleAssignment(id: string): Promise<void> {
    const { error } = await supabase
      .from('role_assignments')
      .delete()
      .eq('id', id)
    
    if (error) throw new Error(`Failed to delete role assignment: ${error.message}`)
  }

  static async getOrganizationalHierarchy(): Promise<any[]> {
    try {
      const { data, error } = await supabase
        .from('org_hierarchy')
        .select('*')
        .eq('is_active', true)
        .order('department_code')
        .order('position_title');
      
      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get organizational hierarchy:', error);
      return [];
    }
  }

  static async getRoleAssignments(roleCode?: string): Promise<any[]> {
    try {
      // Fetch role assignments
      let query = supabase
        .from('role_assignments')
        .select('*')
        .eq('is_active', true);

      if (roleCode) {
        query = query.eq('role_code', roleCode);
      }

      const { data: assignments, error: assignError } = await query
        .order('role_code')
        .order('employee_id');
      
      if (assignError) throw new Error(`Database error: ${assignError.message}`);
      if (!assignments || assignments.length === 0) return [];

      // Fetch org_hierarchy data for these employees
      const employeeIds = assignments.map(a => a.employee_id);
      const { data: employees, error: empError } = await supabase
        .from('org_hierarchy')
        .select('employee_id, employee_name, position_title, department_code, plant_code')
        .in('employee_id', employeeIds);
      
      if (empError) throw new Error(`Database error: ${empError.message}`);

      // Merge the data
      const employeeMap = new Map(employees?.map(e => [e.employee_id, e]) || []);
      return assignments.map(assignment => ({
        ...assignment,
        org_hierarchy: employeeMap.get(assignment.employee_id)
      }));
    } catch (error) {
      console.error('Failed to get role assignments:', error);
      return [];
    }
  }

  static async getResponsibilityAssignments(responsibilityCode?: string): Promise<any[]> {
    // Not implemented - use role_assignments instead
    return [];
  }

  static async createStepInstance(stepInstance: any): Promise<any> {
    if (!stepInstance.workflow_instance_id || !stepInstance.workflow_step_id) {
      throw new Error('Missing required step instance fields');
    }

    const sanitizedStepInstance = {
      ...stepInstance,
      assigned_agent_name: stepInstance.assigned_agent_name?.substring(0, 100),
      assigned_agent_role: stepInstance.assigned_agent_role?.substring(0, 100),
      status: 'PENDING',
      created_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('step_instances')
      .insert(sanitizedStepInstance)
      .select()
      .single();
    
    if (error) throw new Error(`Failed to create step instance: ${error.message}`);
    return data;
  }

  static async getPendingApprovals(agentId: string): Promise<any[]> {
    if (!agentId || typeof agentId !== 'string') {
      throw new Error('Invalid agent ID');
    }

    try {
      const { data, error } = await supabase
        .from('step_instances')
        .select(`
          *,
          workflow_instances (
            object_type,
            object_id,
            context_data,
            workflow_definitions (workflow_name)
          ),
          workflow_steps (step_name)
        `)
        .eq('assigned_agent_id', agentId)
        .eq('status', 'PENDING')
        .order('created_at');

      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get pending approvals:', error);
      return [];
    }
  }

  static async updateStepInstance(stepInstanceId: string, updates: any): Promise<any> {
    if (!stepInstanceId || !updates) {
      throw new Error('Step instance ID and updates required');
    }

    const sanitizedUpdates = {
      status: updates.status,
      comments: updates.comments?.substring(0, 500)
    };

    // First, update the step instance
    const { data: stepData, error: stepError } = await supabase
      .from('step_instances')
      .update(sanitizedUpdates)
      .eq('id', stepInstanceId)
      .select()
      .single();
    
    if (stepError) {
      console.error('Step instance update error:', stepError);
      throw new Error(`Failed to update step instance: ${stepError.message}`);
    }
    if (!stepData) {
      throw new Error('Step instance not found');
    }

    // Then fetch related data separately
    const { data: instanceData } = await supabase
      .from('workflow_instances')
      .select('*')
      .eq('id', stepData.workflow_instance_id)
      .single();

    const { data: stepDefData } = await supabase
      .from('workflow_steps')
      .select('*')
      .eq('id', stepData.workflow_step_id)
      .single();

    return {
      ...stepData,
      workflow_instances: instanceData,
      workflow_steps: stepDefData
    };
  }

  static async getStepInstances(instanceId: string, stepSequence: number): Promise<any[]> {
    if (!instanceId || typeof stepSequence !== 'number') {
      throw new Error('Invalid parameters for step instances query');
    }

    try {
      const { data, error } = await supabase
        .from('step_instances')
        .select(`
          *,
          workflow_steps (completion_rule, min_approvals)
        `)
        .eq('workflow_instance_id', instanceId)
        .eq('step_sequence', stepSequence);

      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get step instances:', error);
      return [];
    }
  }

  static async updateWorkflowInstance(instanceId: string, updates: any): Promise<WorkflowInstance> {
    if (!instanceId || !updates) {
      throw new Error('Instance ID and updates required');
    }

    const sanitizedUpdates = {
      ...updates,
      updated_at: new Date().toISOString()
    };

    if (updates.status === 'COMPLETED') {
      sanitizedUpdates.completed_at = new Date().toISOString();
    }

    const { data, error } = await supabase
      .from('workflow_instances')
      .update(sanitizedUpdates)
      .eq('id', instanceId)
      .select()
      .single();
    
    if (error) {
      console.error('Workflow instance update failed:', { instanceId, updates, error });
      throw new Error(`Failed to update workflow instance: ${error.message}`);
    }
    
    if (!data) {
      throw new Error(`Workflow instance not found: ${instanceId}`);
    }
    
    return data;
  }

  static async getAgentRules(): Promise<any[]> {
    try {
      const { data, error } = await supabase
        .from('agent_rules')
        .select('*')
        .eq('is_active', true)
        .order('rule_type')
        .order('rule_code');
      
      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get agent rules:', error);
      return [];
    }
  }

  // Workflow performance metrics
  static async getWorkflowMetrics(filters?: any): Promise<any[]> {
    try {
      let query = supabase
        .from('workflow_instances')
        .select(`
          workflow_id,
          status,
          created_at,
          completed_at,
          workflow_definitions (workflow_code, workflow_name)
        `);

      if (filters?.object_type) {
        query = query.eq('object_type', filters.object_type);
      }

      if (filters?.status) {
        query = query.eq('status', filters.status);
      }

      const { data, error } = await query
        .order('created_at', { ascending: false })
        .limit(100);

      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get workflow metrics:', error);
      return [];
    }
  }

  static async createWorkflowStep(data: any): Promise<any> {
    const { data: step, error } = await supabase
      .from('workflow_steps')
      .insert(data)
      .select()
      .single()
    
    if (error) throw new Error(`Failed to create step: ${error.message}`)
    return step
  }

  static async updateWorkflowStep(stepId: string, updates: any): Promise<any> {
    const { data: step, error } = await supabase
      .from('workflow_steps')
      .update(updates)
      .eq('id', stepId)
      .select()
      .single()
    
    if (error) throw new Error(`Failed to update step: ${error.message}`)
    return step
  }

  static async createStepAgent(data: any): Promise<any> {
    const { data: agent, error } = await supabase
      .from('step_agents')
      .insert(data)
      .select()
      .single()
    
    if (error) throw new Error(`Failed to create step agent: ${error.message}`)
    return agent
  }

  static async deleteStepAgent(stepAgentId: string): Promise<void> {
    const { error } = await supabase
      .from('step_agents')
      .delete()
      .eq('id', stepAgentId)
    
    if (error) throw new Error(`Failed to delete step agent: ${error.message}`)
  }

  static async updateMaterialRequestStatus(requestId: string, status: string): Promise<void> {
    if (!requestId || !status) {
      throw new Error('Request ID and status required');
    }

    const { error } = await supabase
      .from('material_requests')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', requestId);
    
    if (error) {
      console.error('Failed to update material request status:', error);
      throw new Error(`Failed to update material request status: ${error.message}`);
    }
  }
}
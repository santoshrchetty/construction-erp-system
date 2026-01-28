// Layer 3: Data Access Layer - data/SAPWorkflowRepository.ts
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
  context_data: any;
  status: 'ACTIVE' | 'COMPLETED' | 'CANCELLED';
  current_step_sequence: number;
  created_at: string;
  completed_at?: string;
}

export class SAPWorkflowRepository {
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
      object_id: instance.object_id?.substring(0, 50),
      requester_id: instance.requester_id?.substring(0, 20),
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
          workflow_definitions (workflow_name, object_type),
          org_hierarchy!workflow_instances_requester_id_fkey (employee_name)
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
      let query = supabase
        .from('role_assignments')
        .select(`
          *,
          org_hierarchy (
            employee_name,
            position_title,
            department_code,
            plant_code
          )
        `)
        .eq('is_active', true);

      if (roleCode) {
        query = query.eq('role_code', roleCode);
      }

      const { data, error } = await query
        .order('role_code')
        .order('employee_id');
      
      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get role assignments:', error);
      return [];
    }
  }

  static async getResponsibilityAssignments(responsibilityCode?: string): Promise<any[]> {
    try {
      let query = supabase
        .from('responsibility_assignments')
        .select(`
          *,
          org_hierarchy (
            employee_name,
            position_title,
            department_code,
            plant_code
          )
        `)
        .eq('is_active', true);

      if (responsibilityCode) {
        query = query.eq('responsibility_code', responsibilityCode);
      }

      const { data, error } = await query
        .order('responsibility_code')
        .order('employee_id');
      
      if (error) throw new Error(`Database error: ${error.message}`);
      return data || [];
    } catch (error) {
      console.error('Failed to get responsibility assignments:', error);
      return [];
    }
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
      ...updates,
      decision_date: new Date().toISOString(),
      comments: updates.comments?.substring(0, 500)
    };

    const { data, error } = await supabase
      .from('step_instances')
      .update(sanitizedUpdates)
      .eq('id', stepInstanceId)
      .select(`
        *,
        workflow_instances (*),
        workflow_steps (*)
      `)
      .single();
    
    if (error) throw new Error(`Failed to update step instance: ${error.message}`);
    return data;
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
    
    if (error) throw new Error(`Failed to update workflow instance: ${error.message}`);
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
}
// SAP-Aligned Parallel Approval Service
// Multiple agents per step with completion rules (ALL, ANY, MIN_N)

import { createServerSupabaseClient } from '@/lib/supabase/server'

export class SAPParallelApprovalService {
  
  // 1. INITIALIZE STEP WITH PARALLEL AGENTS
  private static async initializeStepWithAgents(instanceId: string, stepDef: any) {
    const supabase = await createServerSupabaseClient()
    
    // Get all agents for this step
    const { data: stepAgents } = await supabase
      .from('step_agents')
      .select('*')
      .eq('workflow_step_id', stepDef.id)
      .order('agent_sequence')
    
    if (!stepAgents || stepAgents.length === 0) {
      throw new Error(`No agents configured for step ${stepDef.step_code}`)
    }
    
    // Get workflow instance for context
    const { data: instance } = await supabase
      .from('workflow_instances')
      .select('*')
      .eq('id', instanceId)
      .single()
    
    // Create step completion tracker
    await supabase
      .from('step_completion_status')
      .insert({
        workflow_instance_id: instanceId,
        workflow_step_id: stepDef.id,
        step_sequence: stepDef.step_sequence,
        total_agents: stepAgents.length,
        pending_count: stepAgents.length,
        completion_rule: stepDef.completion_rule,
        min_approvals: stepDef.min_approvals
      })
    
    // Resolve and create step instances for each agent
    const stepInstances = []
    for (const stepAgent of stepAgents) {
      const agent = await this.resolveAgent(stepAgent.agent_rule, instance)
      
      if (agent) {
        const { data: stepInstance } = await supabase
          .from('step_instances')
          .insert({
            workflow_instance_id: instanceId,
            workflow_step_id: stepDef.id,
            step_agent_id: stepAgent.id,
            step_sequence: stepDef.step_sequence,
            assigned_agent_id: agent.employee_id,
            assigned_agent_name: agent.employee_name,
            assigned_agent_role: agent.position_title,
            status: 'PENDING',
            timeout_at: new Date(Date.now() + (stepDef.timeout_hours * 60 * 60 * 1000)).toISOString()
          })
          .select()
          .single()
        
        stepInstances.push(stepInstance)
      } else if (stepAgent.is_required) {
        throw new Error(`Cannot resolve required agent: ${stepAgent.agent_rule}`)
      }
    }
    
    return stepInstances
  }
  
  // 2. PROCESS PARALLEL APPROVAL DECISION
  static async processParallelDecision(stepInstanceId: string, decision: 'APPROVE' | 'REJECT' | 'RETURN', comments?: string) {
    const supabase = await createServerSupabaseClient()
    
    try {
      // Update individual step instance
      const { data: stepInstance } = await supabase
        .from('step_instances')
        .update({
          status: decision === 'APPROVE' ? 'APPROVED' : decision === 'REJECT' ? 'REJECTED' : 'RETURNED',
          decision,
          comments,
          decided_at: new Date().toISOString()
        })
        .eq('id', stepInstanceId)
        .select('workflow_instance_id, workflow_step_id, step_sequence')
        .single()
      
      if (!stepInstance) throw new Error('Step instance not found')
      
      // Update step completion status
      await this.updateStepCompletionStatus(
        stepInstance.workflow_instance_id,
        stepInstance.workflow_step_id,
        stepInstance.step_sequence
      )
      
      return { success: true }
      
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' }
    }
  }
  
  // 3. UPDATE STEP COMPLETION STATUS (SAP Completion Rules)
  private static async updateStepCompletionStatus(instanceId: string, stepId: string, stepSequence: number) {
    const supabase = await createServerSupabaseClient()
    
    // Get current step status counts
    const { data: statusCounts } = await supabase
      .rpc('get_step_status_counts', {
        p_workflow_instance_id: instanceId,
        p_workflow_step_id: stepId
      })
    
    if (!statusCounts || statusCounts.length === 0) return
    
    const counts = statusCounts[0]
    const { approved_count, rejected_count, pending_count, total_agents } = counts
    
    // Get completion rule
    const { data: completionStatus } = await supabase
      .from('step_completion_status')
      .select('completion_rule, min_approvals')
      .eq('workflow_instance_id', instanceId)
      .eq('workflow_step_id', stepId)
      .single()
    
    if (!completionStatus) return
    
    const { completion_rule, min_approvals } = completionStatus
    
    // Update counts
    await supabase
      .from('step_completion_status')
      .update({
        approved_count,
        rejected_count,
        pending_count
      })
      .eq('workflow_instance_id', instanceId)
      .eq('workflow_step_id', stepId)
    
    // Check completion based on SAP rules
    let isCompleted = false
    let stepResult: 'APPROVED' | 'REJECTED' = 'APPROVED'
    
    switch (completion_rule) {
      case 'ALL':
        // All agents must approve
        if (approved_count === total_agents) {
          isCompleted = true
          stepResult = 'APPROVED'
        } else if (rejected_count > 0) {
          isCompleted = true
          stepResult = 'REJECTED'
        }
        break
        
      case 'ANY':
        // Any one approval completes step
        if (approved_count > 0) {
          isCompleted = true
          stepResult = 'APPROVED'
        } else if (rejected_count === total_agents) {
          isCompleted = true
          stepResult = 'REJECTED'
        }
        break
        
      case 'MIN_N':
        // Minimum N approvals required
        if (approved_count >= min_approvals) {
          isCompleted = true
          stepResult = 'APPROVED'
        } else if ((total_agents - rejected_count) < min_approvals) {
          // Not enough remaining agents to reach minimum
          isCompleted = true
          stepResult = 'REJECTED'
        }
        break
    }
    
    if (isCompleted) {
      // Mark step as completed
      await supabase
        .from('step_completion_status')
        .update({
          is_completed: true,
          completed_at: new Date().toISOString()
        })
        .eq('workflow_instance_id', instanceId)
        .eq('workflow_step_id', stepId)
      
      // Cancel remaining pending step instances for ANY/MIN_N rules
      if (completion_rule === 'ANY' || (completion_rule === 'MIN_N' && stepResult === 'APPROVED')) {
        await supabase
          .from('step_instances')
          .update({ status: 'CANCELLED' })
          .eq('workflow_instance_id', instanceId)
          .eq('workflow_step_id', stepId)
          .eq('status', 'PENDING')
      }
      
      if (stepResult === 'APPROVED') {
        // Move to next step
        await supabase
          .from('workflow_instances')
          .update({ current_step_sequence: stepSequence + 1 })
          .eq('id', instanceId)
        
        // Initialize next step
        await this.initializeNextStep(instanceId)
      } else {
        // Step rejected - end workflow
        await supabase
          .from('workflow_instances')
          .update({ 
            status: 'REJECTED',
            completed_at: new Date().toISOString()
          })
          .eq('id', instanceId)
      }
    }
  }
  
  // 4. GET PARALLEL STEP STATUS
  static async getParallelStepStatus(instanceId: string, stepSequence: number) {
    const supabase = await createServerSupabaseClient()
    
    const { data: stepStatus } = await supabase
      .from('step_completion_status')
      .select(`
        *,
        workflow_steps(*),
        step_instances(
          *,
          step_agents(*)
        )
      `)
      .eq('workflow_instance_id', instanceId)
      .eq('step_sequence', stepSequence)
      .single()
    
    return stepStatus
  }
  
  // 5. GET AGENT WORKLOAD (For Load Balancing)
  static async getAgentWorkload(agentId: string) {
    const supabase = await createServerSupabaseClient()
    
    const { data: workload } = await supabase
      .from('step_instances')
      .select('status, workflow_instances!inner(object_type)')
      .eq('assigned_agent_id', agentId)
      .eq('status', 'PENDING')
    
    return {
      total_pending: workload?.length || 0,
      by_object_type: workload?.reduce((acc, item) => {
        const objectType = item.workflow_instances.object_type
        acc[objectType] = (acc[objectType] || 0) + 1
        return acc
      }, {} as Record<string, number>) || {}
    }
  }
  
  // 6. BULK PARALLEL APPROVAL
  static async bulkParallelApprove(stepInstanceIds: string[], decision: 'APPROVE' | 'REJECT', comments?: string) {
    const results = []
    
    for (const stepInstanceId of stepInstanceIds) {
      const result = await this.processParallelDecision(stepInstanceId, decision, comments)
      results.push({ stepInstanceId, ...result })
    }
    
    return results
  }
  
  // 7. ESCALATE PARALLEL STEP
  static async escalateParallelStep(instanceId: string, stepSequence: number, reason: string) {
    const supabase = await createServerSupabaseClient()
    
    // Get all pending step instances for this step
    const { data: pendingInstances } = await supabase
      .from('step_instances')
      .select('*')
      .eq('workflow_instance_id', instanceId)
      .eq('step_sequence', stepSequence)
      .eq('status', 'PENDING')
    
    // Escalate each pending instance
    for (const instance of pendingInstances || []) {
      await supabase
        .from('step_instances')
        .update({
          status: 'ESCALATED',
          comments: `Escalated: ${reason}`,
          decided_at: new Date().toISOString()
        })
        .eq('id', instance.id)
      
      // Create escalated step instance (implementation depends on escalation rules)
      // This would involve resolving escalation agent and creating new step instance
    }
  }
}

// 8. DATABASE FUNCTION FOR STEP STATUS COUNTS
/*
CREATE OR REPLACE FUNCTION get_step_status_counts(
    p_workflow_instance_id UUID,
    p_workflow_step_id UUID
)
RETURNS TABLE(
    approved_count INTEGER,
    rejected_count INTEGER,
    pending_count INTEGER,
    total_agents INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) FILTER (WHERE status = 'APPROVED')::INTEGER as approved_count,
        COUNT(*) FILTER (WHERE status = 'REJECTED')::INTEGER as rejected_count,
        COUNT(*) FILTER (WHERE status = 'PENDING')::INTEGER as pending_count,
        COUNT(*)::INTEGER as total_agents
    FROM step_instances 
    WHERE workflow_instance_id = p_workflow_instance_id 
    AND workflow_step_id = p_workflow_step_id;
END;
$$ LANGUAGE plpgsql;
*/
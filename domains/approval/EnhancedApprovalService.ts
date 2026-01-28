// Step 3: Enhanced ApprovalService with Universal Support

import { ApprovalRepository } from './approvalRepository';
import { UniversalApprovalRequest, ApprovalObjectType } from '../../types/ApprovalTypes';

export class EnhancedApprovalService {
  
  // Step 3.1: Universal approval flow generation
  static async generateUniversalFlow(request: UniversalApprovalRequest) {
    console.log('Universal approval flow generation:', request);
    
    try {
      const customerId = '550e8400-e29b-41d4-a716-446655440001';
      
      // 1. Get object type configuration
      const objectType = await ApprovalRepository.getObjectType(customerId, request.object_type);
      if (!objectType) {
        return { success: false, error: 'Unknown object type' };
      }
      
      // 2. Find matching policy with context scoring
      const policies = await ApprovalRepository.getApprovalPolicies(customerId);
      const policy = this.findBestMatchingPolicy(policies, request, objectType);
      
      if (!policy) {
        return { success: false, error: 'No matching policy found' };
      }
      
      // 3. Generate approval flow based on strategy
      const flow = await this.generateFlowSteps(policy, request, customerId);
      
      // 4. Create approval instance
      const instance = await ApprovalRepository.createApprovalInstance({
        customer_id: customerId,
        object_type: request.object_type,
        object_id: request.object_id,
        policy_id: policy.id,
        total_steps: flow.length,
        created_by: request.context.created_by || 'system'
      });
      
      return {
        success: true,
        instance_id: instance.id,
        policy: policy.policy_name,
        strategy: policy.approval_strategy,
        object_category: policy.object_category,
        flow: flow,
        total_steps: flow.length
      };
      
    } catch (error) {
      console.error('Error generating universal flow:', error);
      return { success: false, error: 'Failed to generate approval flow' };
    }
  }
  
  // Step 3.2: Context-aware policy matching with scoring
  private static findBestMatchingPolicy(policies: any[], request: UniversalApprovalRequest, objectType: ApprovalObjectType) {
    const candidates = policies.filter(p => 
      p.approval_object_type === request.object_type &&
      p.object_category === objectType.object_category
    );
    
    if (candidates.length === 0) return null;
    if (candidates.length === 1) return candidates[0];
    
    // Score policies based on context specificity
    const scoredPolicies = candidates.map(policy => ({
      policy,
      score: this.calculateContextScore(policy, request.context)
    }));
    
    // Return highest scoring policy
    scoredPolicies.sort((a, b) => b.score - a.score);
    return scoredPolicies[0].policy;
  }
  
  // Step 3.3: Context scoring algorithm
  private static calculateContextScore(policy: any, context: any): number {
    let score = 0;
    
    // Exact matches get high scores
    if (policy.company_code === context.company_code) score += 10;
    if (policy.country_code === context.country_code) score += 8;
    if (policy.plant_code === context.plant_code) score += 6;
    if (policy.project_code === context.project_code) score += 4;
    if (policy.purchase_org === context.purchase_org) score += 3;
    
    // Penalize mismatches
    if (policy.company_code && policy.company_code !== context.company_code) score -= 5;
    if (policy.plant_code && policy.plant_code !== context.plant_code) score -= 3;
    if (policy.project_code && policy.project_code !== context.project_code) score -= 2;
    
    return score;
  }
  
  // Step 3.4: Dynamic flow generation based on object category
  private static async generateFlowSteps(policy: any, request: UniversalApprovalRequest, customerId: string) {
    const flow = [];
    
    switch (policy.object_category) {
      case 'FINANCIAL':
        return this.generateFinancialFlow(policy, request, customerId);
      case 'DOCUMENT':
        return this.generateDocumentFlow(policy, request, customerId);
      case 'STORAGE':
        return this.generateStorageFlow(policy, request, customerId);
      case 'TRAVEL':
        return this.generateTravelFlow(policy, request, customerId);
      case 'HR':
        return this.generateHRFlow(policy, request, customerId);
      default:
        return this.generateDefaultFlow(policy, request, customerId);
    }
  }
  
  // Step 3.5: Category-specific flow generators
  private static async generateFinancialFlow(policy: any, request: UniversalApprovalRequest, customerId: string) {
    // Financial approval logic (existing logic)
    const amount = request.context.amount || 0;
    const approvers = await ApprovalRepository.getFunctionalApprovers(customerId);
    
    if (policy.approval_strategy === 'AMOUNT_BASED') {
      const suitableApprover = approvers
        .filter(a => a.functional_domain === 'FINANCE' && amount <= a.approval_limit)
        .sort((a, b) => a.approval_limit - b.approval_limit)[0];
      
      return suitableApprover ? [{
        step: 1,
        approver_role: suitableApprover.approver_role,
        level_name: `${suitableApprover.approval_scope} Approval`,
        amount_limit: suitableApprover.approval_limit,
        required: true
      }] : [];
    }
    
    // Role-based financial flow
    return this.generateHierarchicalFlow(policy, request, customerId);
  }
  
  private static async generateDocumentFlow(policy: any, request: UniversalApprovalRequest, customerId: string) {
    const flow = [];
    const context = policy.approval_context || {};
    
    // Document-specific approval chain
    if (context.discipline === 'STRUCTURAL') {
      flow.push({ step: 1, approver_role: 'Structural Engineer', required: true });
      flow.push({ step: 2, approver_role: 'Chief Engineer', required: true });
    } else if (context.discipline === 'MECHANICAL') {
      flow.push({ step: 1, approver_role: 'MEP Engineer', required: true });
      flow.push({ step: 2, approver_role: 'Design Manager', required: true });
    }
    
    // Add regulatory approval if required
    if (context.regulatory_impact) {
      flow.push({ step: flow.length + 1, approver_role: 'Regulatory Authority', required: true });
    }
    
    return flow;
  }
  
  private static async generateStorageFlow(policy: any, request: UniversalApprovalRequest, customerId: string) {
    const flow = [];
    const context = policy.approval_context || {};
    
    // Storage-specific approvals
    if (context.storage_type === 'HAZMAT') {
      flow.push({ step: 1, approver_role: 'Safety Officer', required: true });
      flow.push({ step: 2, approver_role: 'Fire Marshal', required: true });
    } else if (context.storage_type === 'SECURE') {
      flow.push({ step: 1, approver_role: 'Security Manager', required: true });
    }
    
    flow.push({ step: flow.length + 1, approver_role: 'Plant Manager', required: true });
    return flow;
  }
  
  private static async generateTravelFlow(policy: any, request: UniversalApprovalRequest, customerId: string) {
    const amount = request.context.amount || 0;
    const flow = [];
    
    // Travel approval based on amount
    if (amount < 1000) {
      flow.push({ step: 1, approver_role: 'Direct Manager', required: true });
    } else if (amount < 5000) {
      flow.push({ step: 1, approver_role: 'Direct Manager', required: true });
      flow.push({ step: 2, approver_role: 'Department Head', required: true });
    } else {
      flow.push({ step: 1, approver_role: 'Direct Manager', required: true });
      flow.push({ step: 2, approver_role: 'Department Head', required: true });
      flow.push({ step: 3, approver_role: 'Finance Manager', required: true });
    }
    
    return flow;
  }
  
  private static async generateHRFlow(policy: any, request: UniversalApprovalRequest, customerId: string) {
    const flow = [];
    const context = policy.approval_context || {};
    
    // HR-specific approval logic
    if (context.leave_type === 'ANNUAL') {
      flow.push({ step: 1, approver_role: 'Direct Manager', required: true });
      if (request.context.days_requested > 5) {
        flow.push({ step: 2, approver_role: 'HR Manager', required: true });
      }
    }
    
    return flow;
  }
  
  private static async generateHierarchicalFlow(policy: any, request: UniversalApprovalRequest, customerId: string) {
    // Existing hierarchical flow logic
    const orgHierarchy = await ApprovalRepository.getOrganizationalHierarchy(customerId);
    
    let hierarchyChain = [];
    if (request.context.plant_code) {
      hierarchyChain = orgHierarchy
        .filter(h => h.plant_code === request.context.plant_code || h.department_code === 'EXECUTIVE')
        .sort((a, b) => a.approval_limit - b.approval_limit)
        .slice(0, 3);
    }
    
    return hierarchyChain.map((person, index) => ({
      step: index + 1,
      approver_role: person.position_title,
      level_name: `${person.position_title} Approval`,
      approval_limit: person.approval_limit,
      required: true
    }));
  }
  
  private static async generateDefaultFlow(policy: any, request: UniversalApprovalRequest, customerId: string) {
    // Default single-step approval
    return [{
      step: 1,
      approver_role: 'Manager',
      level_name: 'Manager Approval',
      required: true
    }];
  }
}
// Layer 2: Business Logic Layer - domains/approval/ApprovalService.ts
import { ApprovalRepository } from './approvalRepository';

// Default customer ID - should be passed from request context in production
const DEFAULT_CUSTOMER_ID = '550e8400-e29b-41d4-a716-446655440001';

export class ApprovalService {
  private static validateCustomerId(customerId: string): void {
    if (!customerId || typeof customerId !== 'string' || customerId.length < 10) {
      throw new Error('Invalid customer ID');
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
  // Field definitions service method
  static async getFieldDefinitions(customerId: string) {
    console.log('Business layer: Getting field definitions for customer:', customerId);
    
    try {
      this.validateCustomerId(customerId);
      const fields = await ApprovalRepository.getFieldDefinitions(customerId);
      return { success: true, data: fields };
    } catch (error) {
      console.error('Business layer error fetching field definitions:', error);
      return { success: false, data: [], message: error instanceof Error ? error.message : 'Failed to fetch field definitions' };
    }
  }

  // Document types service method
  static async getDocumentTypes(customerId: string) {
    console.log('Business layer: Getting document types for customer:', customerId);
    
    try {
      this.validateCustomerId(customerId);
      const documentTypes = await ApprovalRepository.getDocumentTypes(customerId);
      return { success: true, data: documentTypes };
    } catch (error) {
      console.error('Business layer error fetching document types:', error);
      return { success: false, data: [], message: error instanceof Error ? error.message : 'Failed to fetch document types' };
    }
  }

  // Business logic: Add customer context and policy naming with validation
  static async createPolicy(data: any) {
    console.log('Business layer: Creating approval policy:', data);
    
    try {
      if (!data?.approval_object_type || !data?.approval_object_document_type) {
        return { success: false, message: 'Missing required fields: object type and document type' };
      }

      const sanitizedData = this.sanitizeInput(data);
      
      // Map field names to database columns
      const fieldMapping = {
        'selected_country_code': 'selected_countries',
        'selected_department_code': 'selected_departments', 
        'selected_plant_code': 'selected_plants',
        'selected_storage_location_code': 'selected_storage_locations',
        'selected_purchase_org': 'selected_purchase_orgs',
        'selected_project_code': 'selected_projects'
      };
      
      // Transform field names
      const transformedData = { ...sanitizedData };
      Object.keys(fieldMapping).forEach(oldKey => {
        if (transformedData[oldKey] !== undefined) {
          transformedData[fieldMapping[oldKey]] = transformedData[oldKey];
          delete transformedData[oldKey];
        }
      });
      
      // Business rule: Auto-generate policy name and add customer context
      const enrichedPolicy = {
        customer_id: customerId || DEFAULT_CUSTOMER_ID,
        policy_name: `${transformedData.approval_object_type} ${transformedData.approval_object_document_type} Policy`,
        ...transformedData
      };
      
      const policy = await ApprovalRepository.createApprovalPolicy(enrichedPolicy);
      return { success: true, message: 'Policy created successfully', policy };
    } catch (error) {
      console.error('Business layer error creating policy:', error);
      return { success: false, message: error instanceof Error ? error.message : 'Failed to create policy' };
    }
  }

  // Enhanced universal flow generation with validation
  static async generateUniversalFlow(data: any) {
    console.log('Universal approval flow generation:', data);
    
    try {
      if (!data?.object_type) {
        return { success: false, error: 'Object type is required' };
      }

      const sanitizedData = this.sanitizeInput(data);
      const customerId = sanitizedData.customer_id || DEFAULT_CUSTOMER_ID;
      this.validateCustomerId(customerId);
      
      // 1. Get object type configuration
      const objectTypes = await ApprovalRepository.getObjectTypes(CUSTOMER_ID);
      const objectType = objectTypes.find(ot => ot.object_type === sanitizedData.object_type);
      
      if (!objectType) {
        return { success: false, error: 'Unknown object type' };
      }
      
      // 2. Find matching policy with enhanced context scoring
      const policies = await ApprovalRepository.getApprovalPolicies(CUSTOMER_ID);
      const policy = this.findBestMatchingPolicy(policies, sanitizedData, objectType);
      
      if (!policy) {
        return { success: false, error: 'No matching policy found' };
      }
      
      // 3. Generate category-specific approval flow
      const flow = await this.generateCategorySpecificFlow(policy, sanitizedData, objectType, customerId);
      
      return {
        success: true,
        policy: policy.policy_name,
        strategy: policy.approval_strategy,
        object_category: policy.object_category || objectType.object_category,
        flow: flow,
        total_steps: flow.length,
        estimated_time: this.calculateEstimatedTime(policy, flow)
      };
      
    } catch (error) {
      console.error('Error generating universal flow:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Failed to generate approval flow' };
    }
  }

  // Enhanced policy matching with sparse context scoring
  private static findBestMatchingPolicy(policies: any[], data: any, objectType: any) {
    const candidates = policies.filter(p => 
      p.approval_object_type === data.object_type &&
      (p.object_category === objectType.object_category || !p.object_category)
    );
    
    if (candidates.length === 0) return null;
    if (candidates.length === 1) return candidates[0];
    
    // Score policies based on sparse context specificity
    const scoredPolicies = candidates.map(policy => ({
      policy,
      score: this.calculateSparseContextScore(policy, data)
    }));
    
    scoredPolicies.sort((a, b) => b.score - a.score);
    return scoredPolicies[0].policy;
  }

  // Enhanced sparse context scoring with hierarchical weights
  private static calculateSparseContextScore(policy: any, data: any): number {
    let score = 0;
    let specificity = 0;
    
    const contextFields = [
      { policy: 'selected_countries', request: 'country_code', weight: 120 },
      { policy: 'selected_departments', request: 'department_code', weight: 100 },
      { policy: 'selected_plants', request: 'plant_code', weight: 80 },
      { policy: 'selected_storage_locations', request: 'storage_location_code', weight: 60 },
      { policy: 'selected_purchase_orgs', request: 'purchase_org', weight: 40 },
      { policy: 'selected_projects', request: 'project_code', weight: 20 }
    ];
    
    for (const field of contextFields) {
      const policyValue = policy[field.policy];
      const requestValue = data[field.request];
      
      if (policyValue === null || policyValue === undefined) {
        // NULL = Global (matches everything, low specificity)
        score += field.weight / 10;
      } else if (Array.isArray(policyValue)) {
        if (policyValue.length === 0) {
          // Empty array = Disabled (no match)
          return -10000;
        } else if (policyValue.includes(requestValue)) {
          // Exact match in array (high specificity)
          score += field.weight * 10;
          specificity += field.weight / 20;
        } else if (requestValue) {
          // Request has value but policy doesn't match
          score -= field.weight * 5;
        }
      } else if (policyValue === requestValue) {
        // Exact scalar match
        score += field.weight * 10;
        specificity += field.weight / 20;
      } else if (policyValue && requestValue && policyValue !== requestValue) {
        // Mismatch penalty
        score -= field.weight * 5;
      }
    }
    
    // Bonus for higher specificity with hierarchical weighting
    score += specificity * 25;
    return score;
  }

  // Category-specific flow generation
  private static async generateCategorySpecificFlow(policy: any, data: any, objectType: any, customerId: string) {
    const category = policy.object_category || objectType.object_category;
    
    switch (category) {
      case 'FINANCIAL':
        return this.generateFinancialFlow(policy, data, customerId);
      case 'DOCUMENT':
        return this.generateDocumentFlow(policy, data, customerId);
      case 'STORAGE':
        return this.generateStorageFlow(policy, data, customerId);
      case 'TRAVEL':
        return this.generateTravelFlow(policy, data, customerId);
      case 'HR':
        return this.generateHRFlow(policy, data, customerId);
      default:
        return this.generateDefaultFlow(policy, data, customerId);
    }
  }

  // Financial flow generation (enhanced existing logic)
  private static async generateFinancialFlow(policy: any, data: any, customerId: string) {
    const amount = data.amount || 0;
    
    if (policy.approval_strategy === 'AMOUNT_BASED') {
      const approvers = await ApprovalRepository.getFunctionalApprovers(customerId);
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
    
    return this.generateHierarchicalFlow(policy, data, customerId);
  }

  // Document flow generation
  private static async generateDocumentFlow(policy: any, data: any, customerId: string) {
    const flow = [];
    const discipline = data.discipline || policy.document_discipline;
    
    if (discipline === 'STRUCTURAL') {
      flow.push({ step: 1, approver_role: 'Structural Engineer', level_name: 'Technical Review', required: true });
      flow.push({ step: 2, approver_role: 'Chief Engineer', level_name: 'Senior Review', required: true });
    } else if (discipline === 'MECHANICAL') {
      flow.push({ step: 1, approver_role: 'MEP Engineer', level_name: 'Technical Review', required: true });
      flow.push({ step: 2, approver_role: 'Design Manager', level_name: 'Design Review', required: true });
    } else {
      flow.push({ step: 1, approver_role: 'Technical Lead', level_name: 'Technical Review', required: true });
    }
    
    if (data.regulatory_impact || policy.approval_context?.regulatory_impact) {
      flow.push({ step: flow.length + 1, approver_role: 'Regulatory Authority', level_name: 'Regulatory Review', required: true });
    }
    
    return flow;
  }

  // Storage flow generation
  private static async generateStorageFlow(policy: any, data: any, customerId: string) {
    const flow = [];
    const storageType = data.storage_type || policy.storage_type;
    
    if (storageType === 'HAZMAT') {
      flow.push({ step: 1, approver_role: 'Safety Officer', level_name: 'Safety Review', required: true });
      flow.push({ step: 2, approver_role: 'Fire Marshal', level_name: 'Fire Safety Review', required: true });
    } else if (storageType === 'SECURE') {
      flow.push({ step: 1, approver_role: 'Security Manager', level_name: 'Security Review', required: true });
    }
    
    flow.push({ step: flow.length + 1, approver_role: 'Plant Manager', level_name: 'Final Approval', required: true });
    return flow;
  }

  // Travel flow generation
  private static async generateTravelFlow(policy: any, data: any, customerId: string) {
    const amount = data.amount || 0;
    const flow = [];
    
    flow.push({ step: 1, approver_role: 'Direct Manager', level_name: 'Manager Approval', required: true });
    
    if (amount > 1000) {
      flow.push({ step: 2, approver_role: 'Department Head', level_name: 'Department Approval', required: true });
    }
    
    if (amount > 5000) {
      flow.push({ step: 3, approver_role: 'Finance Manager', level_name: 'Finance Approval', required: true });
    }
    
    return flow;
  }

  // HR flow generation
  private static async generateHRFlow(policy: any, data: any, customerId: string) {
    const flow = [];
    const leaveType = data.leave_type;
    const days = data.days_requested || 0;
    
    flow.push({ step: 1, approver_role: 'Direct Manager', level_name: 'Manager Approval', required: true });
    
    if (days > 5 || leaveType === 'SICK') {
      flow.push({ step: 2, approver_role: 'HR Manager', level_name: 'HR Review', required: true });
    }
    
    return flow;
  }

  // Default flow generation
  private static async generateDefaultFlow(policy: any, data: any, customerId: string) {
    return [{
      step: 1,
      approver_role: 'Manager',
      level_name: 'Manager Approval',
      required: true
    }];
  }

  // Hierarchical flow with HR integration check
  private static async generateHierarchicalFlow(policy: any, data: any, customerId: string) {
    // Check if HR integration is available
    const hrIntegrated = await this.checkHRIntegration(customerId);
    
    if (hrIntegrated) {
      return this.generateHRBasedFlow(policy, data, customerId);
    } else {
      return this.generatePositionBasedFlow(policy, data, customerId);
    }
  }

  // Check HR system integration
  private static async checkHRIntegration(customerId: string): Promise<boolean> {
    try {
      const employees = await ApprovalRepository.getEmployeeHierarchy(customerId);
      return employees && employees.length > 0;
    } catch (error) {
      return false; // HR not available, use position-based
    }
  }

  // HR-based approval flow
  private static async generateHRBasedFlow(policy: any, data: any, customerId: string) {
    const requesterEmployeeId = data.requester_employee_id;
    if (!requesterEmployeeId) {
      return this.generatePositionBasedFlow(policy, data, customerId);
    }

    const employeeHierarchy = await ApprovalRepository.getEmployeeHierarchy(customerId);
    const requester = employeeHierarchy.find(emp => emp.employee_id === requesterEmployeeId);
    
    if (!requester) {
      return this.generatePositionBasedFlow(policy, data, customerId);
    }

    const flow = [];
    let currentLevel = requester;
    let step = 1;

    // Direct Manager
    if (currentLevel.manager_employee_id) {
      const manager = employeeHierarchy.find(emp => emp.employee_id === currentLevel.manager_employee_id);
      if (manager) {
        flow.push({
          step: step++,
          approver_role: manager.position_title,
          approver_name: manager.employee_name,
          employee_id: manager.employee_id,
          level_name: 'Direct Manager Approval',
          approval_limit: manager.approval_limit,
          required: true
        });
        currentLevel = manager;
      }
    }

    // Department Head (if different from manager)
    if (currentLevel.department_head_id && currentLevel.department_head_id !== currentLevel.employee_id) {
      const deptHead = employeeHierarchy.find(emp => emp.employee_id === currentLevel.department_head_id);
      if (deptHead) {
        flow.push({
          step: step++,
          approver_role: deptHead.position_title,
          approver_name: deptHead.employee_name,
          employee_id: deptHead.employee_id,
          level_name: 'Department Head Approval',
          approval_limit: deptHead.approval_limit,
          required: true
        });
      }
    }

    // Add functional approvers based on amount/type
    const functionalApprovers = await this.getFunctionalApproversForRequest(data, customerId);
    functionalApprovers.forEach(approver => {
      flow.push({
        step: step++,
        approver_role: approver.approver_role,
        level_name: `${approver.functional_domain} Approval`,
        approval_limit: approver.approval_limit,
        required: true
      });
    });

    return flow;
  }

  // Position-based approval flow (no HR)
  private static async generatePositionBasedFlow(policy: any, data: any, customerId: string) {
    const orgHierarchy = await ApprovalRepository.getOrganizationalHierarchy(customerId);
    
    let hierarchyChain = [];
    if (data.plant_code) {
      hierarchyChain = orgHierarchy
        .filter(h => h.plant_code === data.plant_code || h.department_code === 'EXECUTIVE')
        .sort((a, b) => a.approval_limit - b.approval_limit)
        .slice(0, 3);
    } else {
      hierarchyChain = orgHierarchy
        .filter(h => h.department_code === 'OPERATIONS' || h.department_code === 'EXECUTIVE')
        .sort((a, b) => a.approval_limit - b.approval_limit)
        .slice(0, 2);
    }
    
    const flow = hierarchyChain.map((person, index) => ({
      step: index + 1,
      approver_role: person.position_title,
      level_name: `${person.position_title} Approval`,
      approval_limit: person.approval_limit,
      department: person.department_code,
      plant: person.plant_code,
      required: true
    }));

    // Add functional approvers
    const functionalApprovers = await this.getFunctionalApproversForRequest(data, customerId);
    functionalApprovers.forEach(approver => {
      flow.push({
        step: flow.length + 1,
        approver_role: approver.approver_role,
        level_name: `${approver.functional_domain} Approval`,
        approval_limit: approver.approval_limit,
        required: true
      });
    });

    return flow;
  }

  // Get functional approvers based on request type
  private static async getFunctionalApproversForRequest(data: any, customerId: string) {
    const functionalApprovers = await ApprovalRepository.getFunctionalApprovers(customerId);
    const requiredApprovers = [];

    // Safety materials require safety approval
    if (data.material_category === 'SAFETY' || data.hazardous === true) {
      const safetyApprover = functionalApprovers.find(a => a.functional_domain === 'SAFETY');
      if (safetyApprover) requiredApprovers.push(safetyApprover);
    }

    // High-value items require finance approval
    if (data.amount && data.amount > 100000) {
      const financeApprover = functionalApprovers.find(a => a.functional_domain === 'FINANCE');
      if (financeApprover) requiredApprovers.push(financeApprover);
    }

    // Technical items require engineering approval
    if (data.material_category === 'TECHNICAL' || data.engineering_review === true) {
      const engineeringApprover = functionalApprovers.find(a => a.functional_domain === 'ENGINEERING');
      if (engineeringApprover) requiredApprovers.push(engineeringApprover);
    }

    return requiredApprovers;
  }

  // Calculate estimated approval time
  private static calculateEstimatedTime(policy: any, flow: any[]): string {
    const baseTime = flow.length * 24;
    const category = policy.object_category;
    
    const multipliers = {
      'FINANCIAL': 1.0,
      'DOCUMENT': 1.5,
      'STORAGE': 0.5,
      'TRAVEL': 0.75,
      'HR': 0.5
    };
    
    const totalHours = baseTime * (multipliers[category] || 1.0);
    return totalHours < 24 ? `${totalHours} hours` : `${Math.ceil(totalHours / 24)} days`;
  }

  // Optimized policy retrieval with filtering
  static async getApprovalPoliciesPaginated(filters: any = {}) {
    console.log('Business layer: Getting filtered policies:', filters);
    
    try {
      const customerId = filters?.customer_id || DEFAULT_CUSTOMER_ID;
      this.validateCustomerId(customerId);
      
      const sanitizedFilters = this.sanitizeInput(filters);
      
      // Use optimized query when object_type is provided
      if (sanitizedFilters.object_type) {
        const policies = await ApprovalRepository.getApprovalPoliciesPaginated(
          customerId, 
          sanitizedFilters.object_type,
          sanitizedFilters.limit || 50,
          sanitizedFilters.page ? sanitizedFilters.page * (sanitizedFilters.limit || 50) : 0,
          sanitizedFilters.document_type
        );
        return { success: true, policies };
      } else {
        // Return empty array if no object type specified (lazy loading)
        return { success: true, policies: [] };
      }
    } catch (error) {
      console.error('Business layer error fetching filtered policies:', error);
      return { success: false, policies: [], message: error instanceof Error ? error.message : 'Failed to fetch policies' };
    }
  }

  static async getApprovers(filters: any = {}) {
    console.log('Business layer: Getting approvers:', filters);
    
    try {
      const customerId = filters?.customer_id || DEFAULT_CUSTOMER_ID;
      this.validateCustomerId(customerId);
      
      const sanitizedFilters = this.sanitizeInput(filters);
      const approvers = await ApprovalRepository.getFunctionalApprovers(customerId, sanitizedFilters);
      return { success: true, approvers };
    } catch (error) {
      console.error('Business layer error fetching approvers:', error);
      return { success: false, approvers: [], message: error instanceof Error ? error.message : 'Failed to fetch approvers' };
    }
  }

  static async deletePolicy(policyId: string) {
    console.log('Business layer: Deleting approval policy:', policyId);
    
    try {
      if (!policyId || typeof policyId !== 'string') {
        return { success: false, message: 'Invalid policy ID' };
      }

      await ApprovalRepository.deleteApprovalPolicy(policyId);
      return { success: true, message: 'Policy deleted successfully' };
    } catch (error) {
      console.error('Business layer error deleting policy:', error);
      return { success: false, message: error instanceof Error ? error.message : 'Failed to delete policy' };
    }
  }

  static async updatePolicy(policyId: string, data: any) {
    console.log('Business layer: Updating approval policy:', policyId, data);
    
    try {
      if (!policyId || !data) {
        return { success: false, message: 'Policy ID and data are required' };
      }

      const sanitizedData = this.sanitizeInput(data);
      const policy = await ApprovalRepository.updateApprovalPolicy(policyId, sanitizedData);
      return { success: true, message: 'Policy updated successfully', policy };
    } catch (error) {
      console.error('Business layer error updating policy:', error);
      return { success: false, message: error instanceof Error ? error.message : 'Failed to update policy' };
    }
  }
}
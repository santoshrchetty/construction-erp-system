// Step 2: Enhanced TypeScript Interfaces

// Enhanced ApprovalPolicy interface
export interface ApprovalPolicy {
  id: string;
  customer_id: string;
  policy_name: string;
  approval_object_type: string;
  approval_object_document_type: string;
  object_category?: 'FINANCIAL' | 'DOCUMENT' | 'STORAGE' | 'TRAVEL' | 'HR';
  object_subtype?: string;
  approval_strategy: 'ROLE_BASED' | 'AMOUNT_BASED' | 'HYBRID';
  approval_pattern: string;
  amount_thresholds?: any;
  company_code?: string;
  country_code?: string;
  plant_code?: string;
  purchase_org?: string;
  project_code?: string;
  location_code?: string;
  storage_location_code?: string;
  storage_type?: string;
  document_category?: string;
  document_discipline?: string;
  revision_type?: string;
  approval_context?: any;
  business_rules?: any;
  escalation_rules?: any;
  is_active: boolean;
}

// New ApprovalObjectType interface
export interface ApprovalObjectType {
  id: string;
  customer_id: string;
  object_type: string;
  object_category: string;
  object_name: string;
  description?: string;
  default_strategy: string;
  required_fields?: string[];
  validation_rules?: any;
  form_config?: any;
  is_active: boolean;
}

// New ApprovalInstance interface
export interface ApprovalInstance {
  id: string;
  customer_id: string;
  object_type: string;
  object_id: string;
  policy_id: string;
  current_step: number;
  total_steps: number;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED';
  created_by: string;
  created_at: string;
  completed_at?: string;
}

// New ApprovalStep interface
export interface ApprovalStep {
  id: string;
  approval_instance_id: string;
  step_number: number;
  approver_role: string;
  approver_user_id?: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  approved_at?: string;
  comments?: string;
  is_required: boolean;
}

// Universal approval request interface
export interface UniversalApprovalRequest {
  object_type: string;
  object_id: string;
  object_data: any;
  context: {
    company_code?: string;
    country_code?: string;
    plant_code?: string;
    project_code?: string;
    amount?: number;
    currency?: string;
    [key: string]: any;
  };
}
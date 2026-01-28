// Step 4: Enhanced ApprovalRepository with Universal Support

import { createClient } from '@supabase/supabase-js';
import { ApprovalObjectType, ApprovalInstance, ApprovalStep } from '../../types/ApprovalTypes';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseKey);

export class EnhancedApprovalRepository {
  
  // Step 4.1: Object type management
  static async getObjectType(customerId: string, objectType: string): Promise<ApprovalObjectType | null> {
    const { data, error } = await supabase
      .from('approval_object_types')
      .select('*')
      .eq('customer_id', customerId)
      .eq('object_type', objectType)
      .eq('is_active', true)
      .single();
    
    if (error) return null;
    return data;
  }
  
  static async getObjectTypes(customerId: string, category?: string): Promise<ApprovalObjectType[]> {
    let query = supabase
      .from('approval_object_types')
      .select('*')
      .eq('customer_id', customerId)
      .eq('is_active', true);
    
    if (category) {
      query = query.eq('object_category', category);
    }
    
    const { data, error } = await query.order('object_category').order('object_type');
    
    if (error) throw error;
    return data || [];
  }
  
  static async createObjectType(objectType: Partial<ApprovalObjectType>): Promise<ApprovalObjectType> {
    const { data, error } = await supabase
      .from('approval_object_types')
      .insert(objectType)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }
  
  // Step 4.2: Approval instance management
  static async createApprovalInstance(instance: Partial<ApprovalInstance>): Promise<ApprovalInstance> {
    const { data, error } = await supabase
      .from('approval_instances')
      .insert(instance)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }
  
  static async getApprovalInstance(instanceId: string): Promise<ApprovalInstance | null> {
    const { data, error } = await supabase
      .from('approval_instances')
      .select('*')
      .eq('id', instanceId)
      .single();
    
    if (error) return null;
    return data;
  }
  
  static async updateApprovalInstance(instanceId: string, updates: Partial<ApprovalInstance>): Promise<ApprovalInstance> {
    const { data, error } = await supabase
      .from('approval_instances')
      .update(updates)
      .eq('id', instanceId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }
  
  static async getApprovalInstances(customerId: string, filters?: any): Promise<ApprovalInstance[]> {
    let query = supabase
      .from('approval_instances')
      .select('*')
      .eq('customer_id', customerId);
    
    if (filters?.object_type) query = query.eq('object_type', filters.object_type);
    if (filters?.status) query = query.eq('status', filters.status);
    if (filters?.created_by) query = query.eq('created_by', filters.created_by);
    
    const { data, error } = await query.order('created_at', { ascending: false });
    
    if (error) throw error;
    return data || [];
  }
  
  // Step 4.3: Approval step management
  static async createApprovalSteps(steps: Partial<ApprovalStep>[]): Promise<ApprovalStep[]> {
    const { data, error } = await supabase
      .from('approval_steps')
      .insert(steps)
      .select();
    
    if (error) throw error;
    return data || [];
  }
  
  static async getApprovalSteps(instanceId: string): Promise<ApprovalStep[]> {
    const { data, error } = await supabase
      .from('approval_steps')
      .select('*')
      .eq('approval_instance_id', instanceId)
      .order('step_number');
    
    if (error) throw error;
    return data || [];
  }
  
  static async updateApprovalStep(stepId: string, updates: Partial<ApprovalStep>): Promise<ApprovalStep> {
    const { data, error } = await supabase
      .from('approval_steps')
      .update(updates)
      .eq('id', stepId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }
  
  // Step 4.4: Enhanced policy queries with universal context
  static async getApprovalPoliciesWithContext(customerId: string, filters?: any): Promise<any[]> {
    let query = supabase
      .from('approval_policies')
      .select('*')
      .eq('customer_id', customerId)
      .eq('is_active', true);
    
    // Universal filters
    if (filters?.object_category) query = query.eq('object_category', filters.object_category);
    if (filters?.object_type) query = query.eq('approval_object_type', filters.object_type);
    if (filters?.company_code) query = query.eq('company_code', filters.company_code);
    if (filters?.plant_code) query = query.eq('plant_code', filters.plant_code);
    if (filters?.project_code) query = query.eq('project_code', filters.project_code);
    if (filters?.storage_type) query = query.eq('storage_type', filters.storage_type);
    if (filters?.document_discipline) query = query.eq('document_discipline', filters.document_discipline);
    
    const { data, error } = await query
      .order('object_category')
      .order('approval_object_type')
      .order('priority_order');
    
    if (error) throw error;
    return data || [];
  }
  
  // Step 4.5: Analytics and reporting
  static async getApprovalAnalytics(customerId: string, dateRange?: { from: string; to: string }) {
    let query = supabase
      .from('approval_instances')
      .select(`
        object_type,
        status,
        created_at,
        completed_at,
        approval_policies!inner(object_category)
      `)
      .eq('customer_id', customerId);
    
    if (dateRange) {
      query = query
        .gte('created_at', dateRange.from)
        .lte('created_at', dateRange.to);
    }
    
    const { data, error } = await query;
    
    if (error) throw error;
    
    // Process analytics data
    const analytics = {
      total_approvals: data?.length || 0,
      by_category: {},
      by_status: {},
      avg_approval_time: 0
    };
    
    data?.forEach(item => {
      const category = item.approval_policies?.object_category || 'UNKNOWN';
      analytics.by_category[category] = (analytics.by_category[category] || 0) + 1;
      analytics.by_status[item.status] = (analytics.by_status[item.status] || 0) + 1;
    });
    
    return analytics;
  }
  
  // Step 4.6: Bulk operations for data migration
  static async migrateExistingPolicies(customerId: string) {
    // Get existing policies without categories
    const { data: policies, error } = await supabase
      .from('approval_policies')
      .select('*')
      .eq('customer_id', customerId)
      .is('object_category', null);
    
    if (error) throw error;
    
    // Auto-categorize based on object type
    const updates = policies?.map(policy => ({
      id: policy.id,
      object_category: this.inferObjectCategory(policy.approval_object_type),
      object_subtype: this.inferObjectSubtype(policy.approval_object_type, policy.approval_object_document_type)
    })) || [];
    
    // Bulk update
    for (const update of updates) {
      await supabase
        .from('approval_policies')
        .update({
          object_category: update.object_category,
          object_subtype: update.object_subtype
        })
        .eq('id', update.id);
    }
    
    return { updated: updates.length };
  }
  
  private static inferObjectCategory(objectType: string): string {
    const categoryMap = {
      'PO': 'FINANCIAL',
      'MR': 'FINANCIAL',
      'PR': 'FINANCIAL',
      'INVOICE': 'FINANCIAL',
      'DRAWING': 'DOCUMENT',
      'SPECIFICATION': 'DOCUMENT',
      'PROCEDURE': 'DOCUMENT',
      'STORAGE': 'STORAGE',
      'TRAVEL': 'TRAVEL',
      'LEAVE': 'HR',
      'CLAIM': 'FINANCIAL'
    };
    
    return categoryMap[objectType] || 'FINANCIAL';
  }
  
  private static inferObjectSubtype(objectType: string, documentType: string): string {
    if (objectType === 'PO') return 'PROCUREMENT';
    if (objectType === 'MR') return 'MATERIAL_REQUEST';
    if (objectType === 'DRAWING') return 'TECHNICAL_DRAWING';
    if (objectType === 'TRAVEL') return 'BUSINESS_TRAVEL';
    if (objectType === 'LEAVE') return 'TIME_OFF';
    
    return documentType || 'STANDARD';
  }
}
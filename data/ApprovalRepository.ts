// Layer 3: Data Access Layer - data/ApprovalRepository.ts
import { createClient } from '@supabase/supabase-js';

if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
  throw new Error('Missing required Supabase environment variables');
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

export interface ApprovalPolicy {
  id: string;
  customer_id: string;
  policy_name: string;
  approval_object_type: string;
  approval_object_document_type: string;
  object_category?: 'FINANCIAL' | 'DOCUMENT' | 'STORAGE' | 'TRAVEL' | 'HR';
  object_subtype?: string;
  approval_strategy: string;
  approval_pattern: string;
  amount_thresholds: any;
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

export class ApprovalRepository {
  // Data layer: Direct Supabase operations with validation
  static async getApprovalPolicies(customerId: string, filters?: any): Promise<ApprovalPolicy[]> {
    if (!customerId || typeof customerId !== 'string') {
      throw new Error('Invalid customer ID');
    }

    let query = supabase
      .from('approval_policies')
      .select('*')
      .eq('customer_id', customerId)
      .eq('is_active', true);

    if (filters?.object_type) {
      query = query.eq('approval_object_type', filters.object_type);
    }

    const { data, error } = await query
      .order('approval_object_type')
      .order('approval_object_document_type')
      .limit(100);
    
    if (error) throw new Error(`Database error: ${error.message}`);
    return data || [];
  }

  static async createApprovalPolicy(policy: Partial<ApprovalPolicy>): Promise<ApprovalPolicy> {
    if (!policy.customer_id || !policy.approval_object_type) {
      throw new Error('Missing required policy fields');
    }

    const sanitizedPolicy = {
      ...policy,
      policy_name: policy.policy_name?.substring(0, 100),
      approval_object_type: policy.approval_object_type?.substring(0, 20),
      approval_object_document_type: policy.approval_object_document_type?.substring(0, 10)
    };

    const { data, error } = await supabase
      .from('approval_policies')
      .insert(sanitizedPolicy)
      .select()
      .single();
    
    if (error) throw new Error(`Failed to create policy: ${error.message}`);
    return data;
  }

  static async getFunctionalApprovers(customerId: string, filters?: any): Promise<any[]> {
    if (!customerId) throw new Error('Customer ID required');

    let query = supabase
      .from('functional_approver_assignments')
      .select('*')
      .eq('customer_id', customerId)
      .eq('is_active', true);

    if (filters?.domain) {
      query = query.eq('functional_domain', filters.domain);
    }

    const { data, error } = await query
      .order('functional_domain')
      .order('approval_scope')
      .limit(50);
    
    if (error) throw new Error(`Database error: ${error.message}`);
    return data || [];
  }

  static async getOrganizationalHierarchy(customerId: string): Promise<any[]> {
    const { data, error } = await supabase
      .from('organizational_hierarchy')
      .select('*')
      .eq('is_active', true)
      .order('approval_limit');
    
    if (error) throw error;
    return data || [];
  }

  // HR Integration: Get employee hierarchy
  static async getEmployeeHierarchy(customerId: string): Promise<any[]> {
    try {
      const { data, error } = await supabase
        .from('employee_hierarchy')
        .select(`
          employee_id,
          employee_name,
          position_title,
          department_code,
          plant_code,
          manager_employee_id,
          department_head_id,
          approval_limit,
          is_active
        `)
        .eq('customer_id', customerId)
        .eq('is_active', true)
        .order('department_code')
        .order('position_level');
      
      if (error) throw error;
      return data || [];
    } catch (error) {
      // HR table doesn't exist or no data - return empty array
      return [];
    }
  }

  // Get employee details by ID
  static async getEmployeeById(customerId: string, employeeId: string): Promise<any> {
    try {
      const { data, error } = await supabase
        .from('employee_hierarchy')
        .select('*')
        .eq('customer_id', customerId)
        .eq('employee_id', employeeId)
        .eq('is_active', true)
        .single();
      
      if (error) throw error;
      return data;
    } catch (error) {
      return null;
    }
  }

  static async deleteApprovalPolicy(policyId: string): Promise<void> {
    if (!policyId || typeof policyId !== 'string') {
      throw new Error('Invalid policy ID');
    }

    const { error } = await supabase
      .from('approval_policies')
      .delete()
      .eq('id', policyId);
    
    if (error) throw new Error(`Failed to delete policy: ${error.message}`);
  }

  static async updateApprovalPolicy(policyId: string, updates: Partial<ApprovalPolicy>): Promise<ApprovalPolicy> {
    if (!policyId || !updates) {
      throw new Error('Policy ID and updates required');
    }

    const sanitizedUpdates = {
      ...updates,
      policy_name: updates.policy_name?.substring(0, 100),
      updated_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('approval_policies')
      .update(sanitizedUpdates)
      .eq('id', policyId)
      .select()
      .single();
    
    if (error) throw new Error(`Failed to update policy: ${error.message}`);
    return data;
  }

  // Universal object type methods
  static async getObjectTypes(customerId: string, category?: string): Promise<any[]> {
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

  static async createObjectType(objectType: any): Promise<any> {
    const { data, error } = await supabase
      .from('approval_object_types')
      .insert(objectType)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  // Approval instance tracking
  static async createApprovalInstance(instance: any): Promise<any> {
    const { data, error } = await supabase
      .from('approval_instances')
      .insert(instance)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  static async getApprovalInstances(customerId: string, filters?: any): Promise<any[]> {
    let query = supabase
      .from('approval_instances')
      .select('*')
      .eq('customer_id', customerId);
    
    if (filters?.object_type) query = query.eq('object_type', filters.object_type);
    if (filters?.status) query = query.eq('status', filters.status);
    
    const { data, error } = await query.order('created_at', { ascending: false });
    
    if (error) throw error;
    return data || [];
  }

  // Enhanced field definitions with options from master data tables
  static async getFieldDefinitions(customerId: string): Promise<any[]> {
    if (!customerId) throw new Error('Customer ID required');

    try {
      const { data: fieldDefs, error } = await supabase
        .from('approval_field_definitions')
        .select('*')
        .eq('customer_id', customerId)
        .eq('is_active', true)
        .order('display_order')
        .abortSignal(AbortSignal.timeout(5000)); // 5 second timeout
      
      if (error) {
        console.error('Field definitions query failed:', error);
        // Return empty array if table doesn't exist or query fails
        return [];
      }
      
      // Load options from master data tables for each field
      const enrichedFields = await Promise.all((fieldDefs || []).map(async (fieldDef) => {
      let options = [];
      
      try {
        switch (fieldDef.field_name) {
          case 'country_code':
            const { data: countries } = await supabase
              .from('countries')
              .select('country_code, country_name')
              .eq('is_active', true)
              .order('country_name');
            options = countries?.map(c => ({
              option_value: c.country_code,
              option_label: c.country_name,
              option_description: `${c.country_name} operations`
            })) || [];
            break;
            
          case 'department_code':
            const { data: departments } = await supabase
              .from('departments')
              .select('department_code, department_name')
              .eq('is_active', true)
              .order('department_name');
            options = departments?.map(d => ({
              option_value: d.department_code,
              option_label: d.department_name,
              option_description: `${d.department_name} operations`
            })) || [];
            break;
            
          case 'plant_code':
            const { data: plants } = await supabase
              .from('plants')
              .select('plant_code, plant_name')
              .eq('is_active', true)
              .order('plant_name');
            options = plants?.map(p => ({
              option_value: p.plant_code,
              option_label: p.plant_name,
              option_description: `${p.plant_name} facility`
            })) || [];
            break;
            
          default:
            // Fallback to approval_field_options table
            const { data: fieldOptions } = await supabase
              .from('approval_field_options')
              .select('option_value, option_label, option_description')
              .eq('field_definition_id', fieldDef.id)
              .eq('is_active', true)
              .order('display_order');
            options = fieldOptions || [];
        }
      } catch (optionError) {
        console.warn(`Failed to load options for ${fieldDef.field_name}:`, optionError);
      }
      
      return {
        ...fieldDef,
        approval_field_options: options
      };
    }));
    
    return enrichedFields;
    } catch (abortError) {
      console.warn('Field definitions query aborted or failed:', abortError);
      // Return empty array as fallback
      return [];
    }
  }

  // Optimized field definitions with materialized view
  static async getFieldDefinitionsOptimized(customerId: string): Promise<any[]> {
    if (!customerId) throw new Error('Customer ID required');

    const { data, error } = await supabase
      .from('mv_approval_field_cache')
      .select('*')
      .eq('customer_id', customerId)
      .order('display_order');
    
    if (error) {
      // Fallback to regular query if materialized view fails
      console.warn('Materialized view failed, using fallback:', error.message);
      return this.getFieldDefinitions(customerId);
    }
    return data || [];
  }

  // Enhanced paginated policy retrieval with document type filtering
  static async getApprovalPoliciesPaginated(
    customerId: string, 
    objectType?: string, 
    limit: number = 50, 
    offset: number = 0,
    documentType?: string
  ): Promise<any[]> {
    if (!customerId) throw new Error('Customer ID required');
    if (!objectType) return []; // Return empty for lazy loading

    const { data, error } = await supabase
      .rpc('get_approval_policies_paginated', {
        p_customer_id: customerId,
        p_object_type: objectType,
        p_document_type: documentType || null,
        p_limit: limit,
        p_offset: offset
      });
    
    if (error) {
      // Fallback to regular query with enhanced filtering
      console.warn('Stored procedure failed, using fallback:', error.message);
      let query = supabase
        .from('approval_policies')
        .select('*')
        .eq('customer_id', customerId)
        .eq('approval_object_type', objectType)
        .eq('is_active', true);
      
      if (documentType) {
        query = query.eq('approval_object_document_type', documentType);
      }
      
      const { data: fallbackData, error: fallbackError } = await query
        .order('context_specificity', { ascending: false })
        .order('policy_name')
        .range(offset, offset + limit - 1);
      
      if (fallbackError) throw new Error(`Database error: ${fallbackError.message}`);
      return fallbackData || [];
    }
    
    return data || [];
  }

  // Get document types for object types
  static async getDocumentTypes(customerId: string): Promise<any[]> {
    if (!customerId) throw new Error('Customer ID required');

    const { data, error } = await supabase
      .from('approval_document_types')
      .select('*')
      .eq('customer_id', customerId)
      .eq('is_active', true)
      .order('object_type')
      .order('display_order');
    
    if (error) {
      console.warn('Document types query failed:', error.message);
      return [];
    }
    return data || [];
  }

  // Fast policy matching with stored procedure
  static async getMatchingPolicies(
    customerId: string,
    objectType: string,
    documentType?: string,
    country?: string,
    department?: string,
    plant?: string
  ): Promise<any[]> {
    if (!customerId || !objectType) {
      throw new Error('Customer ID and object type required');
    }

    const { data, error } = await supabase
      .rpc('get_matching_policies', {
        p_customer_id: customerId,
        p_object_type: objectType,
        p_document_type: documentType || null,
        p_country: country || null,
        p_department: department || null,
        p_plant: plant || null
      });
    
    if (error) throw new Error(`Policy matching error: ${error.message}`);
    return data || [];
  }

  static async getFieldOptions(fieldId: string): Promise<any[]> {
    const { data, error } = await supabase
      .from('approval_field_options')
      .select('*')
      .eq('field_definition_id', fieldId)
      .eq('is_active', true)
      .order('display_order');
    
    if (error) throw error;
    return data || [];
  }

  static async createCustomOption(customerId: string, fieldId: string, option: any): Promise<any> {
    if (!customerId || !fieldId || !option?.value || !option?.label) {
      throw new Error('Missing required option fields');
    }

    const sanitizedOption = {
      customer_id: customerId,
      field_definition_id: fieldId,
      option_value: option.value.substring(0, 100),
      option_label: option.label.substring(0, 200),
      option_description: option.description?.substring(0, 500),
      display_order: 999
    };

    const { data, error } = await supabase
      .from('approval_field_options')
      .insert(sanitizedOption)
      .select()
      .single();
    
    if (error) throw new Error(`Failed to create option: ${error.message}`);
    return data;
  }

  static async updatePolicyMultiSelect(policyId: string, selections: any): Promise<any> {
    const { data, error } = await supabase
      .from('approval_policies')
      .update({
        selected_plants: selections.plant_code || null,
        selected_purchase_orgs: selections.purchase_org || null,
        selected_projects: selections.project_code || null,
        custom_fields: selections.custom_fields || null
      })
      .eq('id', policyId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }
}
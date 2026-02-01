import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export interface Tenant {
  id: string;
  tenant_code: string;
  tenant_name: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface TenantCompany {
  tenant_id: string;
  company_code: string;
  company_name: string;
  is_active: boolean;
}

export class TenantService {
  /**
   * Set tenant context for database operations
   */
  static async setTenantContext(tenantId: string) {
    const { error } = await supabase.rpc('set_tenant_context', {
      p_tenant_id: tenantId
    });
    
    if (error) {
      throw new Error(`Failed to set tenant context: ${error.message}`);
    }
  }

  /**
   * Create a new tenant
   */
  static async createTenant(tenantCode: string, tenantName: string): Promise<string> {
    const { data, error } = await supabase.rpc('create_tenant', {
      p_tenant_code: tenantCode,
      p_tenant_name: tenantName
    });
    
    if (error) {
      throw new Error(`Failed to create tenant: ${error.message}`);
    }
    
    return data;
  }

  /**
   * Get all tenants
   */
  static async getAllTenants(): Promise<Tenant[]> {
    const { data, error } = await supabase
      .from('tenants')
      .select('*')
      .eq('is_active', true)
      .order('tenant_code');
    
    if (error) {
      throw new Error(`Failed to fetch tenants: ${error.message}`);
    }
    
    return data || [];
  }

  /**
   * Get tenant by code
   */
  static async getTenantByCode(tenantCode: string): Promise<Tenant | null> {
    const { data, error } = await supabase
      .from('tenants')
      .select('*')
      .eq('tenant_code', tenantCode)
      .eq('is_active', true)
      .single();
    
    if (error && error.code !== 'PGRST116') {
      throw new Error(`Failed to fetch tenant: ${error.message}`);
    }
    
    return data;
  }

  /**
   * Get companies for a tenant
   */
  static async getTenantCompanies(tenantId: string): Promise<TenantCompany[]> {
    const { data, error } = await supabase
      .from('company_codes')
      .select('tenant_id, company_code, company_name, is_active')
      .eq('tenant_id', tenantId)
      .eq('is_active', true)
      .order('company_code');
    
    if (error) {
      throw new Error(`Failed to fetch tenant companies: ${error.message}`);
    }
    
    return data || [];
  }

  /**
   * Validate tenant-company combination
   */
  static async validateTenantCompany(tenantId: string, companyCode: string): Promise<boolean> {
    const { data, error } = await supabase
      .from('company_codes')
      .select('company_code')
      .eq('tenant_id', tenantId)
      .eq('company_code', companyCode)
      .eq('is_active', true)
      .single();
    
    if (error && error.code !== 'PGRST116') {
      throw new Error(`Failed to validate tenant-company: ${error.message}`);
    }
    
    return !!data;
  }

  /**
   * Get next document number with tenant isolation
   */
  static async getNextNumber(
    tenantId: string,
    companyCode: string,
    documentType: string,
    fiscalYear?: string
  ): Promise<string> {
    const { data, error } = await supabase.rpc('get_next_number_tenant_safe', {
      p_tenant_id: tenantId,
      p_company_code: companyCode,
      p_document_type: documentType,
      p_fiscal_year: fiscalYear
    });
    
    if (error) {
      throw new Error(`Failed to get next number: ${error.message}`);
    }
    
    return data;
  }

  /**
   * Middleware helper to extract and validate tenant from request
   */
  static async validateRequestTenant(headers: Headers): Promise<{
    tenantId: string;
    companyCode: string;
  }> {
    const tenantId = headers.get('x-tenant-id');
    const companyCode = headers.get('x-company-code');
    
    if (!tenantId || !companyCode) {
      throw new Error('Missing tenant or company information in request headers');
    }
    
    const isValid = await this.validateTenantCompany(tenantId, companyCode);
    if (!isValid) {
      throw new Error('Invalid tenant-company combination');
    }
    
    // Set tenant context for this request
    await this.setTenantContext(tenantId);
    
    return { tenantId, companyCode };
  }

  /**
   * Create default tenant setup for new installations
   */
  static async setupDefaultTenant(): Promise<void> {
    try {
      // Check if default tenant exists
      const defaultTenant = await this.getTenantByCode('DEFAULT');
      
      if (!defaultTenant) {
        // Create default tenant
        const tenantId = await this.createTenant('DEFAULT', 'Default Tenant');
        
        // Create default company for the tenant
        const { error } = await supabase
          .from('company_codes')
          .insert({
            tenant_id: tenantId,
            company_code: 'C001',
            company_name: 'Default Company',
            is_active: true
          });
        
        if (error) {
          throw new Error(`Failed to create default company: ${error.message}`);
        }
      }
    } catch (error) {
      console.error('Failed to setup default tenant:', error);
      throw error;
    }
  }
}
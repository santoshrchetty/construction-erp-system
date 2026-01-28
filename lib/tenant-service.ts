import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export class TenantService {
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

    if (error) throw new Error(`Failed to get next number: ${error.message}`);
    return data;
  }

  static async getCompaniesByTenant(tenantId: string) {
    const { data, error } = await supabase
      .from('company_codes')
      .select('*')
      .eq('tenant_id', tenantId)
      .eq('is_active', true)
      .order('company_code');

    if (error) throw new Error(`Failed to get companies: ${error.message}`);
    return data;
  }

  static async validateTenantAccess(tenantId: string, companyCode: string): Promise<boolean> {
    const { data, error } = await supabase
      .from('company_codes')
      .select('id')
      .eq('tenant_id', tenantId)
      .eq('company_code', companyCode)
      .eq('is_active', true)
      .single();

    return !error && !!data;
  }
}
import { supabase } from '../config/supabase';
import { NumberRange, NumberRangeAlert, NumberRangeStatistics } from '../domains/finance/NumberRangeService';

export class NumberRangeRepository {
  async getNextNumber(companyCode: string, documentType: string, fiscalYear?: string): Promise<string> {
    const { data, error } = await supabase.rpc('get_next_number', {
      p_company_code: companyCode,
      p_document_type: documentType,
      p_fiscal_year: fiscalYear
    });

    if (error) throw error;
    return data;
  }

  async getNumberRanges(companyCode?: string): Promise<NumberRange[]> {
    let query = supabase
      .from('document_number_ranges')
      .select('*')
      .order('company_code', { ascending: true })
      .order('document_type', { ascending: true });

    if (companyCode) {
      query = query.eq('company_code', companyCode);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  }

  async getNumberRangeById(id: string): Promise<NumberRange> {
    const { data, error } = await supabase
      .from('document_number_ranges')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  async createNumberRange(numberRange: Omit<NumberRange, 'id'>): Promise<NumberRange> {
    const { data, error } = await supabase
      .from('document_number_ranges')
      .insert([numberRange])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateNumberRange(id: string, updates: Partial<NumberRange>): Promise<NumberRange> {
    const { data, error } = await supabase
      .from('document_number_ranges')
      .update({ ...updates, modified_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteNumberRange(id: string): Promise<void> {
    const { error } = await supabase
      .from('document_number_ranges')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  async getAlerts(companyCode?: string, unacknowledgedOnly: boolean = true): Promise<NumberRangeAlert[]> {
    let query = supabase
      .from('number_range_alerts')
      .select('*')
      .order('created_at', { ascending: false });

    if (companyCode) {
      query = query.eq('company_code', companyCode);
    }

    if (unacknowledgedOnly) {
      query = query.eq('is_acknowledged', false);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  }

  async acknowledgeAlert(alertId: string): Promise<void> {
    const { error } = await supabase
      .from('number_range_alerts')
      .update({
        is_acknowledged: true,
        acknowledged_at: new Date().toISOString()
      })
      .eq('id', alertId);

    if (error) throw error;
  }

  async getStatistics(companyCode?: string): Promise<NumberRangeStatistics[]> {
    const { data, error } = await supabase.rpc('get_number_range_statistics', {
      p_company_code: companyCode
    });

    if (error) throw error;
    return data || [];
  }

  async getUsageHistory(companyCode: string, documentType: string, limit: number = 100) {
    const { data, error } = await supabase
      .from('number_range_usage_history')
      .select('*')
      .eq('company_code', companyCode)
      .eq('document_type', documentType)
      .order('used_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  }

  async bulkCreateNumberRanges(numberRanges: Omit<NumberRange, 'id'>[]): Promise<NumberRange[]> {
    const { data, error } = await supabase
      .from('document_number_ranges')
      .insert(numberRanges)
      .select();

    if (error) throw error;
    return data || [];
  }

  async getCompanies(): Promise<string[]> {
    const { data, error } = await supabase
      .from('document_number_ranges')
      .select('company_code')
      .order('company_code');

    if (error) throw error;
    
    const uniqueCompanies = [...new Set(data?.map(item => item.company_code) || [])];
    return uniqueCompanies;
  }

  async getDocumentTypes(companyCode?: string): Promise<string[]> {
    let query = supabase
      .from('document_number_ranges')
      .select('document_type')
      .order('document_type');

    if (companyCode) {
      query = query.eq('company_code', companyCode);
    }

    const { data, error } = await query;
    if (error) throw error;
    
    const uniqueTypes = [...new Set(data?.map(item => item.document_type) || [])];
    return uniqueTypes;
  }
}
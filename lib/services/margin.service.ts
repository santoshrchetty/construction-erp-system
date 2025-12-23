import { supabase } from '../supabase'

export interface MarginAnalysisData {
  project_id: string
  project_name: string
  contract_value: number
  planned_cost: number
  actual_cost: number
  forecast_cost: number
  total_billed: number
  planned_margin: number
  planned_margin_percent: number
  actual_margin: number
  actual_margin_percent: number
  estimated_margin: number
  estimated_margin_percent: number
  projected_margin: number
  projected_margin_percent: number
  earned_revenue: number
  unbilled_revenue: number
}

export interface MarginTrendData {
  trend_date: string
  cumulative_cost: number
  cumulative_billing: number
  margin_amount: number
  margin_percent: number
}

export interface BillingData {
  id?: string
  project_id: string
  billing_date: string
  billing_amount: number
  billing_type: 'progress' | 'milestone' | 'final'
  description?: string
  invoice_number?: string
  status: 'pending' | 'invoiced' | 'paid'
}

export class MarginService {
  /**
   * Get margin analysis for a specific project
   */
  static async getProjectMarginAnalysis(projectId: string): Promise<MarginAnalysisData | null> {
    const { data, error } = await supabase
      .rpc('get_project_margin_analysis', { p_project_id: projectId })
      .single()

    if (error) throw error
    return data
  }

  /**
   * Get margin analysis for all active projects
   */
  static async getAllProjectsMarginAnalysis(): Promise<MarginAnalysisData[]> {
    const { data, error } = await supabase
      .from('margin_analysis')
      .select('*')
      .order('project_name')

    if (error) throw error
    return data || []
  }

  /**
   * Get margin trend data for a project
   */
  static async getMarginTrend(
    projectId: string,
    startDate?: string,
    endDate?: string
  ): Promise<MarginTrendData[]> {
    const { data, error } = await supabase
      .rpc('get_margin_trend', {
        p_project_id: projectId,
        p_start_date: startDate,
        p_end_date: endDate
      })

    if (error) throw error
    return data || []
  }

  /**
   * Create billing record
   */
  static async createBilling(billingData: Omit<BillingData, 'id'>): Promise<BillingData> {
    const { data, error } = await supabase
      .from('project_billing')
      .insert(billingData)
      .select()
      .single()

    if (error) throw error
    return data
  }

  /**
   * Update billing record
   */
  static async updateBilling(id: string, updates: Partial<BillingData>): Promise<BillingData> {
    const { data, error } = await supabase
      .from('project_billing')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  /**
   * Get billing records for a project
   */
  static async getProjectBilling(projectId: string): Promise<BillingData[]> {
    const { data, error } = await supabase
      .from('project_billing')
      .select('*')
      .eq('project_id', projectId)
      .order('billing_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  /**
   * Calculate margin metrics
   */
  static calculateMarginMetrics(revenue: number, cost: number) {
    return {
      margin: revenue - cost,
      marginPercent: revenue > 0 ? ((revenue - cost) / revenue) * 100 : 0,
      markup: cost > 0 ? ((revenue - cost) / cost) * 100 : 0
    }
  }

  /**
   * Get margin status based on percentage
   */
  static getMarginStatus(marginPercent: number) {
    if (marginPercent >= 20) return 'excellent'
    if (marginPercent >= 15) return 'good'
    if (marginPercent >= 10) return 'acceptable'
    if (marginPercent >= 5) return 'poor'
    return 'critical'
  }

  /**
   * Format margin values for display
   */
  static formatMarginValue(value: number, type: 'currency' | 'percentage' = 'currency') {
    switch (type) {
      case 'currency':
        return new Intl.NumberFormat('en-US', {
          style: 'currency',
          currency: 'USD',
          minimumFractionDigits: 0,
          maximumFractionDigits: 0
        }).format(value)
      
      case 'percentage':
        return `${value.toFixed(1)}%`
      
      default:
        return value.toString()
    }
  }
}
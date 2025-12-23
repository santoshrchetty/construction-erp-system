import { supabase } from '../supabase'

export interface CTCData {
  project_id: string
  project_name: string
  calculation_date: string
  total_budget: number
  total_actual: number
  total_committed: number
  ctc_labor: number
  ctc_materials: number
  ctc_subcontract: number
  ctc_overhead: number
  total_ctc: number
  forecast_at_completion: number
  budget_variance: number
  progress_percentage: number
}

export interface TaskCTCData {
  task_id: string
  task_name: string
  budget_amount: number
  actual_amount: number
  progress_percentage: number
  remaining_work: number
  ctc_amount: number
}

export interface AdvancedCTCData {
  project_id: string
  current_ctc: number
  burn_rate_ctc: number
  trend_ctc: number
  recommended_ctc: number
  confidence_level: 'high' | 'medium' | 'low'
}

export class CTCService {
  /**
   * Calculate CTC for a specific project
   */
  static async getProjectCTC(projectId: string): Promise<CTCData | null> {
    const { data, error } = await supabase
      .rpc('calculate_project_ctc', { p_project_id: projectId })
      .single()

    if (error) throw error
    return data
  }

  /**
   * Get CTC calculations for all active projects
   */
  static async getAllProjectsCTC(): Promise<CTCData[]> {
    const { data, error } = await supabase
      .from('ctc_calculations')
      .select('*')
      .order('project_name')

    if (error) throw error
    return data || []
  }

  /**
   * Calculate CTC for a specific task
   */
  static async getTaskCTC(taskId: string): Promise<TaskCTCData | null> {
    const { data, error } = await supabase
      .rpc('calculate_task_ctc', { p_task_id: taskId })
      .single()

    if (error) throw error
    return data
  }

  /**
   * Get advanced CTC calculation with burn rate analysis
   */
  static async getAdvancedCTC(
    projectId: string,
    analysisPeriodDays: number = 30
  ): Promise<AdvancedCTCData | null> {
    const { data, error } = await supabase
      .rpc('calculate_ctc_with_burn_rate', {
        p_project_id: projectId,
        p_analysis_period_days: analysisPeriodDays
      })
      .single()

    if (error) throw error
    return data
  }

  /**
   * Calculate CTC breakdown by category
   */
  static calculateCTCBreakdown(ctcData: CTCData) {
    const total = ctcData.total_ctc
    
    return {
      labor: {
        amount: ctcData.ctc_labor,
        percentage: total > 0 ? (ctcData.ctc_labor / total) * 100 : 0
      },
      materials: {
        amount: ctcData.ctc_materials,
        percentage: total > 0 ? (ctcData.ctc_materials / total) * 100 : 0
      },
      subcontract: {
        amount: ctcData.ctc_subcontract,
        percentage: total > 0 ? (ctcData.ctc_subcontract / total) * 100 : 0
      },
      overhead: {
        amount: ctcData.ctc_overhead,
        percentage: total > 0 ? (ctcData.ctc_overhead / total) * 100 : 0
      }
    }
  }

  /**
   * Calculate completion forecast metrics
   */
  static calculateCompletionMetrics(ctcData: CTCData) {
    const completionRatio = ctcData.total_budget > 0 ? 
      ctcData.forecast_at_completion / ctcData.total_budget : 0

    return {
      forecastAtCompletion: ctcData.forecast_at_completion,
      budgetVariance: ctcData.budget_variance,
      variancePercentage: ctcData.total_budget > 0 ? 
        (ctcData.budget_variance / ctcData.total_budget) * 100 : 0,
      completionRatio,
      isOverBudget: ctcData.forecast_at_completion > ctcData.total_budget,
      remainingBudget: ctcData.total_budget - ctcData.total_actual - ctcData.total_ctc
    }
  }

  /**
   * Get CTC status based on variance
   */
  static getCTCStatus(budgetVariance: number, totalBudget: number) {
    if (totalBudget === 0) return 'unknown'
    
    const variancePercentage = Math.abs(budgetVariance / totalBudget) * 100
    
    if (budgetVariance > 0) {
      return variancePercentage > 10 ? 'significantly_under_budget' : 'under_budget'
    } else {
      return variancePercentage > 10 ? 'significantly_over_budget' : 'over_budget'
    }
  }

  /**
   * Format CTC values for display
   */
  static formatCTCValue(value: number, type: 'currency' | 'percentage' = 'currency') {
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
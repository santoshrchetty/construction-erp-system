import { supabase } from '../supabase'

export interface EVMData {
  project_id: string
  project_name: string
  status_date: string
  planned_value: number
  earned_value: number
  actual_cost: number
  budget_at_completion: number
  cost_performance_index: number | null
  schedule_performance_index: number | null
  cost_variance: number
  schedule_variance: number
  estimate_to_complete: number
  estimate_at_completion: number
  variance_at_completion: number
  to_complete_performance_index: number | null
  percent_complete: number
  percent_spent: number
}

export interface EVMTrendData {
  trend_date: string
  planned_value: number
  earned_value: number
  actual_cost: number
}

export interface TaskEVMData {
  task_id: string
  task_name: string
  planned_value: number
  earned_value: number
  actual_cost: number
  cost_performance_index: number | null
  schedule_performance_index: number | null
}

export class EVMService {
  /**
   * Get EVM calculations for a specific project
   */
  static async getProjectEVM(projectId: string): Promise<EVMData | null> {
    const { data, error } = await supabase
      .rpc('get_project_evm', { p_project_id: projectId })
      .single()

    if (error) throw error
    return data
  }

  /**
   * Get EVM calculations for all active projects
   */
  static async getAllProjectsEVM(): Promise<EVMData[]> {
    const { data, error } = await supabase
      .from('evm_calculations')
      .select('*')
      .order('project_name')

    if (error) throw error
    return data || []
  }

  /**
   * Get EVM trend data for a project over time
   */
  static async getEVMTrend(
    projectId: string,
    startDate?: string,
    endDate?: string
  ): Promise<EVMTrendData[]> {
    const { data, error } = await supabase
      .rpc('get_evm_trend', {
        p_project_id: projectId,
        p_start_date: startDate,
        p_end_date: endDate
      })

    if (error) throw error
    return data || []
  }

  /**
   * Get EVM data for a specific task
   */
  static async getTaskEVM(taskId: string): Promise<TaskEVMData | null> {
    const { data, error } = await supabase
      .rpc('get_task_evm', { p_task_id: taskId })
      .single()

    if (error) throw error
    return data
  }

  /**
   * Calculate EVM formulas manually (utility functions)
   */
  static calculateEVMMetrics(pv: number, ev: number, ac: number, bac: number) {
    return {
      // Performance Indices
      cpi: ac > 0 ? ev / ac : null,
      spi: pv > 0 ? ev / pv : null,
      
      // Variances
      cv: ev - ac,
      sv: ev - pv,
      
      // Forecasts
      etc: ac > 0 && ev < bac ? (bac - ev) / (ev / ac) : bac - ev,
      eac: ac + (ac > 0 && ev < bac ? (bac - ev) / (ev / ac) : bac - ev),
      vac: bac - (ac + (ac > 0 && ev < bac ? (bac - ev) / (ev / ac) : bac - ev)),
      
      // Performance Ratios
      tcpi: (bac - ac) > 0 ? (bac - ev) / (bac - ac) : null,
      percentComplete: bac > 0 ? (ev / bac) * 100 : 0,
      percentSpent: bac > 0 ? (ac / bac) * 100 : 0
    }
  }

  /**
   * Get performance status based on indices
   */
  static getPerformanceStatus(cpi: number | null, spi: number | null) {
    const costStatus = cpi === null ? 'unknown' : 
      cpi >= 1.0 ? 'under_budget' : 'over_budget'
    
    const scheduleStatus = spi === null ? 'unknown' :
      spi >= 1.0 ? 'ahead_of_schedule' : 'behind_schedule'
    
    return { costStatus, scheduleStatus }
  }

  /**
   * Format EVM values for display
   */
  static formatEVMValue(value: number | null, type: 'currency' | 'percentage' | 'ratio' = 'currency') {
    if (value === null) return 'N/A'
    
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
      
      case 'ratio':
        return value.toFixed(2)
      
      default:
        return value.toString()
    }
  }
}
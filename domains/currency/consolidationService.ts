import { createServiceClient } from '@/lib/supabase/server'
import { getExchangeRate, convertCurrency } from './currencyService'

export interface ConsolidationGroup {
  group_code: string
  group_name: string
  parent_company_code: string
  reporting_currency: string
  consolidation_method: string
}

export interface ConsolidatedStockData {
  group_code: string
  group_name: string
  reporting_currency: string
  total_companies: number
  total_materials: number
  total_value_reporting: number
  companies: CompanyStockSummary[]
}

export interface CompanyStockSummary {
  company_code: string
  company_name: string
  company_currency: string
  material_count: number
  company_value: number
  reporting_value: number
  ownership_percentage: number
}

export async function getConsolidatedStockOverview(groupCode: string, reportingDate?: string): Promise<ConsolidatedStockData> {
  const supabase = createServiceClient()
  const targetDate = reportingDate || new Date().toISOString().split('T')[0]
  
  // Get consolidation group info
  const { data: groupData } = await supabase
    .from('consolidation_groups')
    .select('*')
    .eq('group_code', groupCode)
    .eq('is_active', true)
    .single()
  
  if (!groupData) throw new Error('Consolidation group not found')
  
  // Get companies in the group
  const { data: assignments } = await supabase
    .from('company_group_assignments')
    .select(`
      company_code,
      ownership_percentage,
      consolidation_method,
      company_codes!inner (
        company_code,
        company_name,
        currency
      )
    `)
    .eq('group_id', groupData.id)
    .eq('is_active', true)
    .lte('effective_from', targetDate)
    .or(`effective_to.is.null,effective_to.gte.${targetDate}`)
  
  if (!assignments) return createEmptyConsolidation(groupData)
  
  // Get stock data for each company
  const companySummaries = await Promise.all(
    assignments.map(async (assignment) => {
      const companyCode = assignment.company_codes.company_code
      const companyCurrency = assignment.company_codes.currency
      
      // Get stock summary for company
      const { data: stockData } = await supabase
        .from('stock_balances')
        .select(`
          total_value,
          storage_locations!inner (
            plants!inner (
              company_codes!inner (
                company_code
              )
            )
          )
        `)
        .eq('storage_locations.plants.company_codes.company_code', companyCode)
      
      const materialCount = stockData?.length || 0
      const companyValue = stockData?.reduce((sum, item) => sum + Number(item.total_value || 0), 0) || 0
      
      // Convert to reporting currency
      let reportingValue = companyValue
      if (companyCurrency !== groupData.reporting_currency) {
        try {
          reportingValue = await convertCurrency(
            companyValue,
            companyCurrency,
            groupData.reporting_currency,
            targetDate
          )
        } catch (error) {
          console.warn(`Currency conversion failed for ${companyCurrency} to ${groupData.reporting_currency}:`, error)
        }
      }
      
      // Apply consolidation method
      if (assignment.consolidation_method === 'PROPORTIONAL') {
        reportingValue = reportingValue * (assignment.ownership_percentage / 100)
      }
      
      return {
        company_code: companyCode,
        company_name: assignment.company_codes.company_name,
        company_currency: companyCurrency,
        material_count: materialCount,
        company_value: companyValue,
        reporting_value: reportingValue,
        ownership_percentage: assignment.ownership_percentage
      }
    })
  )
  
  return {
    group_code: groupData.group_code,
    group_name: groupData.group_name,
    reporting_currency: groupData.reporting_currency,
    total_companies: companySummaries.length,
    total_materials: companySummaries.reduce((sum, company) => sum + company.material_count, 0),
    total_value_reporting: companySummaries.reduce((sum, company) => sum + company.reporting_value, 0),
    companies: companySummaries
  }
}

export async function getMultiCompanyStockComparison(companyCodes: string[], reportingCurrency: string = 'USD', reportingDate?: string) {
  const supabase = createServiceClient()
  const targetDate = reportingDate || new Date().toISOString().split('T')[0]
  
  const companyData = await Promise.all(
    companyCodes.map(async (companyCode) => {
      // Get company info
      const { data: company } = await supabase
        .from('company_codes')
        .select('company_code, company_name, currency')
        .eq('company_code', companyCode)
        .single()
      
      if (!company) return null
      
      // Get stock summary
      const { data: stockData } = await supabase
        .from('stock_balances')
        .select(`
          current_quantity,
          total_value,
          stock_items (category),
          storage_locations!inner (
            plants!inner (
              company_codes!inner (company_code)
            )
          )
        `)
        .eq('storage_locations.plants.company_codes.company_code', companyCode)
      
      const totalValue = stockData?.reduce((sum, item) => sum + Number(item.total_value || 0), 0) || 0
      const totalQuantity = stockData?.reduce((sum, item) => sum + Number(item.current_quantity || 0), 0) || 0
      
      // Convert to reporting currency
      let reportingValue = totalValue
      if (company.currency !== reportingCurrency) {
        try {
          reportingValue = await convertCurrency(totalValue, company.currency, reportingCurrency, targetDate)
        } catch (error) {
          console.warn(`Currency conversion failed:`, error)
        }
      }
      
      // Category breakdown
      const categoryBreakdown = stockData?.reduce((acc, item) => {
        const category = item.stock_items?.category || 'UNKNOWN'
        acc[category] = (acc[category] || 0) + Number(item.total_value || 0)
        return acc
      }, {} as Record<string, number>) || {}
      
      return {
        company_code: companyCode,
        company_name: company.company_name,
        company_currency: company.currency,
        material_count: stockData?.length || 0,
        total_quantity: totalQuantity,
        company_value: totalValue,
        reporting_value: reportingValue,
        category_breakdown: categoryBreakdown
      }
    })
  )
  
  return {
    reporting_currency: reportingCurrency,
    reporting_date: targetDate,
    companies: companyData.filter(Boolean)
  }
}

function createEmptyConsolidation(groupData: any): ConsolidatedStockData {
  return {
    group_code: groupData.group_code,
    group_name: groupData.group_name,
    reporting_currency: groupData.reporting_currency,
    total_companies: 0,
    total_materials: 0,
    total_value_reporting: 0,
    companies: []
  }
}
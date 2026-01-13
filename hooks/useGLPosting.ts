import { useState, useEffect } from 'react'
import { FinanceService } from '../domains/finance/FinanceService'

interface GLAccount {
  account_number: string
  account_name: string
  account_type: string
}

interface CostCenter {
  cost_center_code: string
  cost_center_name: string
}

interface Project {
  code: string
  name: string
}

interface GLConfig {
  balance_tolerance: number
  minimum_entries: number
}

const financeService = new FinanceService()

export const useGLPosting = (companyCode: string) => {
  const [accounts, setAccounts] = useState<GLAccount[]>([])
  const [costCenters, setCostCenters] = useState<CostCenter[]>([])
  const [projects, setProjects] = useState<Project[]>([])
  const [companies, setCompanies] = useState<{code: string, name: string}[]>([])
  const [config, setConfig] = useState<GLConfig>({balance_tolerance: 0.01, minimum_entries: 2})
  const [loading, setLoading] = useState(true)
  const [dataError, setDataError] = useState<{accounts?: string, costCenters?: string, projects?: string}>({})
  const [retryCount, setRetryCount] = useState<{accounts: number, costCenters: number, projects: number}>({accounts: 0, costCenters: 0, projects: 0})

  const loadCompanies = async () => {
    try {
      const data = await financeService.getCompanies()
      setCompanies(data)
    } catch (error) {
      console.error('Error loading companies:', error)
    }
  }

  const loadData = async () => {
    if (!companyCode) return
    
    setDataError({})
    setLoading(true)

    try {
      // Load configuration
      const configData = await financeService.getGLPostingConfig(companyCode)
      const configMap = configData.reduce((acc: any, item: any) => {
        acc[item.config_key] = item.data_type === 'decimal' ? parseFloat(item.config_value) : 
                               item.data_type === 'integer' ? parseInt(item.config_value) : 
                               item.config_value
        return acc
      }, {})
      setConfig({
        balance_tolerance: configMap.balance_tolerance || 0.01,
        minimum_entries: configMap.minimum_entries || 2
      })
    } catch (error) {
      console.warn('Failed to load GL config, using defaults:', error)
    }

    // Load accounts
    try {
      const accountsData = await financeService.getChartOfAccounts(companyCode)
      setAccounts(accountsData.map((acc: any) => ({
        account_number: acc.account_code,
        account_name: acc.account_name,
        account_type: acc.account_type
      })))
      setRetryCount(prev => ({ ...prev, accounts: 0 }))
    } catch (error) {
      console.error('Failed to load accounts:', error)
      setDataError(prev => ({ ...prev, accounts: `Failed to load chart of accounts: ${error.message}` }))
      setAccounts([])
      setRetryCount(prev => ({ ...prev, accounts: prev.accounts + 1 }))
    }

    // Load cost centers
    try {
      const costCenterData = await financeService.getCostCenters(companyCode)
      setCostCenters(costCenterData.map((cc: any) => ({
        cost_center_code: cc.cost_center_code,
        cost_center_name: cc.cost_center_name
      })))
      setRetryCount(prev => ({ ...prev, costCenters: 0 }))
    } catch (error) {
      console.error('Failed to load cost centers:', error)
      setDataError(prev => ({ ...prev, costCenters: `Failed to load cost centers: ${error.message}` }))
      setCostCenters([])
      setRetryCount(prev => ({ ...prev, costCenters: prev.costCenters + 1 }))
    }

    // Load projects
    try {
      const projectData = await financeService.getWBSElements(companyCode)
      setProjects(projectData.map((wbs: any) => ({
        code: wbs.wbs_element,
        name: wbs.wbs_description
      })))
      setRetryCount(prev => ({ ...prev, projects: 0 }))
    } catch (error) {
      console.error('Failed to load projects:', error)
      setDataError(prev => ({ ...prev, projects: `Failed to load WBS elements: ${error.message}` }))
      setProjects([])
      setRetryCount(prev => ({ ...prev, projects: prev.projects + 1 }))
    }

    setLoading(false)
  }

  const postDocument = async (document: any, userId: string) => {
    try {
      return await financeService.createGLPosting(document, userId)
    } catch (error) {
      console.error('Error posting document:', error)
      return { success: false, error: error.message }
    }
  }

  useEffect(() => {
    loadCompanies()
  }, [])

  useEffect(() => {
    if (companyCode) {
      loadData()
    }
  }, [companyCode])

  return {
    accounts,
    costCenters,
    projects,
    companies,
    config,
    loading,
    dataError,
    retryCount,
    postDocument,
    refreshData: loadData
  }
}
// Service Layer - Business Logic
import { ProjectRepository } from './repositories/projectRepository'

const projectRepository = new ProjectRepository()

export async function getProjectSummary(companyCode: string = 'C001') {
  try {
    const journalData = await projectRepository.getUniversalJournalData(companyCode)
    const projectData = await projectRepository.getProjectBudgets()

    const budgetLookup = projectData.reduce((acc, project) => {
      acc[project.code] = project.budget
      return acc
    }, {})

    const projectSummary = journalData.reduce((acc, entry) => {
      const project = entry.project_code
      const glAccount = entry.gl_account
      
      if (!acc[project]) {
        acc[project] = {
          project_code: project,
          budget: budgetLookup[project] || 0,
          total_costs: 0,
          total_revenue: 0,
          net_amount: 0,
          transaction_count: 0,
          last_posting_date: entry.posting_date
        }
      }

      acc[project].transaction_count++
      const amount = parseFloat(entry.company_amount)
      
      if (glAccount >= '400000' && glAccount <= '499999') {
        if (entry.debit_credit === 'C') {
          acc[project].total_revenue += amount
        } else {
          acc[project].total_revenue -= amount
        }
      }
      else if (glAccount >= '500000' && glAccount <= '699999') {
        if (entry.debit_credit === 'D') {
          acc[project].total_costs += amount
        } else {
          acc[project].total_costs -= amount
        }
      }
      
      acc[project].net_amount = acc[project].total_revenue - acc[project].total_costs

      return acc
    }, {})

    return Object.values(projectSummary)
  } catch (error) {
    console.error('Error getting project summary:', error)
    return []
  }
}

export async function getProjectDashboardData(companyCode: string = 'C001') {
  try {
    const projects = await getProjectSummary(companyCode)
    
    const totalProjects = projects.length
    const totalCosts = projects.reduce((sum, p: any) => sum + p.total_costs, 0)
    const totalRevenue = projects.reduce((sum, p: any) => sum + p.total_revenue, 0)
    const netProfit = totalRevenue - totalCosts

    return {
      summary: {
        totalProjects,
        totalCosts,
        totalRevenue,
        netProfit,
        profitMargin: totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0
      },
      projects
    }
  } catch (error) {
    console.error('Error getting project dashboard data:', error)
    return { summary: {}, projects: [] }
  }
}

export async function getProjectCosts(projectCode: string, companyCode: string = 'C001') {
  try {
    return await projectRepository.getProjectReport(companyCode, projectCode)
  } catch (error) {
    console.error('Error getting project costs:', error)
    return []
  }
}

export async function getProjectWBSDetails(projectCode: string, companyCode: string = 'C001') {
  try {
    const journalData = await projectRepository.getUniversalJournalData(companyCode)
    const projectData = journalData.filter(entry => entry.project_code === projectCode && entry.wbs_element)

    const wbsSummary = projectData.reduce((acc, entry) => {
      const wbs = entry.wbs_element
      if (!acc[wbs]) {
        acc[wbs] = {
          wbs_element: wbs,
          total_debits: 0,
          total_credits: 0,
          net_amount: 0,
          transaction_count: 0,
          last_posting_date: entry.posting_date
        }
      }

      acc[wbs].transaction_count++
      if (entry.debit_credit === 'D') {
        acc[wbs].total_debits += parseFloat(entry.company_amount)
      } else {
        acc[wbs].total_credits += parseFloat(entry.company_amount)
      }
      acc[wbs].net_amount = acc[wbs].total_debits - acc[wbs].total_credits

      return acc
    }, {})

    return Object.values(wbsSummary)
  } catch (error) {
    console.error('Error getting WBS details:', error)
    return []
  }
}

export async function getProjectReport(projectCode: string, companyCode: string = 'C001', fromDate?: string, toDate?: string) {
  try {
    return await projectRepository.getProjectReport(companyCode, projectCode, fromDate, toDate)
  } catch (error) {
    console.error('Error getting project report:', error)
    return []
  }
}
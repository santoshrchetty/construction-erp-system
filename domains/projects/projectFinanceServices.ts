// Project Services - Domain Layer
import { createClient } from '@supabase/supabase-js'

// Use environment variables for Supabase client
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing Supabase environment variables')
}

const supabase = createClient(supabaseUrl, supabaseKey)

export async function getProjectCosts(projectCode: string, companyCode: string = 'C001') {
  try {
    const { data, error } = await supabase
      .rpc('get_project_report', {
        p_company_code: companyCode,
        p_project_code: projectCode,
        p_from_date: null,
        p_to_date: new Date().toISOString().split('T')[0]
      })

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error getting project costs:', error)
    return []
  }
}

export async function getProjectSummary(companyCode: string = 'C001') {
  try {
    // Get financial data from universal_journal
    const { data: journalData, error: journalError } = await supabase
      .from('universal_journal')
      .select(`
        project_code,
        gl_account,
        debit_credit,
        company_amount,
        posting_date,
        cost_center,
        wbs_element
      `)
      .eq('company_code', companyCode)
      .not('project_code', 'is', null)
      .order('posting_date', { ascending: false })

    if (journalError) throw journalError

    // Get project budget data
    const { data: projectData, error: projectError } = await supabase
      .from('projects')
      .select('code, budget')

    if (projectError) throw projectError

    // Create budget lookup
    const budgetLookup = projectData.reduce((acc, project) => {
      acc[project.code] = project.budget
      return acc
    }, {})

    // Group by project
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
      
      // Revenue accounts (400000-499999) - Credits increase revenue
      if (glAccount >= '400000' && glAccount <= '499999') {
        if (entry.debit_credit === 'C') {
          acc[project].total_revenue += amount
        } else {
          acc[project].total_revenue -= amount
        }
      }
      // Cost accounts (500000-699999) - Debits increase costs
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

export async function getProjectWBSDetails(projectCode: string, companyCode: string = 'C001') {
  try {
    const { data, error } = await supabase
      .from('universal_journal')
      .select(`
        wbs_element,
        debit_credit,
        company_amount,
        posting_date
      `)
      .eq('company_code', companyCode)
      .eq('project_code', projectCode)
      .not('wbs_element', 'is', null)
      .order('posting_date', { ascending: false })

    if (error) throw error

    // Group by WBS element
    const wbsSummary = data.reduce((acc, entry) => {
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
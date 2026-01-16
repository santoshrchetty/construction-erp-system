// Handler Layer - Business Orchestration Only
import * as projectFinanceServices from '@/domains/projects/projectFinanceServices'
import * as projectCreationServices from '@/domains/projects/projectCreationService'

export async function handleProjects(action: string, body: any, method: string = 'GET') {
  try {
    switch (action) {
      case 'create':
        if (method === 'POST') {
          return await projectCreationServices.createProject(body)
        }
        return { error: 'POST method required for create action' }

      case 'categories':
        return await projectCreationServices.getProjectCategories()

      case 'companies':
        return await projectCreationServices.getCompanyCodes()

      case 'persons-responsible':
        return await projectCreationServices.getPersonsResponsible()

      case 'organizational-data':
        return await projectCreationServices.getOrganizationalData(body.company_code)

      case 'numbering-patterns':
        return await projectCreationServices.getNumberingPatterns(body)

      case 'project-types':
        return await projectCreationServices.getProjectTypes(body.category_code)

      case 'generate-code':
        return await projectCreationServices.generateCode(body)

      case 'costs':
        const { projectCode, companyCode: costsCompany } = body || { projectCode: null, companyCode: 'C001' }
        return await projectFinanceServices.getProjectCosts(projectCode, costsCompany)

      case 'summary':
        const { companyCode: summaryCompany } = body || { companyCode: 'C001' }
        return await projectFinanceServices.getProjectSummary(summaryCompany)

      case 'dashboard':
        const { companyCode: dashboardCompany } = body || { companyCode: 'C001' }
        return await projectFinanceServices.getProjectDashboardData(dashboardCompany)

      case 'wbs-details':
        const { projectCode: wbsProject, companyCode: wbsCompany } = body || { projectCode: null, companyCode: 'C001' }
        const wbsDetails = await projectFinanceServices.getProjectWBSDetails(wbsProject, wbsCompany)
        return { wbs_details: wbsDetails }

      case 'reports':
        const { projectCode: reportProject, fromDate, toDate, companyCode: reportCompany } = 
          body || { projectCode: null, fromDate: null, toDate: null, companyCode: 'C001' }
        return await projectFinanceServices.getProjectReport(reportProject, reportCompany, fromDate, toDate)

      default:
        return { action, message: `${action} functionality available` }
    }
  } catch (error) {
    console.error('Project handler error:', error)
    throw error
  }
}
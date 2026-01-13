// Project API Handler - API Layer
import { NextRequest } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import * as projectFinanceServices from '@/domains/projects/projectFinanceServices'
import { ProjectCreationService, CreateProjectRequest } from '@/domains/projects/projectCreationService'

const projectCreationService = new ProjectCreationService()

export async function handleProjects(action: string, request: NextRequest, method: string = 'GET') {
  try {
    // Get server supabase client with cookies for authentication
    const supabase = createServiceClient()
    switch (action) {
      case 'create':
        if (method === 'POST') {
          const body: CreateProjectRequest = await request.json()
          
          // Reserve project code using selected pattern
          const { data: projectCode, error: codeError } = await supabase
            .rpc('generate_project_number_with_pattern', {
              p_entity_type: 'PROJECT',
              p_company_code: body.company_code,
              p_pattern: body.selected_pattern
            })
          
          if (codeError) throw new Error(`Failed to generate project code: ${codeError.message}`)
          
          // Get current user
          const { data: { user }, error: userError } = await supabase.auth.getUser()
          if (userError) throw new Error(`Auth error: ${userError.message}`)
          
          // Create project
          const { data, error } = await supabase
            .from('projects')
            .insert({
              code: projectCode,
              name: body.name,
              description: body.description,
              project_type: body.project_type,
              start_date: body.start_date,
              planned_end_date: body.planned_end_date,
              budget: body.budget,
              location: body.location,
              company_code_id: body.company_code,
              person_responsible_id: body.person_responsible_id || null,
              cost_center_id: body.cost_center_id,
              profit_center_id: body.profit_center_id,
              plant_id: body.plant_id,
              status: 'planning',
              created_by: user?.id,
              working_days: body.working_days,
              holidays: body.holidays
            })
            .select('id, code')
            .single()
          
          if (error) throw new Error(`Failed to create project: ${error.message}`)
          return { id: data.id, code: data.code }
        }
        return { error: 'POST method required for create action' }

      case 'categories':
        return await projectCreationService.getProjectCategories()

      case 'generate-number':
        // COMMENTED OUT - Overlapping with project creation numbering
        // const entityType = new URL(request.url).searchParams.get('entity_type') as 'PROJECT'
        // const companyCode = new URL(request.url).searchParams.get('company_code') || 'C001'
        // const projectNumber = await projectCreationService.generateProjectNumber({
        //   entity_type: entityType,
        //   company_code: companyCode
        // })
        // return { project_number: projectNumber }
        return { error: 'Use project creation flow for number generation' }

      case 'costs':
        const { projectCode, companyCode: costsCompany } = method === 'POST' ? await request.json() : 
          { projectCode: null, companyCode: 'C001' }
        return await projectFinanceServices.getProjectCosts(projectCode, costsCompany)

      case 'summary':
        const { companyCode: summaryCompany } = method === 'POST' ? await request.json() : 
          { companyCode: 'C001' }
        return await projectFinanceServices.getProjectSummary(summaryCompany)

      case 'dashboard':
        const { companyCode: dashboardCompany } = method === 'POST' ? await request.json() : 
          { companyCode: 'C001' }
        return await projectFinanceServices.getProjectDashboardData(dashboardCompany)

      case 'wbs-details':
        const { projectCode: wbsProject, companyCode: wbsCompany } = method === 'POST' ? await request.json() : 
          { projectCode: null, companyCode: 'C001' }
        const wbsDetails = await projectFinanceServices.getProjectWBSDetails(wbsProject, wbsCompany)
        return { wbs_details: wbsDetails }

      case 'reports':
        const { projectCode: reportProject, fromDate, toDate, companyCode: reportCompany } = 
          method === 'POST' ? await request.json() : { projectCode: null, fromDate: null, toDate: null, companyCode: 'C001' }
        
        const { data, error } = await supabase
          .rpc('get_project_report', {
            p_company_code: reportCompany,
            p_project_code: reportProject,
            p_from_date: fromDate,
            p_to_date: toDate || new Date().toISOString().split('T')[0]
          })

        if (error) throw error
        return data || []

      default:
        return { action, message: `${action} functionality available` }
    }
  } catch (error) {
    console.error('Project handler error:', error)
    throw error
  }
}
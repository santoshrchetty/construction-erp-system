// Service Layer - Project Creation Domain
import { ProjectRepository } from './repositories/projectRepository'

const projectRepository = new ProjectRepository()

export async function createProject(request: any) {
  try {
    const projectCode = await projectRepository.generateProjectCode({
      entity_type: 'PROJECT',
      company_code: request.company_code,
      pattern: request.selected_pattern
    })
    
    const user = await projectRepository.getCurrentUser()
    
    const projectData = {
      code: projectCode,
      name: request.name,
      description: request.description,
      project_type: request.project_type,
      category_code: request.category_code || 'CUSTOMER',
      start_date: request.start_date,
      planned_end_date: request.planned_end_date,
      budget: request.budget,
      location: request.location,
      company_code: request.company_code,
      person_responsible_id: request.person_responsible_id || null,
      cost_center_id: request.cost_center_id,
      profit_center_id: request.profit_center_id,
      plant_id: request.plant_id,
      status: 'planning',
      created_by: user?.id,
      working_days: request.working_days,
      holidays: request.holidays
    }
    
    return await projectRepository.createProject(projectData)
  } catch (error) {
    console.error('Error creating project:', error)
    throw error
  }
}

export async function getProjectCategories() {
  try {
    return await projectRepository.getProjectCategories()
  } catch (error) {
    console.error('Error getting project categories:', error)
    throw error
  }
}

export async function getCompanyCodes() {
  try {
    return await projectRepository.getCompanyCodes()
  } catch (error) {
    console.error('Error getting company codes:', error)
    throw error
  }
}

export async function getPersonsResponsible() {
  try {
    return await projectRepository.getPersonsResponsible()
  } catch (error) {
    console.error('Error getting persons responsible:', error)
    throw error
  }
}

export async function getOrganizationalData(companyCode: string) {
  try {
    return await projectRepository.getOrganizationalData(companyCode)
  } catch (error) {
    console.error('Error getting organizational data:', error)
    throw error
  }
}

export async function getNumberingPatterns(params: any) {
  try {
    return await projectRepository.getNumberingPatterns(params)
  } catch (error) {
    console.error('Error getting numbering patterns:', error)
    throw error
  }
}

export async function getProjectTypes(categoryCode: string) {
  try {
    return await projectRepository.getProjectTypes(categoryCode)
  } catch (error) {
    console.error('Error getting project types:', error)
    throw error
  }
}

export async function generateCode(params: any) {
  try {
    const code = await projectRepository.generateProjectCode(params)
    return { code }
  } catch (error) {
    console.error('Error generating code:', error)
    throw error
  }
}
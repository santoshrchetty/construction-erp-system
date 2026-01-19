// Layer 2: Service - Business Logic
import { repositories } from '@/lib/repositories'

export interface ResourcePlanningFilter {
  projectId: string
  dateFrom: string
  dateTo: string
  limit?: number
}

export class ResourcePlanningService {
  async getActivitiesForResourcePlanning(filter: ResourcePlanningFilter) {
    const activities = await repositories.activities.findWithResourceCounts(
      filter.projectId,
      filter.dateFrom,
      filter.dateTo,
      filter.limit
    )
    
    // Add cost calculations for each activity
    const activitiesWithCosts = await Promise.all(
      activities.map(async (activity: any) => {
        const costs = await this.calculateActivityCosts(activity.id)
        return {
          ...activity,
          ...costs
        }
      })
    )
    
    return activitiesWithCosts
  }

  async calculateActivityCosts(activityId: string) {
    const supabase = await (await import('@/lib/supabase/server')).createServiceClient()
    
    // Get activity code for universal journal lookup
    const { data: activity } = await supabase
      .from('activities')
      .select('code')
      .eq('id', activityId)
      .single()
    
    if (!activity) {
      return {
        material_cost: 0, equipment_cost: 0, manpower_cost: 0,
        services_cost: 0, subcontractor_cost: 0, total_planned_cost: 0,
        material_actual: 0, equipment_actual: 0, manpower_actual: 0,
        services_actual: 0, subcontractor_actual: 0, total_actual_cost: 0
      }
    }
    
    // Get PLANNED costs from resource assignments
    const { data: materials } = await supabase
      .from('activity_materials')
      .select('required_quantity, unit_cost')
      .eq('activity_id', activityId)
    
    const material_cost = materials?.reduce((sum, m) => sum + (m.required_quantity * m.unit_cost), 0) || 0
    
    const { data: equipment } = await supabase
      .from('activity_equipment')
      .select('required_hours, hourly_rate')
      .eq('activity_id', activityId)
    
    const equipment_cost = equipment?.reduce((sum, e) => sum + (e.required_hours * e.hourly_rate), 0) || 0
    
    const { data: manpower } = await supabase
      .from('activity_manpower')
      .select('required_hours, hourly_rate')
      .eq('activity_id', activityId)
    
    const manpower_cost = manpower?.reduce((sum, m) => sum + (m.required_hours * m.hourly_rate), 0) || 0
    
    const { data: services } = await supabase
      .from('activity_services')
      .select('unit_cost')
      .eq('activity_id', activityId)
    
    const services_cost = services?.reduce((sum, s) => sum + s.unit_cost, 0) || 0
    
    const { data: subcontractors } = await supabase
      .from('activity_subcontractors')
      .select('contract_value')
      .eq('activity_id', activityId)
    
    const subcontractor_cost = subcontractors?.reduce((sum, s) => sum + s.contract_value, 0) || 0
    
    const total_planned_cost = material_cost + equipment_cost + manpower_cost + services_cost + subcontractor_cost
    
    // Get ACTUAL costs from universal_journal using activity_code and cost_elements
    // Materials
    const { data: materialActuals } = await supabase
      .from('universal_journal')
      .select('company_amount, cost_elements!inner(cost_element_type)')
      .eq('activity_code', activity.code)
      .eq('debit_credit', 'D')
      .eq('cost_elements.cost_element_type', 'MATERIAL')
    
    const material_actual = materialActuals?.reduce((sum, j) => sum + parseFloat(j.company_amount.toString()), 0) || 0
    
    // Equipment
    const { data: equipmentActuals } = await supabase
      .from('universal_journal')
      .select('company_amount, cost_elements!inner(cost_element_type)')
      .eq('activity_code', activity.code)
      .eq('debit_credit', 'D')
      .eq('cost_elements.cost_element_type', 'EQUIPMENT')
    
    const equipment_actual = equipmentActuals?.reduce((sum, j) => sum + parseFloat(j.company_amount.toString()), 0) || 0
    
    // Manpower
    const { data: manpowerActuals } = await supabase
      .from('universal_journal')
      .select('company_amount, cost_elements!inner(cost_element_type)')
      .eq('activity_code', activity.code)
      .eq('debit_credit', 'D')
      .eq('cost_elements.cost_element_type', 'LABOR')
    
    const manpower_actual = manpowerActuals?.reduce((sum, j) => sum + parseFloat(j.company_amount.toString()), 0) || 0
    
    // Services (using OVERHEAD as proxy)
    const { data: servicesActuals } = await supabase
      .from('universal_journal')
      .select('company_amount, cost_elements!inner(cost_element_type)')
      .eq('activity_code', activity.code)
      .eq('debit_credit', 'D')
      .eq('cost_elements.cost_element_type', 'OVERHEAD')
    
    const services_actual = servicesActuals?.reduce((sum, j) => sum + parseFloat(j.company_amount.toString()), 0) || 0
    
    // Subcontractors
    const { data: subcontractorActuals } = await supabase
      .from('universal_journal')
      .select('company_amount, cost_elements!inner(cost_element_type)')
      .eq('activity_code', activity.code)
      .eq('debit_credit', 'D')
      .eq('cost_elements.cost_element_type', 'SUBCONTRACTOR')
    
    const subcontractor_actual = subcontractorActuals?.reduce((sum, j) => sum + parseFloat(j.company_amount.toString()), 0) || 0
    
    const total_actual_cost = material_actual + equipment_actual + manpower_actual + services_actual + subcontractor_actual
    
    return {
      material_cost,
      equipment_cost,
      manpower_cost,
      services_cost,
      subcontractor_cost,
      total_planned_cost,
      material_actual,
      equipment_actual,
      manpower_actual,
      services_actual,
      subcontractor_actual,
      total_actual_cost
    }
  }

  async getResourceSummary(projectId: string) {
    const activities = await repositories.activities.findByProject(projectId)
    
    // Business logic: Calculate resource summary
    const summary = {
      totalActivities: activities.length,
      activitiesWithMaterials: 0,
      activitiesWithEquipment: 0,
      activitiesWithManpower: 0,
      activitiesNeedingResources: 0
    }

    // Add more business logic as needed
    return summary
  }

  // Services
  async getActivityServices(activityId: string) {
    return repositories.activities.findServicesByActivity(activityId)
  }

  async attachService(activityId: string, serviceData: any) {
    // Business logic: Validate and prepare data
    const service = {
      activity_id: activityId,
      ...serviceData
    }
    return repositories.activities.createService(service)
  }

  // Subcontractors
  async getActivitySubcontractors(activityId: string) {
    return repositories.activities.findSubcontractorsByActivity(activityId)
  }

  async attachSubcontractor(activityId: string, subcontractorData: any) {
    // Business logic: Validate and prepare data
    const subcontractor = {
      activity_id: activityId,
      ...subcontractorData
    }
    return repositories.activities.createSubcontractor(subcontractor)
  }
}

export const resourcePlanningService = new ResourcePlanningService()

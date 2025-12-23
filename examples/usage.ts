import { repositories } from '../lib/repositories'
import { CreateProject, CreateTask, CreateVendor } from '../types'

// Example usage of the repositories
export async function exampleUsage() {
  try {
    // Create a new project
    const newProject: CreateProject = {
      name: 'Downtown Office Complex',
      code: 'DOC-2024-001',
      project_type: 'commercial',
      start_date: '2024-01-15',
      planned_end_date: '2024-12-31',
      budget: 5000000
    }
    
    const project = await repositories.projects.create(newProject)
    console.log('Created project:', project)

    // Find active projects
    const activeProjects = await repositories.projects.findActiveProjects()
    console.log('Active projects:', activeProjects)

    // Create WBS node
    const wbsNode = await repositories.wbs.create({
      project_id: project.id,
      code: 'DOC-01',
      name: 'Foundation Phase',
      node_type: 'phase',
      level: 1,
      sequence_order: 1,
      budget_allocation: 1500000
    })

    // Create activity
    const activity = await repositories.activities.create({
      project_id: project.id,
      wbs_node_id: wbsNode.id,
      code: 'ACT-001',
      name: 'Site Preparation',
      planned_start_date: '2024-01-15',
      planned_end_date: '2024-02-15',
      budget_amount: 300000
    })

    // Create task
    const task = await repositories.tasks.create({
      project_id: project.id,
      activity_id: activity.id,
      name: 'Site Clearing',
      status: 'not_started',
      priority: 'high',
      planned_hours: 40,
      created_by: 'user-id-here'
    })

    // Create vendor
    const vendor = await repositories.vendors.create({
      name: 'ABC Construction Supplies',
      code: 'VEN-001',
      email: 'contact@abcsupplies.com',
      status: 'active'
    })

    // Create purchase order
    const po = await repositories.purchaseOrders.create({
      project_id: project.id,
      po_number: 'PO-2024-001',
      vendor_id: vendor.id,
      issue_date: '2024-01-20',
      delivery_date: '2024-02-20',
      total_amount: 100000,
      created_by: 'user-id-here'
    })

    // Create timesheet
    const timesheet = await repositories.timesheets.create({
      user_id: 'user-id-here',
      project_id: project.id,
      week_ending_date: '2024-01-26'
    })

    // Add timesheet entry
    const entry = await repositories.timesheetEntries.create({
      timesheet_id: timesheet.id,
      task_id: task.id,
      entry_date: '2024-01-22',
      hours: 8,
      description: 'Site clearing work'
    })

    console.log('All entities created successfully!')

  } catch (error) {
    console.error('Error:', error)
  }
}
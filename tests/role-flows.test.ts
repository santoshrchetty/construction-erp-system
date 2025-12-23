import { repositories } from '@/lib/repositories'
import { createServerClient } from '@/lib/supabase'

// Mock user contexts for different roles
const mockUsers = {
  admin: { id: 'admin-uuid', role: 'Admin' },
  manager: { id: 'manager-uuid', role: 'Manager' },
  procurement: { id: 'procurement-uuid', role: 'Procurement' },
  storekeeper: { id: 'storekeeper-uuid', role: 'Storekeeper' },
  engineer: { id: 'engineer-uuid', role: 'Engineer' },
  finance: { id: 'finance-uuid', role: 'Finance' },
  hr: { id: 'hr-uuid', role: 'HR' },
  employee: { id: 'employee-uuid', role: 'Employee' }
}

describe('Role-wise Flow Tests', () => {
  let testProject: any
  let testWBS: any

  beforeAll(async () => {
    // Setup test data
    testProject = await repositories.projects.create({
      name: 'Test Construction Project',
      code: 'TCP-001',
      project_type: 'commercial',
      start_date: '2024-01-01',
      planned_end_date: '2024-12-31',
      budget: 1000000
    })

    testWBS = await repositories.wbs.create({
      project_id: testProject.id,
      code: 'WBS-01',
      name: 'Foundation Phase',
      node_type: 'phase',
      level: 1,
      sequence_order: 1
    })
  })

  describe('Admin Role Flow', () => {
    test('Admin can create and manage projects', async () => {
      const project = await repositories.projects.create({
        name: 'Admin Test Project',
        code: 'ATP-001',
        project_type: 'residential',
        start_date: '2024-02-01',
        planned_end_date: '2024-08-31',
        budget: 500000
      })
      expect(project).toBeDefined()
      expect(project.name).toBe('Admin Test Project')
    })

    test('Admin can manage all users and roles', async () => {
      const supabase = createServerClient()
      const { data: roles } = await supabase.from('roles').select('*')
      expect(roles).toBeDefined()
      expect(roles?.length).toBeGreaterThan(0)
    })
  })

  describe('Manager Role Flow', () => {
    test('Manager can create WBS structure', async () => {
      const wbs = await repositories.wbs.create({
        project_id: testProject.id,
        code: 'WBS-02',
        name: 'Structural Phase',
        node_type: 'phase',
        level: 1,
        sequence_order: 2,
        budget_allocation: 300000
      })
      expect(wbs).toBeDefined()
      expect(wbs.name).toBe('Structural Phase')
    })

    test('Manager can assign tasks and track progress', async () => {
      const task = await repositories.tasks.create({
        project_id: testProject.id,
        wbs_node_id: testWBS.id,
        name: 'Foundation Excavation',
        status: 'not_started',
        priority: 'high',
        planned_start_date: '2024-01-15',
        planned_end_date: '2024-01-30',
        planned_hours: 80,
        assigned_to: mockUsers.engineer.id,
        created_by: mockUsers.manager.id
      })
      expect(task).toBeDefined()
      expect(task.assigned_to).toBe(mockUsers.engineer.id)
    })
  })

  describe('Procurement Officer Flow', () => {
    test('Procurement can create vendors', async () => {
      const vendor = await repositories.procurement.createVendor({
        name: 'ABC Construction Supplies',
        code: 'VEN-001',
        contact_person: 'John Smith',
        email: 'john@abc-supplies.com',
        phone: '+1-555-0123',
        status: 'active',
        specializations: ['concrete', 'steel', 'aggregates']
      })
      expect(vendor).toBeDefined()
      expect(vendor.name).toBe('ABC Construction Supplies')
    })

    test('Procurement can create purchase orders', async () => {
      const vendor = await repositories.procurement.createVendor({
        name: 'Steel Suppliers Ltd',
        code: 'VEN-002',
        contact_person: 'Jane Doe',
        email: 'jane@steel-suppliers.com',
        status: 'active'
      })

      const po = await repositories.procurement.createPurchaseOrder({
        project_id: testProject.id,
        po_number: 'PO-001',
        vendor_id: vendor.id,
        po_type: 'standard',
        issue_date: '2024-01-20',
        delivery_date: '2024-02-15',
        total_amount: 50000,
        created_by: mockUsers.procurement.id,
        lines: [{
          line_number: 1,
          description: 'Steel Rebar 12mm',
          quantity: 1000,
          unit: 'kg',
          unit_rate: 50
        }]
      })
      expect(po).toBeDefined()
      expect(po.po_number).toBe('PO-001')
    })
  })

  describe('Storekeeper Flow', () => {
    test('Storekeeper can create stores', async () => {
      const store = await repositories.stores.create({
        project_id: testProject.id,
        name: 'Main Warehouse',
        code: 'WH-001',
        location: 'Site Entrance',
        store_keeper_id: mockUsers.storekeeper.id
      })
      expect(store).toBeDefined()
      expect(store.name).toBe('Main Warehouse')
    })

    test('Storekeeper can receive goods', async () => {
      const store = await repositories.stores.create({
        project_id: testProject.id,
        name: 'Materials Store',
        code: 'MS-001',
        location: 'Site Office',
        store_keeper_id: mockUsers.storekeeper.id
      })

      const vendor = await repositories.procurement.createVendor({
        name: 'Cement Suppliers',
        code: 'VEN-003',
        contact_person: 'Mike Johnson',
        email: 'mike@cement.com',
        status: 'active'
      })

      const po = await repositories.procurement.createPurchaseOrder({
        project_id: testProject.id,
        po_number: 'PO-002',
        vendor_id: vendor.id,
        po_type: 'standard',
        issue_date: '2024-01-25',
        delivery_date: '2024-02-20',
        total_amount: 25000,
        created_by: mockUsers.procurement.id,
        lines: [{
          line_number: 1,
          description: 'Portland Cement',
          quantity: 500,
          unit: 'bags',
          unit_rate: 50
        }]
      })

      const grn = await repositories.stores.createGoodsReceipt({
        project_id: testProject.id,
        po_id: po.id,
        store_id: store.id,
        grn_number: 'GRN-001',
        vendor_id: vendor.id,
        receipt_date: '2024-02-20',
        received_by: mockUsers.storekeeper.id,
        lines: [{
          po_line_id: po.lines[0].id,
          ordered_quantity: 500,
          received_quantity: 500,
          accepted_quantity: 500,
          unit_rate: 50
        }]
      })
      expect(grn).toBeDefined()
      expect(grn.grn_number).toBe('GRN-001')
    })
  })

  describe('Employee Role Flow', () => {
    test('Employee can submit timesheets', async () => {
      const timesheet = await repositories.timesheets.create({
        user_id: mockUsers.employee.id,
        project_id: testProject.id,
        week_ending_date: '2024-02-04',
        entries: [{
          entry_date: '2024-01-29',
          hours: 8,
          entry_type: 'regular',
          description: 'Foundation work',
          billable: true
        }]
      })
      expect(timesheet).toBeDefined()
      expect(timesheet.total_hours).toBe(8)
    })
  })

  afterAll(async () => {
    const supabase = createServerClient()
    await supabase.from('projects').delete().eq('id', testProject.id)
  })
})
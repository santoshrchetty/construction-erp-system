import { repositories } from '@/lib/repositories'
import { createServerClient } from '@/lib/supabase'

describe('Workflow Integration Tests', () => {
  let testProject: any
  let testWBS: any
  let testVendor: any
  let testStore: any

  beforeAll(async () => {
    // Setup test project
    testProject = await repositories.projects.create({
      name: 'Integration Test Project',
      code: 'ITP-001',
      project_type: 'commercial',
      start_date: '2024-01-01',
      planned_end_date: '2024-12-31',
      budget: 2000000
    })

    testWBS = await repositories.wbs.create({
      project_id: testProject.id,
      code: 'WBS-INT-01',
      name: 'Integration Test Phase',
      node_type: 'phase',
      level: 1,
      sequence_order: 1,
      budget_allocation: 500000
    })

    testVendor = await repositories.procurement.createVendor({
      name: 'Integration Test Vendor',
      code: 'ITV-001',
      contact_person: 'Test Contact',
      email: 'test@vendor.com',
      status: 'active'
    })

    testStore = await repositories.stores.create({
      project_id: testProject.id,
      name: 'Integration Test Store',
      code: 'ITS-001',
      location: 'Test Site'
    })
  })

  describe('Complete Procurement Workflow', () => {
    test('End-to-end procurement process', async () => {
      // 1. Create Purchase Order
      const po = await repositories.procurement.createPurchaseOrder({
        project_id: testProject.id,
        po_number: 'PO-INT-001',
        vendor_id: testVendor.id,
        po_type: 'standard',
        issue_date: '2024-01-15',
        delivery_date: '2024-02-01',
        total_amount: 100000,
        created_by: 'procurement-user-id',
        lines: [{
          line_number: 1,
          description: 'Steel Bars 16mm',
          quantity: 1000,
          unit: 'kg',
          unit_rate: 100
        }]
      })

      expect(po).toBeDefined()
      expect(po.status).toBe('draft')

      // 2. Approve Purchase Order
      const approvedPO = await repositories.procurement.approvePurchaseOrder(po.id, 'manager-user-id')
      expect(approvedPO.status).toBe('approved')

      // 3. Receive Goods
      const grn = await repositories.stores.createGoodsReceipt({
        project_id: testProject.id,
        po_id: po.id,
        store_id: testStore.id,
        grn_number: 'GRN-INT-001',
        vendor_id: testVendor.id,
        receipt_date: '2024-02-01',
        received_by: 'storekeeper-user-id',
        lines: [{
          po_line_id: po.lines[0].id,
          ordered_quantity: 1000,
          received_quantity: 1000,
          accepted_quantity: 1000,
          unit_rate: 100
        }]
      })

      expect(grn).toBeDefined()
      expect(grn.status).toBe('pending')

      // 4. Verify Stock Updated
      const stockLevels = await repositories.stores.getStockLevels(testProject.id)
      expect(stockLevels).toBeDefined()
      expect(stockLevels.length).toBeGreaterThan(0)

      // 5. Verify PO Status Updated
      const updatedPO = await repositories.procurement.findById(po.id)
      expect(updatedPO.status).toBe('fully_received')
    })
  })

  describe('Project Execution Workflow', () => {
    test('Task creation to completion workflow', async () => {
      // 1. Create Activity
      const activity = await repositories.wbs.createActivity({
        project_id: testProject.id,
        wbs_node_id: testWBS.id,
        code: 'ACT-INT-001',
        name: 'Foundation Work',
        planned_start_date: '2024-02-01',
        planned_end_date: '2024-02-28',
        planned_hours: 200,
        budget_amount: 50000
      })

      expect(activity).toBeDefined()

      // 2. Create Tasks
      const task1 = await repositories.tasks.create({
        project_id: testProject.id,
        wbs_node_id: testWBS.id,
        activity_id: activity.id,
        name: 'Excavation',
        status: 'not_started',
        priority: 'high',
        planned_start_date: '2024-02-01',
        planned_end_date: '2024-02-10',
        planned_hours: 80,
        assigned_to: 'engineer-user-id',
        created_by: 'manager-user-id'
      })

      const task2 = await repositories.tasks.create({
        project_id: testProject.id,
        wbs_node_id: testWBS.id,
        activity_id: activity.id,
        name: 'Foundation Pouring',
        status: 'not_started',
        priority: 'high',
        planned_start_date: '2024-02-11',
        planned_end_date: '2024-02-20',
        planned_hours: 120,
        assigned_to: 'engineer-user-id',
        created_by: 'manager-user-id'
      })

      // 3. Create Task Dependency
      const dependency = await repositories.tasks.createDependency({
        predecessor_task_id: task1.id,
        successor_task_id: task2.id,
        dependency_type: 'finish_to_start',
        lag_days: 1
      })

      expect(dependency).toBeDefined()

      // 4. Start Task 1
      const startedTask1 = await repositories.tasks.updateProgress(task1.id, {
        status: 'in_progress',
        actual_start_date: '2024-02-01',
        progress_percentage: 0
      })

      expect(startedTask1.status).toBe('in_progress')

      // 5. Log Time on Task 1
      const timesheet = await repositories.timesheets.create({
        user_id: 'engineer-user-id',
        project_id: testProject.id,
        week_ending_date: '2024-02-04',
        entries: [{
          task_id: task1.id,
          activity_id: activity.id,
          entry_date: '2024-02-01',
          hours: 8,
          entry_type: 'regular',
          description: 'Excavation work',
          billable: true
        }, {
          task_id: task1.id,
          activity_id: activity.id,
          entry_date: '2024-02-02',
          hours: 8,
          entry_type: 'regular',
          description: 'Excavation work',
          billable: true
        }]
      })

      expect(timesheet.total_hours).toBe(16)

      // 6. Update Task Progress
      const progressTask1 = await repositories.tasks.updateProgress(task1.id, {
        progress_percentage: 50,
        actual_hours: 40
      })

      expect(progressTask1.progress_percentage).toBe(50)

      // 7. Complete Task 1
      const completedTask1 = await repositories.tasks.updateProgress(task1.id, {
        status: 'completed',
        progress_percentage: 100,
        actual_end_date: '2024-02-10',
        actual_hours: 80
      })

      expect(completedTask1.status).toBe('completed')

      // 8. Start Task 2 (should be allowed after Task 1 completion)
      const startedTask2 = await repositories.tasks.updateProgress(task2.id, {
        status: 'in_progress',
        actual_start_date: '2024-02-12',
        progress_percentage: 0
      })

      expect(startedTask2.status).toBe('in_progress')
    })
  })

  describe('Cost Tracking Workflow', () => {
    test('Cost accumulation from multiple sources', async () => {
      const supabase = createServerClient()

      // 1. Create Cost Object
      const { data: costObject } = await supabase
        .from('cost_objects')
        .insert({
          project_id: testProject.id,
          wbs_node_id: testWBS.id,
          code: 'CO-INT-001',
          name: 'Foundation Costs',
          cost_type: 'material',
          budget_amount: 100000
        })
        .select()
        .single()

      expect(costObject).toBeDefined()

      // 2. Add Actual Costs from PO
      const { data: actualCost1 } = await supabase
        .from('actual_costs')
        .insert({
          project_id: testProject.id,
          cost_object_id: costObject.id,
          wbs_node_id: testWBS.id,
          cost_type: 'material',
          amount: 50000,
          cost_date: '2024-02-01',
          reference_type: 'PO',
          description: 'Steel purchase',
          created_by: 'system-user-id'
        })
        .select()
        .single()

      expect(actualCost1).toBeDefined()

      // 3. Add Labor Costs from Timesheet
      const { data: actualCost2 } = await supabase
        .from('actual_costs')
        .insert({
          project_id: testProject.id,
          cost_object_id: costObject.id,
          wbs_node_id: testWBS.id,
          cost_type: 'labor',
          amount: 15000,
          cost_date: '2024-02-05',
          reference_type: 'TIMESHEET',
          description: 'Labor costs',
          created_by: 'system-user-id'
        })
        .select()
        .single()

      expect(actualCost2).toBeDefined()

      // 4. Verify Total Costs
      const { data: totalCosts } = await supabase
        .from('actual_costs')
        .select('amount')
        .eq('cost_object_id', costObject.id)

      const total = totalCosts?.reduce((sum, cost) => sum + parseFloat(cost.amount), 0)
      expect(total).toBe(65000)

      // 5. Update Cost Object with Actual Amount
      const { data: updatedCostObject } = await supabase
        .from('cost_objects')
        .update({ actual_amount: total })
        .eq('id', costObject.id)
        .select()
        .single()

      expect(updatedCostObject.actual_amount).toBe(65000)
    })
  })

  describe('Reporting and Analytics Workflow', () => {
    test('EVM calculations workflow', async () => {
      const supabase = createServerClient()

      // 1. Check EVM View
      const { data: evmData } = await supabase
        .from('evm_calculations')
        .select('*')
        .eq('project_id', testProject.id)
        .single()

      expect(evmData).toBeDefined()
      expect(evmData.project_name).toBe('Integration Test Project')
      expect(evmData.total_budget).toBe(2000000)

      // 2. Check CTC View
      const { data: ctcData } = await supabase
        .from('ctc_calculations')
        .select('*')
        .eq('project_id', testProject.id)
        .single()

      expect(ctcData).toBeDefined()
      expect(ctcData.total_budget).toBe(2000000)

      // 3. Check Margin Analysis
      const { data: marginData } = await supabase
        .from('margin_analysis')
        .select('*')
        .eq('project_id', testProject.id)
        .single()

      expect(marginData).toBeDefined()
      expect(marginData.contract_value).toBe(2000000)
    })
  })

  describe('Approval Workflows', () => {
    test('Timesheet approval workflow', async () => {
      const supabase = createServerClient()

      // 1. Employee submits timesheet
      const { data: timesheet } = await supabase
        .from('timesheets')
        .insert({
          user_id: 'employee-user-id',
          project_id: testProject.id,
          week_ending_date: '2024-02-11',
          status: 'draft',
          total_hours: 40
        })
        .select()
        .single()

      expect(timesheet.status).toBe('draft')

      // 2. Employee submits for approval
      const { data: submittedTimesheet } = await supabase
        .from('timesheets')
        .update({
          status: 'submitted',
          submitted_date: new Date().toISOString()
        })
        .eq('id', timesheet.id)
        .select()
        .single()

      expect(submittedTimesheet.status).toBe('submitted')

      // 3. Manager approves
      const { data: approvedTimesheet } = await supabase
        .from('timesheets')
        .update({
          status: 'approved',
          approved_by: 'manager-user-id',
          approved_date: new Date().toISOString()
        })
        .eq('id', timesheet.id)
        .select()
        .single()

      expect(approvedTimesheet.status).toBe('approved')
      expect(approvedTimesheet.approved_by).toBe('manager-user-id')
    })

    test('Purchase order approval workflow', async () => {
      // 1. Create PO in draft
      const po = await repositories.procurement.createPurchaseOrder({
        project_id: testProject.id,
        po_number: 'PO-APPROVAL-001',
        vendor_id: testVendor.id,
        po_type: 'standard',
        issue_date: '2024-02-15',
        delivery_date: '2024-03-01',
        total_amount: 75000,
        created_by: 'procurement-user-id',
        lines: [{
          line_number: 1,
          description: 'Cement bags',
          quantity: 500,
          unit: 'bags',
          unit_rate: 150
        }]
      })

      expect(po.status).toBe('draft')

      // 2. Submit for approval
      const submittedPO = await repositories.procurement.submitForApproval(po.id)
      expect(submittedPO.status).toBe('pending_approval')

      // 3. Approve PO
      const approvedPO = await repositories.procurement.approvePurchaseOrder(po.id, 'manager-user-id')
      expect(approvedPO.status).toBe('approved')
      expect(approvedPO.approved_by).toBe('manager-user-id')
    })
  })

  afterAll(async () => {
    // Cleanup test data
    const supabase = createServerClient()
    await supabase.from('projects').delete().eq('id', testProject.id)
  })
})
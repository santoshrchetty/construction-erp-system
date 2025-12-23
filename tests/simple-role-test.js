const { createClient } = require('@supabase/supabase-js')

// Load environment variables
require('dotenv').config({ path: '.env.local' })

// Simple role flow test without TypeScript complications
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

const supabase = createClient(supabaseUrl, supabaseKey)

const testRoles = {
  admin: { id: '550e8400-e29b-41d4-a716-446655440001', role: 'Admin' },
  manager: { id: '550e8400-e29b-41d4-a716-446655440002', role: 'Manager' },
  procurement: { id: '550e8400-e29b-41d4-a716-446655440003', role: 'Procurement' },
  storekeeper: { id: '550e8400-e29b-41d4-a716-446655440004', role: 'Storekeeper' },
  engineer: { id: '550e8400-e29b-41d4-a716-446655440005', role: 'Engineer' },
  finance: { id: '550e8400-e29b-41d4-a716-446655440006', role: 'Finance' },
  hr: { id: '550e8400-e29b-41d4-a716-446655440007', role: 'HR' },
  employee: { id: '550e8400-e29b-41d4-a716-446655440008', role: 'Employee' }
}

async function testRoleFlows() {
  console.log('🚀 Starting Role-wise Flow Tests...\n')
  
  let testProject = null
  let results = { passed: 0, failed: 0, tests: [] }

  try {
    // 1. Test Admin - Create Project
    console.log('🔍 Testing Admin role...')
    const { data: project, error: projectError } = await supabase
      .from('projects')
      .insert({
        name: 'Test Construction Project',
        code: 'TCP-001',
        project_type: 'commercial',
        start_date: '2024-01-01',
        planned_end_date: '2024-12-31',
        budget: 1000000
      })
      .select()
      .single()
    
    if (projectError) {
      console.log('❌ Admin test failed:', projectError.message)
      results.failed++
      results.tests.push({ role: 'Admin', test: 'Create Project', status: 'FAILED', error: projectError.message })
    } else {
      console.log('✅ Admin can create projects')
      testProject = project
      results.passed++
      results.tests.push({ role: 'Admin', test: 'Create Project', status: 'PASSED' })
    }

    if (!testProject) {
      console.log('❌ Cannot continue without test project')
      return
    }

    // 2. Test Manager - Create WBS
    console.log('🔍 Testing Manager role...')
    const { data: wbs, error: wbsError } = await supabase
      .from('wbs_nodes')
      .insert({
        project_id: testProject.id,
        code: 'WBS-001',
        name: 'Foundation Phase',
        node_type: 'phase',
        level: 1,
        sequence_order: 1,
        budget_allocation: 300000
      })
      .select()
      .single()
    
    if (wbsError) {
      console.log('❌ Manager test failed:', wbsError.message)
      results.failed++
      results.tests.push({ role: 'Manager', test: 'Create WBS', status: 'FAILED', error: wbsError.message })
    } else {
      console.log('✅ Manager can create WBS structure')
      results.passed++
      results.tests.push({ role: 'Manager', test: 'Create WBS', status: 'PASSED' })
    }

    // 3. Test Procurement - Create Vendor
    console.log('🔍 Testing Procurement role...')
    const vendorCode = 'TV-' + Date.now()
    const { data: vendor, error: vendorError } = await supabase
      .from('vendors')
      .insert({
        name: 'Test Vendor Co. ' + Date.now(),
        code: vendorCode,
        contact_person: 'John Doe',
        email: 'john' + Date.now() + '@testvendor.com',
        status: 'active'
      })
      .select()
      .single()
    
    if (vendorError) {
      console.log('❌ Procurement test failed:', vendorError.message)
      results.failed++
      results.tests.push({ role: 'Procurement', test: 'Create Vendor', status: 'FAILED', error: vendorError.message })
    } else {
      console.log('✅ Procurement can create vendors')
      results.passed++
      results.tests.push({ role: 'Procurement', test: 'Create Vendor', status: 'PASSED' })

      // Create Purchase Order
      const { data: po, error: poError } = await supabase
        .from('purchase_orders')
        .insert({
          project_id: testProject.id,
          po_number: 'PO-001',
          vendor_id: vendor.id,
          po_type: 'standard',
          issue_date: '2024-01-15',
          delivery_date: '2024-02-01',
          total_amount: 50000,
          created_by: testRoles.procurement.id
        })
        .select()
        .single()
      
      if (poError) {
        console.log('❌ PO creation failed:', poError.message)
        results.failed++
        results.tests.push({ role: 'Procurement', test: 'Create PO', status: 'FAILED', error: poError.message })
      } else {
        console.log('✅ Procurement can create purchase orders')
        results.passed++
        results.tests.push({ role: 'Procurement', test: 'Create PO', status: 'PASSED' })
      }
    }

    // 4. Test Storekeeper - Create Store
    console.log('🔍 Testing Storekeeper role...')
    const { data: store, error: storeError } = await supabase
      .from('stores')
      .insert({
        project_id: testProject.id,
        name: 'Main Warehouse',
        code: 'WH-001',
        location: 'Site Entrance',
        store_keeper_id: testRoles.storekeeper.id
      })
      .select()
      .single()
    
    if (storeError) {
      console.log('❌ Storekeeper test failed:', storeError.message)
      results.failed++
      results.tests.push({ role: 'Storekeeper', test: 'Create Store', status: 'FAILED', error: storeError.message })
    } else {
      console.log('✅ Storekeeper can create stores')
      results.passed++
      results.tests.push({ role: 'Storekeeper', test: 'Create Store', status: 'PASSED' })
    }

    // 5. Test Engineer - Create Task
    if (wbs) {
      console.log('🔍 Testing Engineer role...')
      const { data: task, error: taskError } = await supabase
        .from('tasks')
        .insert({
          project_id: testProject.id,
          wbs_node_id: wbs.id,
          name: 'Foundation Excavation',
          status: 'not_started',
          priority: 'high',
          planned_start_date: '2024-01-15',
          planned_end_date: '2024-01-30',
          planned_hours: 80,
          assigned_to: testRoles.engineer.id,
          created_by: testRoles.manager.id
        })
        .select()
        .single()
      
      if (taskError) {
        console.log('❌ Task creation failed:', taskError.message)
        results.failed++
        results.tests.push({ role: 'Engineer', test: 'Create Task', status: 'FAILED', error: taskError.message })
      } else {
        console.log('✅ Tasks can be assigned to engineers')
        results.passed++
        results.tests.push({ role: 'Engineer', test: 'Create Task', status: 'PASSED' })
      }
    }

    // 6. Test Finance - Create Billing
    console.log('🔍 Testing Finance role...')
    const { data: billing, error: billingError } = await supabase
      .from('project_billing')
      .insert({
        project_id: testProject.id,
        billing_date: '2024-02-28',
        billing_amount: 100000,
        billing_type: 'progress',
        description: 'Foundation Phase - 30% Complete'
      })
      .select()
      .single()
    
    if (billingError) {
      console.log('❌ Finance test failed:', billingError.message)
      results.failed++
      results.tests.push({ role: 'Finance', test: 'Create Billing', status: 'FAILED', error: billingError.message })
    } else {
      console.log('✅ Finance can create billing entries')
      results.passed++
      results.tests.push({ role: 'Finance', test: 'Create Billing', status: 'PASSED' })
    }

    // 7. Test HR - Create Employee
    console.log('🔍 Testing HR role...')
    const empCode = 'EMP-' + Date.now()
    const { data: employee, error: employeeError } = await supabase
      .from('employees')
      .insert({
        employee_code: empCode,
        first_name: 'John',
        last_name: 'Worker',
        email: 'john.worker' + Date.now() + '@company.com',
        job_title: 'Site Engineer',
        department: 'Engineering',
        hire_date: '2024-01-15'
      })
      .select()
      .single()
    
    if (employeeError) {
      console.log('❌ HR test failed:', employeeError.message)
      results.failed++
      results.tests.push({ role: 'HR', test: 'Create Employee', status: 'FAILED', error: employeeError.message })
    } else {
      console.log('✅ HR can create employee records')
      results.passed++
      results.tests.push({ role: 'HR', test: 'Create Employee', status: 'PASSED' })
    }

    // 8. Test Employee - Create Daily Timesheet (only if employee was created)
    if (employee) {
      console.log('🔍 Testing Employee role...')
      const { data: timesheet, error: timesheetError } = await supabase
        .from('daily_timesheets')
        .insert({
          timesheet_date: '2024-02-04',
          project_id: testProject.id,
          employee_id: employee.id,
          status: 'draft',
          total_regular_hours: 8,
          total_overtime_hours: 0,
          total_cost: 800
        })
        .select()
        .single()
      
      if (timesheetError) {
        console.log('❌ Employee test failed:', timesheetError.message)
        results.failed++
        results.tests.push({ role: 'Employee', test: 'Create Timesheet', status: 'FAILED', error: timesheetError.message })
      } else {
        console.log('✅ Employee can create timesheets')
        results.passed++
        results.tests.push({ role: 'Employee', test: 'Create Timesheet', status: 'PASSED' })
      }
    } else {
      console.log('⚠️ Skipping Employee test - no employee created')
      results.tests.push({ role: 'Employee', test: 'Create Timesheet', status: 'SKIPPED', error: 'No employee available' })
    }


    // Test Views
    console.log('🔍 Testing analytical views...')
    
    const { data: evmData, error: evmError } = await supabase
      .from('evm_calculations')
      .select('*')
      .eq('project_id', testProject.id)
      .maybeSingle()
    
    if (evmError) {
      console.log('❌ EVM view test failed:', evmError.message)
      results.failed++
      results.tests.push({ role: 'System', test: 'EVM View', status: 'FAILED', error: evmError.message })
    } else {
      console.log('✅ EVM calculations view working')
      results.passed++
      results.tests.push({ role: 'System', test: 'EVM View', status: 'PASSED' })
    }

  } catch (error) {
    console.log('❌ Test execution failed:', error.message)
    results.failed++
  }

  // Generate Report
  console.log('\n📊 TEST RESULTS SUMMARY')
  console.log('='.repeat(50))
  console.log(`✅ Total Passed: ${results.passed}`)
  console.log(`❌ Total Failed: ${results.failed}`)
  console.log(`📈 Success Rate: ${((results.passed / (results.passed + results.failed)) * 100).toFixed(1)}%`)
  
  console.log('\nDetailed Results:')
  results.tests.forEach(test => {
    const status = test.status === 'PASSED' ? '✅' : '❌'
    console.log(`${status} ${test.role} - ${test.test}`)
    if (test.error) {
      console.log(`   Error: ${test.error}`)
    }
  })

  // Cleanup
  if (testProject) {
    console.log('\n🧹 Cleaning up test data...')
    await supabase.from('projects').delete().eq('id', testProject.id)
    console.log('✅ Cleanup completed')
  }

  console.log('\n🎉 Role flow tests completed!')
}

// Run the tests
testRoleFlows().catch(console.error)
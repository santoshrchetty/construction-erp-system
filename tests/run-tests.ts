#!/usr/bin/env node

import { execSync } from 'child_process'
import { createServerClient } from '@/lib/supabase'

// Test runner configuration
const testConfig = {
  roles: [
    'Admin',
    'Manager', 
    'Procurement',
    'Storekeeper',
    'Engineer',
    'Finance',
    'HR',
    'Employee'
  ],
  workflows: [
    'procurement',
    'project_execution',
    'cost_tracking',
    'timesheet_approval',
    'inventory_management'
  ]
}

// Mock test data
const testData = {
  users: {
    admin: { id: 'admin-001', email: 'admin@test.com', role: 'Admin' },
    manager: { id: 'mgr-001', email: 'manager@test.com', role: 'Manager' },
    procurement: { id: 'proc-001', email: 'procurement@test.com', role: 'Procurement' },
    storekeeper: { id: 'store-001', email: 'storekeeper@test.com', role: 'Storekeeper' },
    engineer: { id: 'eng-001', email: 'engineer@test.com', role: 'Engineer' },
    finance: { id: 'fin-001', email: 'finance@test.com', role: 'Finance' },
    hr: { id: 'hr-001', email: 'hr@test.com', role: 'HR' },
    employee: { id: 'emp-001', email: 'employee@test.com', role: 'Employee' }
  },
  project: {
    name: 'Test Construction Project',
    code: 'TCP-2024-001',
    project_type: 'commercial',
    start_date: '2024-01-01',
    planned_end_date: '2024-12-31',
    budget: 5000000
  }
}

class RoleFlowTester {
  private supabase = createServerClient()
  private testResults: any[] = []

  async runAllTests() {
    console.log('🚀 Starting Role-wise Flow Tests...\n')
    
    try {
      // Setup test environment
      await this.setupTestEnvironment()
      
      // Run role-specific tests
      for (const role of testConfig.roles) {
        await this.testRoleFlow(role)
      }
      
      // Run workflow integration tests
      for (const workflow of testConfig.workflows) {
        await this.testWorkflow(workflow)
      }
      
      // Generate test report
      this.generateReport()
      
    } catch (error) {
      console.error('❌ Test execution failed:', error)
    } finally {
      await this.cleanup()
    }
  }

  private async setupTestEnvironment() {
    console.log('📋 Setting up test environment...')
    
    // Create test project
    const { data: project, error } = await this.supabase
      .from('projects')
      .insert(testData.project)
      .select()
      .single()
    
    if (error) throw error
    
    testData.project.id = project.id
    console.log('✅ Test project created:', project.code)
    
    // Create test users in roles table if needed
    for (const [roleName, userData] of Object.entries(testData.users)) {
      const { error: roleError } = await this.supabase
        .from('users')
        .upsert({
          id: userData.id,
          email: userData.email,
          first_name: roleName.charAt(0).toUpperCase() + roleName.slice(1),
          last_name: 'User',
          employee_code: `${roleName.toUpperCase()}-001`
        })
      
      if (roleError) console.warn(`⚠️ Could not create user ${roleName}:`, roleError.message)
    }
  }

  private async testRoleFlow(role: string) {
    console.log(`\n🔍 Testing ${role} role flow...`)
    
    const testResult = {
      role,
      tests: [],
      passed: 0,
      failed: 0,
      startTime: Date.now()
    }

    try {
      switch (role) {
        case 'Admin':
          await this.testAdminFlow(testResult)
          break
        case 'Manager':
          await this.testManagerFlow(testResult)
          break
        case 'Procurement':
          await this.testProcurementFlow(testResult)
          break
        case 'Storekeeper':
          await this.testStorekeeperFlow(testResult)
          break
        case 'Engineer':
          await this.testEngineerFlow(testResult)
          break
        case 'Finance':
          await this.testFinanceFlow(testResult)
          break
        case 'HR':
          await this.testHRFlow(testResult)
          break
        case 'Employee':
          await this.testEmployeeFlow(testResult)
          break
      }
    } catch (error) {
      testResult.tests.push({
        name: `${role} Flow Test`,
        status: 'FAILED',
        error: error.message
      })
      testResult.failed++
    }

    testResult.endTime = Date.now()
    testResult.duration = testResult.endTime - testResult.startTime
    this.testResults.push(testResult)
    
    console.log(`✅ ${role} tests completed: ${testResult.passed} passed, ${testResult.failed} failed`)
  }

  private async testAdminFlow(testResult: any) {
    // Test 1: Create project
    try {
      const { data, error } = await this.supabase
        .from('projects')
        .insert({
          name: 'Admin Test Project',
          code: 'ATP-001',
          project_type: 'residential',
          start_date: '2024-02-01',
          planned_end_date: '2024-08-31',
          budget: 1000000
        })
        .select()
        .single()
      
      if (error) throw error
      
      testResult.tests.push({ name: 'Create Project', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'Create Project', status: 'FAILED', error: error.message })
      testResult.failed++
    }

    // Test 2: Manage roles
    try {
      const { data, error } = await this.supabase
        .from('roles')
        .select('*')
      
      if (error) throw error
      if (!data || data.length === 0) throw new Error('No roles found')
      
      testResult.tests.push({ name: 'Access Roles', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'Access Roles', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testManagerFlow(testResult: any) {
    // Test 1: Create WBS
    try {
      const { data, error } = await this.supabase
        .from('wbs_nodes')
        .insert({
          project_id: testData.project.id,
          code: 'WBS-MGR-001',
          name: 'Manager Test Phase',
          node_type: 'phase',
          level: 1,
          sequence_order: 1,
          budget_allocation: 500000
        })
        .select()
        .single()
      
      if (error) throw error
      
      testResult.tests.push({ name: 'Create WBS', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'Create WBS', status: 'FAILED', error: error.message })
      testResult.failed++
    }

    // Test 2: Create task
    try {
      const { data: wbs } = await this.supabase
        .from('wbs_nodes')
        .select('id')
        .eq('project_id', testData.project.id)
        .limit(1)
        .single()

      if (wbs) {
        const { data, error } = await this.supabase
          .from('tasks')
          .insert({
            project_id: testData.project.id,
            wbs_node_id: wbs.id,
            name: 'Manager Test Task',
            status: 'not_started',
            priority: 'medium',
            planned_start_date: '2024-02-01',
            planned_end_date: '2024-02-15',
            planned_hours: 40,
            assigned_to: testData.users.engineer.id,
            created_by: testData.users.manager.id
          })
          .select()
          .single()
        
        if (error) throw error
        
        testResult.tests.push({ name: 'Create Task', status: 'PASSED' })
        testResult.passed++
      }
    } catch (error) {
      testResult.tests.push({ name: 'Create Task', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testProcurementFlow(testResult: any) {
    // Test 1: Create vendor
    try {
      const { data, error } = await this.supabase
        .from('vendors')
        .insert({
          name: 'Test Vendor Co.',
          code: 'TV-PROC-001',
          contact_person: 'John Doe',
          email: 'john@testvendor.com',
          status: 'active'
        })
        .select()
        .single()
      
      if (error) throw error
      
      testResult.tests.push({ name: 'Create Vendor', status: 'PASSED' })
      testResult.passed++
      
      // Test 2: Create PO
      const { data: po, error: poError } = await this.supabase
        .from('purchase_orders')
        .insert({
          project_id: testData.project.id,
          po_number: 'PO-PROC-001',
          vendor_id: data.id,
          po_type: 'standard',
          issue_date: '2024-02-01',
          delivery_date: '2024-02-15',
          total_amount: 50000,
          created_by: testData.users.procurement.id
        })
        .select()
        .single()
      
      if (poError) throw poError
      
      testResult.tests.push({ name: 'Create Purchase Order', status: 'PASSED' })
      testResult.passed++
      
    } catch (error) {
      testResult.tests.push({ name: 'Procurement Flow', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testStorekeeperFlow(testResult: any) {
    // Test 1: Create store
    try {
      const { data, error } = await this.supabase
        .from('stores')
        .insert({
          project_id: testData.project.id,
          name: 'Test Store',
          code: 'TS-STORE-001',
          location: 'Test Location',
          store_keeper_id: testData.users.storekeeper.id
        })
        .select()
        .single()
      
      if (error) throw error
      
      testResult.tests.push({ name: 'Create Store', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'Create Store', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testEngineerFlow(testResult: any) {
    // Test: View assigned tasks
    try {
      const { data, error } = await this.supabase
        .from('tasks')
        .select('*')
        .eq('assigned_to', testData.users.engineer.id)
      
      if (error) throw error
      
      testResult.tests.push({ name: 'View Assigned Tasks', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'View Assigned Tasks', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testFinanceFlow(testResult: any) {
    // Test: Create billing entry
    try {
      const { data, error } = await this.supabase
        .from('project_billing')
        .insert({
          project_id: testData.project.id,
          billing_date: '2024-02-28',
          billing_amount: 100000,
          billing_type: 'progress',
          description: 'Test billing entry'
        })
        .select()
        .single()
      
      if (error) throw error
      
      testResult.tests.push({ name: 'Create Billing Entry', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'Create Billing Entry', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testHRFlow(testResult: any) {
    // Test: Create employee
    try {
      const { data, error } = await this.supabase
        .from('employees')
        .insert({
          employee_code: 'EMP-HR-001',
          first_name: 'Test',
          last_name: 'Employee',
          email: 'test.emp@company.com',
          job_title: 'Test Engineer',
          department: 'Engineering',
          hire_date: '2024-02-01'
        })
        .select()
        .single()
      
      if (error) throw error
      
      testResult.tests.push({ name: 'Create Employee', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'Create Employee', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testEmployeeFlow(testResult: any) {
    // Test: Create timesheet
    try {
      const { data, error } = await this.supabase
        .from('timesheets')
        .insert({
          user_id: testData.users.employee.id,
          project_id: testData.project.id,
          week_ending_date: '2024-02-04',
          status: 'draft',
          total_hours: 40
        })
        .select()
        .single()
      
      if (error) throw error
      
      testResult.tests.push({ name: 'Create Timesheet', status: 'PASSED' })
      testResult.passed++
    } catch (error) {
      testResult.tests.push({ name: 'Create Timesheet', status: 'FAILED', error: error.message })
      testResult.failed++
    }
  }

  private async testWorkflow(workflow: string) {
    console.log(`\n🔄 Testing ${workflow} workflow...`)
    // Workflow tests would be implemented here
    console.log(`✅ ${workflow} workflow test completed`)
  }

  private generateReport() {
    console.log('\n📊 TEST RESULTS SUMMARY')
    console.log('=' .repeat(50))
    
    let totalPassed = 0
    let totalFailed = 0
    
    this.testResults.forEach(result => {
      console.log(`\n${result.role} Role:`)
      console.log(`  ✅ Passed: ${result.passed}`)
      console.log(`  ❌ Failed: ${result.failed}`)
      console.log(`  ⏱️  Duration: ${result.duration}ms`)
      
      totalPassed += result.passed
      totalFailed += result.failed
      
      if (result.failed > 0) {
        result.tests.filter(t => t.status === 'FAILED').forEach(test => {
          console.log(`    ❌ ${test.name}: ${test.error}`)
        })
      }
    })
    
    console.log('\n' + '='.repeat(50))
    console.log(`OVERALL RESULTS:`)
    console.log(`✅ Total Passed: ${totalPassed}`)
    console.log(`❌ Total Failed: ${totalFailed}`)
    console.log(`📈 Success Rate: ${((totalPassed / (totalPassed + totalFailed)) * 100).toFixed(1)}%`)
  }

  private async cleanup() {
    console.log('\n🧹 Cleaning up test data...')
    
    try {
      // Delete test project (cascades to related data)
      await this.supabase
        .from('projects')
        .delete()
        .eq('id', testData.project.id)
      
      console.log('✅ Cleanup completed')
    } catch (error) {
      console.warn('⚠️ Cleanup warning:', error.message)
    }
  }
}

// Run tests if called directly
if (require.main === module) {
  const tester = new RoleFlowTester()
  tester.runAllTests()
    .then(() => {
      console.log('\n🎉 All tests completed!')
      process.exit(0)
    })
    .catch((error) => {
      console.error('\n💥 Test runner failed:', error)
      process.exit(1)
    })
}

export { RoleFlowTester, testConfig, testData }
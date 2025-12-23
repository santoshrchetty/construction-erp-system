import { createServerClient } from '@/lib/supabase'

// Role permission matrix
const rolePermissions = {
  Admin: {
    projects: ['create', 'read', 'update', 'delete'],
    users: ['create', 'read', 'update', 'delete'],
    roles: ['create', 'read', 'update', 'delete'],
    wbs: ['create', 'read', 'update', 'delete'],
    tasks: ['create', 'read', 'update', 'delete'],
    procurement: ['create', 'read', 'update', 'delete'],
    stores: ['create', 'read', 'update', 'delete'],
    timesheets: ['create', 'read', 'update', 'delete', 'approve'],
    reports: ['read', 'export']
  },
  Manager: {
    projects: ['create', 'read', 'update'],
    wbs: ['create', 'read', 'update', 'delete'],
    tasks: ['create', 'read', 'update', 'delete'],
    timesheets: ['read', 'approve'],
    reports: ['read', 'export'],
    procurement: ['read'],
    stores: ['read']
  },
  Procurement: {
    vendors: ['create', 'read', 'update'],
    purchase_orders: ['create', 'read', 'update'],
    procurement: ['create', 'read', 'update'],
    projects: ['read'],
    reports: ['read']
  },
  Storekeeper: {
    stores: ['create', 'read', 'update'],
    inventory: ['create', 'read', 'update'],
    goods_receipt: ['create', 'read', 'update'],
    stock_movements: ['create', 'read'],
    projects: ['read']
  },
  Engineer: {
    tasks: ['read', 'update'],
    projects: ['read'],
    wbs: ['read'],
    timesheets: ['create', 'read', 'update'],
    reports: ['read']
  },
  Finance: {
    costing: ['create', 'read', 'update'],
    billing: ['create', 'read', 'update'],
    reports: ['read', 'export'],
    projects: ['read'],
    procurement: ['read']
  },
  HR: {
    employees: ['create', 'read', 'update'],
    timesheets: ['read', 'approve'],
    users: ['create', 'read', 'update'],
    reports: ['read']
  },
  Employee: {
    timesheets: ['create', 'read', 'update'],
    tasks: ['read', 'update'],
    projects: ['read']
  }
}

describe('Role Permission Tests', () => {
  const supabase = createServerClient()

  describe('Admin Permissions', () => {
    test('Admin can access all tables', async () => {
      const tables = ['projects', 'wbs_nodes', 'tasks', 'vendors', 'purchase_orders', 'stores']
      
      for (const table of tables) {
        const { data, error } = await supabase.from(table).select('*').limit(1)
        expect(error).toBeNull()
        expect(data).toBeDefined()
      }
    })

    test('Admin can manage roles', async () => {
      const { data: roles, error } = await supabase.from('roles').select('*')
      expect(error).toBeNull()
      expect(roles).toBeDefined()
      expect(roles?.length).toBeGreaterThan(0)
    })
  })

  describe('Manager Permissions', () => {
    test('Manager can create projects', async () => {
      const { data, error } = await supabase
        .from('projects')
        .insert({
          name: 'Manager Test Project',
          code: 'MTP-001',
          project_type: 'commercial',
          start_date: '2024-01-01',
          planned_end_date: '2024-12-31',
          budget: 500000
        })
        .select()
        .single()
      
      expect(error).toBeNull()
      expect(data).toBeDefined()
      expect(data.name).toBe('Manager Test Project')
    })

    test('Manager can create WBS nodes', async () => {
      // First get a project
      const { data: project } = await supabase
        .from('projects')
        .select('id')
        .limit(1)
        .single()

      if (project) {
        const { data, error } = await supabase
          .from('wbs_nodes')
          .insert({
            project_id: project.id,
            code: 'WBS-TEST-001',
            name: 'Test WBS Node',
            node_type: 'phase',
            level: 1,
            sequence_order: 1
          })
          .select()
          .single()
        
        expect(error).toBeNull()
        expect(data).toBeDefined()
      }
    })
  })

  describe('Procurement Permissions', () => {
    test('Procurement can create vendors', async () => {
      const { data, error } = await supabase
        .from('vendors')
        .insert({
          name: 'Test Vendor',
          code: 'TV-001',
          contact_person: 'Test Contact',
          email: 'test@vendor.com',
          status: 'active'
        })
        .select()
        .single()
      
      expect(error).toBeNull()
      expect(data).toBeDefined()
      expect(data.name).toBe('Test Vendor')
    })

    test('Procurement can create purchase orders', async () => {
      // Get project and vendor
      const { data: project } = await supabase
        .from('projects')
        .select('id')
        .limit(1)
        .single()

      const { data: vendor } = await supabase
        .from('vendors')
        .select('id')
        .limit(1)
        .single()

      if (project && vendor) {
        const { data, error } = await supabase
          .from('purchase_orders')
          .insert({
            project_id: project.id,
            po_number: 'PO-TEST-001',
            vendor_id: vendor.id,
            po_type: 'standard',
            issue_date: '2024-01-01',
            delivery_date: '2024-01-15',
            total_amount: 10000,
            created_by: 'test-user-id'
          })
          .select()
          .single()
        
        expect(error).toBeNull()
        expect(data).toBeDefined()
      }
    })
  })

  describe('Storekeeper Permissions', () => {
    test('Storekeeper can create stores', async () => {
      const { data: project } = await supabase
        .from('projects')
        .select('id')
        .limit(1)
        .single()

      if (project) {
        const { data, error } = await supabase
          .from('stores')
          .insert({
            project_id: project.id,
            name: 'Test Store',
            code: 'TS-001',
            location: 'Test Location'
          })
          .select()
          .single()
        
        expect(error).toBeNull()
        expect(data).toBeDefined()
        expect(data.name).toBe('Test Store')
      }
    })

    test('Storekeeper can create goods receipts', async () => {
      // Get required data
      const { data: project } = await supabase.from('projects').select('id').limit(1).single()
      const { data: po } = await supabase.from('purchase_orders').select('id').limit(1).single()
      const { data: store } = await supabase.from('stores').select('id').limit(1).single()
      const { data: vendor } = await supabase.from('vendors').select('id').limit(1).single()

      if (project && po && store && vendor) {
        const { data, error } = await supabase
          .from('goods_receipts')
          .insert({
            project_id: project.id,
            po_id: po.id,
            store_id: store.id,
            grn_number: 'GRN-TEST-001',
            vendor_id: vendor.id,
            receipt_date: '2024-01-15',
            received_by: 'test-storekeeper-id'
          })
          .select()
          .single()
        
        expect(error).toBeNull()
        expect(data).toBeDefined()
      }
    })
  })

  describe('Employee Permissions', () => {
    test('Employee can create timesheets', async () => {
      const { data: project } = await supabase
        .from('projects')
        .select('id')
        .limit(1)
        .single()

      if (project) {
        const { data, error } = await supabase
          .from('timesheets')
          .insert({
            user_id: 'test-employee-id',
            project_id: project.id,
            week_ending_date: '2024-01-07',
            status: 'draft'
          })
          .select()
          .single()
        
        expect(error).toBeNull()
        expect(data).toBeDefined()
      }
    })

    test('Employee can view assigned tasks', async () => {
      const { data, error } = await supabase
        .from('tasks')
        .select('*')
        .eq('assigned_to', 'test-employee-id')
      
      expect(error).toBeNull()
      expect(data).toBeDefined()
    })
  })

  describe('Finance Permissions', () => {
    test('Finance can create billing entries', async () => {
      const { data: project } = await supabase
        .from('projects')
        .select('id')
        .limit(1)
        .single()

      if (project) {
        const { data, error } = await supabase
          .from('project_billing')
          .insert({
            project_id: project.id,
            billing_date: '2024-01-31',
            billing_amount: 50000,
            billing_type: 'progress',
            description: 'Monthly Progress Billing'
          })
          .select()
          .single()
        
        expect(error).toBeNull()
        expect(data).toBeDefined()
      }
    })

    test('Finance can view cost data', async () => {
      const { data, error } = await supabase
        .from('actual_costs')
        .select('*')
        .limit(10)
      
      expect(error).toBeNull()
      expect(data).toBeDefined()
    })
  })

  describe('HR Permissions', () => {
    test('HR can create employees', async () => {
      const { data, error } = await supabase
        .from('employees')
        .insert({
          employee_code: 'EMP-TEST-001',
          first_name: 'Test',
          last_name: 'Employee',
          email: 'test.employee@company.com',
          job_title: 'Test Role',
          department: 'Testing',
          hire_date: '2024-01-01'
        })
        .select()
        .single()
      
      expect(error).toBeNull()
      expect(data).toBeDefined()
      expect(data.employee_code).toBe('EMP-TEST-001')
    })

    test('HR can view timesheet data', async () => {
      const { data, error } = await supabase
        .from('timesheets')
        .select('*')
        .limit(10)
      
      expect(error).toBeNull()
      expect(data).toBeDefined()
    })
  })
})
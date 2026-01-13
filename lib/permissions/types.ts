// Permission system types and enums
export enum UserRole {
  ADMIN = 'Admin',
  MANAGER = 'Manager',
  PROCUREMENT = 'Procurement',
  STOREKEEPER = 'Storekeeper',
  ENGINEER = 'Engineer',
  FINANCE = 'Finance',
  HR = 'HR',
  EMPLOYEE = 'Employee'
}

export enum Module {
  PROJECTS = 'projects',
  WBS = 'wbs',
  BOQ = 'boq',
  TASKS = 'tasks',
  TIMESHEETS = 'timesheets',
  PROCUREMENT = 'procurement',
  PURCHASE_ORDERS = 'purchase_orders',
  GOODS_RECEIPTS = 'goods_receipts',
  STORES = 'stores',
  COSTING = 'costing',
  CTC = 'ctc',
  PROGRESS = 'progress',
  REPORTING = 'reporting',
  VENDORS = 'vendors',
  EMPLOYEES = 'employees',
  USERS = 'users'
}

export enum Permission {
  CREATE = 'create',
  EDIT = 'edit',
  DELETE = 'delete',
  VIEW = 'view',
  APPROVE = 'approve',
  SUBMIT = 'submit'
}

export type PermissionMatrix = {
  [key in UserRole]: {
    [key in Module]?: Permission[]
  }
}

export interface PermissionCheck {
  role: UserRole
  module: Module
  permission: Permission
  userId?: string
  resourceId?: string
}
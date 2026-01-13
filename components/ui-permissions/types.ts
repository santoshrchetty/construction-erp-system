export enum UserRole {
  ADMIN = 'admin',
  PROJECT_MANAGER = 'project_manager',
  SITE_ENGINEER = 'site_engineer',
  STOREKEEPER = 'storekeeper',
  EMPLOYEE = 'employee'
}

export enum Module {
  PROJECTS = 'projects',
  TASKS = 'tasks',
  INVENTORY = 'inventory',
  FINANCE = 'finance',
  REPORTS = 'reports',
  USERS = 'users'
}

export enum Permission {
  READ = 'read',
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  APPROVE = 'approve'
}
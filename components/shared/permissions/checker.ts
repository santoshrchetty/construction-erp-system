import { UserRole, Module, Permission } from './types'

class PermissionChecker {
  private permissions: Record<UserRole, Record<Module, Permission[]>> = {
    [UserRole.ADMIN]: {
      [Module.PROJECTS]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.DELETE, Permission.APPROVE],
      [Module.TASKS]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.DELETE, Permission.APPROVE],
      [Module.INVENTORY]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.DELETE, Permission.APPROVE],
      [Module.FINANCE]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.DELETE, Permission.APPROVE],
      [Module.REPORTS]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.DELETE],
      [Module.USERS]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.DELETE]
    },
    [UserRole.PROJECT_MANAGER]: {
      [Module.PROJECTS]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.APPROVE],
      [Module.TASKS]: [Permission.READ, Permission.CREATE, Permission.UPDATE, Permission.DELETE],
      [Module.INVENTORY]: [Permission.READ, Permission.UPDATE],
      [Module.FINANCE]: [Permission.READ, Permission.UPDATE],
      [Module.REPORTS]: [Permission.READ, Permission.CREATE],
      [Module.USERS]: [Permission.READ]
    },
    [UserRole.SITE_ENGINEER]: {
      [Module.PROJECTS]: [Permission.READ, Permission.UPDATE],
      [Module.TASKS]: [Permission.READ, Permission.CREATE, Permission.UPDATE],
      [Module.INVENTORY]: [Permission.READ, Permission.UPDATE],
      [Module.FINANCE]: [Permission.READ],
      [Module.REPORTS]: [Permission.READ, Permission.CREATE],
      [Module.USERS]: [Permission.READ]
    },
    [UserRole.STOREKEEPER]: {
      [Module.PROJECTS]: [Permission.READ],
      [Module.TASKS]: [Permission.READ],
      [Module.INVENTORY]: [Permission.READ, Permission.CREATE, Permission.UPDATE],
      [Module.FINANCE]: [Permission.READ],
      [Module.REPORTS]: [Permission.READ],
      [Module.USERS]: [Permission.READ]
    },
    [UserRole.EMPLOYEE]: {
      [Module.PROJECTS]: [Permission.READ],
      [Module.TASKS]: [Permission.READ, Permission.UPDATE],
      [Module.INVENTORY]: [Permission.READ],
      [Module.FINANCE]: [],
      [Module.REPORTS]: [Permission.READ],
      [Module.USERS]: [Permission.READ]
    }
  }

  hasPermission(userRole: UserRole, module: Module, permission: Permission): boolean {
    const rolePermissions = this.permissions[userRole]
    if (!rolePermissions) return false
    
    const modulePermissions = rolePermissions[module]
    if (!modulePermissions) return false
    
    return modulePermissions.includes(permission)
  }

  getPermissions(userRole: UserRole, module: Module): Permission[] {
    const rolePermissions = this.permissions[userRole]
    if (!rolePermissions) return []
    
    return rolePermissions[module] || []
  }
}

export const permissionChecker = new PermissionChecker()
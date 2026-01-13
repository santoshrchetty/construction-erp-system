import { UserRole, Module, Permission, PermissionCheck } from './types'
import { PERMISSION_MATRIX } from './matrix'

export class PermissionChecker {
  private static instance: PermissionChecker
  private permissionMatrix = PERMISSION_MATRIX

  static getInstance(): PermissionChecker {
    if (!PermissionChecker.instance) {
      PermissionChecker.instance = new PermissionChecker()
    }
    return PermissionChecker.instance
  }

  hasPermission(role: UserRole, module: Module, permission: Permission): boolean {
    const rolePermissions = this.permissionMatrix[role]
    const modulePermissions = rolePermissions?.[module]
    return modulePermissions?.includes(permission) ?? false
  }

  canView(role: UserRole, module: Module): boolean {
    return this.hasPermission(role, module, Permission.VIEW)
  }

  canCreate(role: UserRole, module: Module): boolean {
    return this.hasPermission(role, module, Permission.CREATE)
  }

  canEdit(role: UserRole, module: Module): boolean {
    return this.hasPermission(role, module, Permission.EDIT)
  }

  canDelete(role: UserRole, module: Module): boolean {
    return this.hasPermission(role, module, Permission.DELETE)
  }

  canApprove(role: UserRole, module: Module): boolean {
    return this.hasPermission(role, module, Permission.APPROVE)
  }

  canSubmit(role: UserRole, module: Module): boolean {
    return this.hasPermission(role, module, Permission.SUBMIT)
  }

  getAccessibleModules(role: UserRole): Module[] {
    const rolePermissions = this.permissionMatrix[role]
    return Object.keys(rolePermissions || {}) as Module[]
  }

  getModulePermissions(role: UserRole, module: Module): Permission[] {
    return this.permissionMatrix[role]?.[module] || []
  }

  checkMultiplePermissions(
    role: UserRole, 
    checks: Array<{ module: Module; permission: Permission }>,
    requireAll: boolean = true
  ): boolean {
    if (requireAll) {
      return checks.every(check => this.hasPermission(role, check.module, check.permission))
    }
    return checks.some(check => this.hasPermission(role, check.module, check.permission))
  }
}

export const permissionChecker = PermissionChecker.getInstance()
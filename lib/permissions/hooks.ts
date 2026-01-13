import { useMemo } from 'react'
import { UserRole, Module, Permission } from './types'
import { permissionChecker } from './checker'
import { useAuth } from '@/lib/contexts/AuthContext'

export function usePermissions({ userRole, module }: { userRole?: UserRole; module: Module }) {
  const { profile } = useAuth()
  const role = userRole || (profile?.roles?.name as UserRole) || UserRole.EMPLOYEE

  return useMemo(() => ({
    canView: permissionChecker.canView(role, module),
    canCreate: permissionChecker.canCreate(role, module),
    canEdit: permissionChecker.canEdit(role, module),
    canDelete: permissionChecker.canDelete(role, module),
    canApprove: permissionChecker.canApprove(role, module),
    canSubmit: permissionChecker.canSubmit(role, module),
    permissions: permissionChecker.getModulePermissions(role, module)
  }), [role, module])
}

export function useModulePermissions(module: Module) {
  const { profile } = useAuth()
  const role = (profile?.roles?.name as UserRole) || UserRole.EMPLOYEE

  return useMemo(() => 
    permissionChecker.getModulePermissions(role, module), 
    [role, module]
  )
}

export function usePermission(module: Module, permission: Permission) {
  const { profile } = useAuth()
  const role = (profile?.roles?.name as UserRole) || UserRole.EMPLOYEE

  return useMemo(() => 
    permissionChecker.hasPermission(role, module, permission), 
    [role, module, permission]
  )
}

export function useAccessibleModules() {
  const { profile } = useAuth()
  const role = (profile?.roles?.name as UserRole) || UserRole.EMPLOYEE

  return useMemo(() => 
    permissionChecker.getAccessibleModules(role), 
    [role]
  )
}

export function useMultiplePermissions(
  checks: Array<{ module: Module; permission: Permission }>,
  requireAll: boolean = true
) {
  const { profile } = useAuth()
  const role = (profile?.roles?.name as UserRole) || UserRole.EMPLOYEE

  return useMemo(() => 
    permissionChecker.checkMultiplePermissions(role, checks, requireAll), 
    [role, checks, requireAll]
  )
}
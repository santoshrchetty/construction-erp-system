'use client'
import React, { createContext, useContext, ReactNode } from 'react'
import { UserRole, Module, Permission } from './types'
import { permissionChecker } from './checker'
import { useAuth } from '@/lib/contexts/AuthContext'

interface PermissionContextType {
  userRole: UserRole
  userId: string | null
  checkPermission: (module: Module, permission: Permission) => boolean
  hasAnyPermission: (module: Module, permissions: Permission[]) => boolean
}

const PermissionContext = createContext<PermissionContextType | null>(null)

export function PermissionProvider({ children }: { children: ReactNode }) {
  const { user, profile } = useAuth()
  const userRole = (profile?.roles?.name as UserRole) || UserRole.EMPLOYEE
  const userId = user?.id || null

  const checkPermission = (module: Module, permission: Permission): boolean => {
    return permissionChecker.hasPermission(userRole, module, permission)
  }

  const hasAnyPermission = (module: Module, permissions: Permission[]): boolean => {
    return permissions.some(permission => checkPermission(module, permission))
  }

  return (
    <PermissionContext.Provider value={{
      userRole,
      userId,
      checkPermission,
      hasAnyPermission
    }}>
      {children}
    </PermissionContext.Provider>
  )
}

export function usePermissionContext() {
  const context = useContext(PermissionContext)
  if (!context) {
    throw new Error('usePermissionContext must be used within PermissionProvider')
  }
  return context
}
'use client'
import { ReactNode } from 'react'
import { Module, Permission } from '@/lib/permissions/types'
import { usePermissionContext } from './PermissionContext'

interface PermissionGuardProps {
  module: Module
  permission: Permission
  children: ReactNode
  fallback?: ReactNode
}

export function PermissionGuard({ module, permission, children, fallback = null }: PermissionGuardProps) {
  const { checkPermission } = usePermissionContext()
  
  if (!checkPermission(module, permission)) {
    return <>{fallback}</>
  }
  
  return <>{children}</>
}

interface MultiPermissionGuardProps {
  checks: Array<{ module: Module; permission: Permission }>
  logic?: 'AND' | 'OR'
  children: ReactNode
  fallback?: ReactNode
}

export function MultiPermissionGuard({ 
  checks, 
  logic = 'AND', 
  children, 
  fallback = null 
}: MultiPermissionGuardProps) {
  const { checkPermission } = usePermissionContext()
  
  const hasPermission = logic === 'AND' 
    ? checks.every(({ module, permission }) => checkPermission(module, permission))
    : checks.some(({ module, permission }) => checkPermission(module, permission))
  
  if (!hasPermission) {
    return <>{fallback}</>
  }
  
  return <>{children}</>
}
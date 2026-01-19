'use client'

import { ReactNode } from 'react'

interface PermissionGuardProps {
  children: ReactNode
  module?: any
  permission?: any
  fallback?: ReactNode
}

export function PermissionGuard({ children }: PermissionGuardProps) {
  return <>{children}</>
}

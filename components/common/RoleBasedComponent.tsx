'use client'

import { useAuth } from '@/lib/contexts/AuthContext'

interface RoleBasedComponentProps {
  children: React.ReactNode
  allowedRoles?: string[]
  requiredPermission?: { resource: string; action: string }
  fallback?: React.ReactNode
}

export default function RoleBasedComponent({ 
  children, 
  allowedRoles, 
  requiredPermission,
  fallback = null
}: RoleBasedComponentProps) {
  const { getUserRole, hasPermission } = useAuth()

  const userRole = getUserRole()

  // Check role-based access
  if (allowedRoles && !allowedRoles.includes(userRole)) {
    return <>{fallback}</>
  }

  // Check permission-based access
  if (requiredPermission && !hasPermission(requiredPermission.resource, requiredPermission.action)) {
    return <>{fallback}</>
  }

  return <>{children}</>
}
'use client'

import { useAuth } from '@/lib/contexts/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

interface ProtectedRouteProps {
  children: React.ReactNode
  allowedRoles?: string[]
  requiredPermission?: { resource: string; action: string }
}

export default function ProtectedRoute({ 
  children, 
  allowedRoles,
  requiredPermission 
}: ProtectedRouteProps) {
  const { user, profile, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    // Wait for both user and profile to load
    if (!loading) {
      // Not authenticated
      if (!user) {
        router.push('/login')
        return
      }

      // User exists but profile not loaded or no role
      if (!profile || !profile.roles?.name) {
        router.push('/unauthorized')
        return
      }

      // Check role requirements
      if (allowedRoles && allowedRoles.length > 0) {
        const userRole = profile.roles?.name
        if (!userRole || !allowedRoles.includes(userRole)) {
          router.push('/unauthorized')
          return
        }
      }

      // Check permission requirements
      if (requiredPermission) {
        // Stub permission check - implement proper permission system
        const hasPermissionCheck = true // TODO: Implement proper permission checking
        if (!hasPermissionCheck) {
          router.push('/unauthorized')
          return
        }
      }
    }
  }, [user, profile, loading, allowedRoles, requiredPermission, router])

  // Show loading spinner while waiting for auth/profile
  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    )
  }

  // Don't render if not authenticated
  if (!user) {
    return null
  }

  // Don't render if profile not loaded or no role
  if (!profile || !profile.roles?.name) {
    return null
  }

  // Don't render if role requirements not met
  if (allowedRoles && allowedRoles.length > 0) {
    const userRole = profile.roles?.name
    if (!userRole || !allowedRoles.includes(userRole)) {
      return null
    }
  }

  // Don't render if permission requirements not met
  if (requiredPermission) {
    if (!hasPermission(requiredPermission.resource, requiredPermission.action)) {
      return null
    }
  }

  return <>{children}</>
}
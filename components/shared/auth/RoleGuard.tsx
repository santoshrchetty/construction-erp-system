'use client'

import { useAuth } from '@/lib/contexts/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

interface RoleGuardProps {
  allowedRoles: string[]
  children: React.ReactNode
  fallbackRoute?: string
}

export default function RoleGuard({ 
  allowedRoles, 
  children, 
  fallbackRoute = '/dashboard' 
}: RoleGuardProps) {
  const { user, profile, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!loading && user && profile) {
      const userRole = profile.roles?.name || 'Employee'
      
      if (!allowedRoles.includes(userRole)) {
        router.push(fallbackRoute)
      }
    }
  }, [loading, user, profile, allowedRoles, fallbackRoute, router])

  if (loading) {
    return <div className="flex items-center justify-center min-h-screen">Loading...</div>
  }

  if (!user) {
    return null
  }

  const userRole = profile?.roles?.name || 'Employee'
  
  if (!allowedRoles.includes(userRole)) {
    return null
  }

  return <>{children}</>
}
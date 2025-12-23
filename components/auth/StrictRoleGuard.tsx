'use client'

import { useAuth } from '@/lib/contexts/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

interface StrictRoleGuardProps {
  allowedRoles: string[]
  children: React.ReactNode
}

export default function StrictRoleGuard({ allowedRoles, children }: StrictRoleGuardProps) {
  const { user, profile, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!loading) {
      if (!user) {
        router.push('/login')
        return
      }

      if (!profile?.roles?.name) {
        router.push('/login')
        return
      }

      const userRole = profile.roles.name
      
      if (!allowedRoles.includes(userRole)) {
        // Strict validation - no fallback, redirect to login
        router.push('/login')
        return
      }
    }
  }, [loading, user, profile, allowedRoles, router])

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!user || !profile?.roles?.name || !allowedRoles.includes(profile.roles.name)) {
    return null
  }

  return <>{children}</>
}
'use client'

import { ReactNode } from 'react'

interface ProtectedRouteProps {
  children: ReactNode
  allowedRoles?: string[]
}

export default function ProtectedRoute({ children }: ProtectedRouteProps) {
  return <>{children}</>
}

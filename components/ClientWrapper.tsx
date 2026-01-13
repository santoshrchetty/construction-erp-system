'use client'

import { AuthProvider } from '@/lib/contexts/AuthContext'
import { ReactNode } from 'react'

interface ClientWrapperProps {
  children: ReactNode
}

export default function ClientWrapper({ children }: ClientWrapperProps) {
  return (
    <AuthProvider>
      {children}
    </AuthProvider>
  )
}
'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/lib/contexts/AuthContext'

export function usePermissions() {
  const { user } = useAuth()
  const [loading, setLoading] = useState(false)

  const checkPermission = async (authObject: string, action: string, context: any = {}) => {
    if (!user) return false

    try {
      setLoading(true)
      const response = await fetch('/api/permissions/check', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ authObject, action, context })
      })

      const data = await response.json()
      return data.hasPermission || false
    } catch (error) {
      console.error('Permission check failed:', error)
      return false
    } finally {
      setLoading(false)
    }
  }

  return { checkPermission, loading }
}
'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'

interface Tenant {
  id: string
  name: string
  code: string
}

interface TenantSelectionProps {
  userId: string
  onTenantSelected: (tenantId: string) => void
}

export default function TenantSelection({ userId, onTenantSelected }: TenantSelectionProps) {
  const [tenants, setTenants] = useState<Tenant[]>([])
  const [loading, setLoading] = useState(true)
  const [selecting, setSelecting] = useState(false)

  useEffect(() => {
    fetchUserTenants()
  }, [userId])

  const fetchUserTenants = async () => {
    try {
      const { data, error } = await supabase
        .from('user_tenants')
        .select(`
          tenant_id,
          tenants!inner (
            id,
            name,
            code
          )
        `)
        .eq('user_id', userId)
        .eq('is_active', true)

      if (error) {
        console.error('Supabase error:', error)
        throw error
      }

      if (!data || data.length === 0) {
        console.log('No tenant data found for user:', userId)
        setTenants([])
        return
      }

      const userTenants = data.map(ut => ut.tenants).filter(Boolean)
      setTenants(userTenants)
    } catch (error) {
      console.error('Error fetching tenants:', error)
      // Show more detailed error information
      if (error?.message) {
        console.error('Error message:', error.message)
      }
      if (error?.details) {
        console.error('Error details:', error.details)
      }
    } finally {
      setLoading(false)
    }
  }

  const handleTenantSelect = async (tenantId: string) => {
    setSelecting(true)
    try {
      // Store selected tenant in session/localStorage
      localStorage.setItem('selectedTenant', tenantId)
      onTenantSelected(tenantId)
    } catch (error) {
      console.error('Error selecting tenant:', error)
    } finally {
      setSelecting(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-[#F7F7F7] via-white to-[#F0F8FF] flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#F7F7F7] via-white to-[#F0F8FF] flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-[0_8px_32px_rgba(0,0,0,0.12)] p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-light text-[#32363A] mb-3">Select Tenant</h1>
          <p className="text-[#6A6D70] font-light">Choose your organization to continue</p>
        </div>

        <div className="space-y-3">
          {tenants.map((tenant) => (
            <button
              key={tenant.id}
              onClick={() => handleTenantSelect(tenant.id)}
              disabled={selecting}
              className="w-full p-4 text-left border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors disabled:opacity-50"
            >
              <div className="font-medium text-[#32363A]">{tenant.name}</div>
              <div className="text-sm text-[#6A6D70]">{tenant.code}</div>
            </button>
          ))}
        </div>

        {tenants.length === 0 && (
          <div className="text-center py-8">
            <p className="text-[#6A6D70]">No tenants available. Contact your administrator.</p>
          </div>
        )}
      </div>
    </div>
  )
}
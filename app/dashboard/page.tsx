'use client'
import { IndustrialDashboard } from '@/components/ui-permissions/IndustrialDashboard'
import { PermissionProvider } from '@/components/ui-permissions/PermissionContext'

export default function DashboardPage() {
  return (
    <PermissionProvider>
      <IndustrialDashboard />
    </PermissionProvider>
  )
}
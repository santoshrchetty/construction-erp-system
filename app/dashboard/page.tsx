'use client'
import { IndustrialDashboard } from '@/components/layout/dashboards/IndustrialDashboard'
import { PermissionProvider } from '@/components/shared/permissions/PermissionContext'

export default function DashboardPage() {
  return (
    <PermissionProvider>
      <IndustrialDashboard />
    </PermissionProvider>
  )
}
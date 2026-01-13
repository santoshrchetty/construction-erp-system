'use client'
import { IndustrialDashboard } from '@/components/ui-permissions/IndustrialDashboard'
import { PermissionGuard } from '@/components/ui-permissions/PermissionGuard'
import { Module, Permission } from '@/lib/permissions/types'

export default function AdminPage() {
  return (
    <PermissionGuard 
      module={Module.USERS} 
      permission={Permission.VIEW}
      fallback={<div className="p-8 text-center">Access Denied</div>}
    >
      <IndustrialDashboard />
    </PermissionGuard>
  )
}
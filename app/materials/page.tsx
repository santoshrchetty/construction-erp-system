'use client'
import { MaterialRequestList } from '@/components/features/materials/MaterialRequestList'
import { PermissionGuard } from '@/components/ui-permissions/PermissionGuard'
import { Module, Permission } from '@/lib/permissions/types'

export default function MaterialsPage() {
  return (
    <PermissionGuard 
      module={Module.MATERIALS} 
      permission={Permission.VIEW}
      fallback={<div className="p-8 text-center">Access Denied</div>}
    >
      <MaterialRequestList />
    </PermissionGuard>
  )
}
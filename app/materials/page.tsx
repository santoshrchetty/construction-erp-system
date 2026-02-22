'use client'
import MaterialRequestFormV2 from '@/components/features/materials/MaterialRequestFormV2'
import { PermissionGuard } from '@/components/ui-permissions/PermissionGuard'
import { Module, Permission } from '@/lib/permissions/types'

export default function MaterialsPage() {
  return (
    <PermissionGuard 
      module={Module.MATERIALS} 
      permission={Permission.VIEW}
      fallback={<div className="p-8 text-center">Access Denied</div>}
    >
      <MaterialRequestFormV2 />
    </PermissionGuard>
  )
}
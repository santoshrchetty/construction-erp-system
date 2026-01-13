'use client'
import { ButtonHTMLAttributes, InputHTMLAttributes, FormHTMLAttributes } from 'react'
import { Module, Permission } from '@/lib/permissions/types'
import { usePermissionContext } from './PermissionContext'

interface PermissionButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  module: Module
  permission: Permission
  hideWhenDisabled?: boolean
}

export function PermissionButton({ 
  module, 
  permission, 
  hideWhenDisabled = false,
  children,
  className = '',
  ...props 
}: PermissionButtonProps) {
  const { checkPermission } = usePermissionContext()
  const hasPermission = checkPermission(module, permission)
  
  if (!hasPermission && hideWhenDisabled) {
    return null
  }
  
  return (
    <button
      {...props}
      disabled={!hasPermission || props.disabled}
      className={`${className} ${!hasPermission ? 'opacity-50 cursor-not-allowed' : ''}`}
    >
      {children}
    </button>
  )
}

interface PermissionInputProps extends InputHTMLAttributes<HTMLInputElement> {
  module: Module
  permission: Permission
}

export function PermissionInput({ 
  module, 
  permission, 
  className = '',
  ...props 
}: PermissionInputProps) {
  const { checkPermission } = usePermissionContext()
  const hasPermission = checkPermission(module, permission)
  
  return (
    <input
      {...props}
      disabled={!hasPermission || props.disabled}
      className={`${className} ${!hasPermission ? 'opacity-50 cursor-not-allowed' : ''}`}
    />
  )
}

interface TableActionsProps {
  module: Module
  onEdit?: () => void
  onDelete?: () => void
  onView?: () => void
}

export function TableActions({ module, onEdit, onDelete, onView }: TableActionsProps) {
  const { checkPermission } = usePermissionContext()
  
  return (
    <div className="flex space-x-2">
      {onView && checkPermission(module, Permission.VIEW) && (
        <button
          onClick={onView}
          className="text-blue-600 hover:text-blue-800 text-sm"
        >
          View
        </button>
      )}
      {onEdit && checkPermission(module, Permission.EDIT) && (
        <button
          onClick={onEdit}
          className="text-green-600 hover:text-green-800 text-sm"
        >
          Edit
        </button>
      )}
      {onDelete && checkPermission(module, Permission.DELETE) && (
        <button
          onClick={onDelete}
          className="text-red-600 hover:text-red-800 text-sm"
        >
          Delete
        </button>
      )}
    </div>
  )
}
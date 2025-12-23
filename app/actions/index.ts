// Export all server actions
export * from './projects/actions'
export * from './wbs/actions'
export * from './tasks/actions'
export * from './boq/actions'
export * from './procurement/actions'
export * from './stores/actions'
export * from './timesheets/actions'

// Common action result type
export interface ActionResult<T = any> {
  success: boolean
  data?: T
  error?: string
}

// Error handling utility
export function handleActionError(error: unknown): ActionResult {
  console.error('Action error:', error)
  
  if (error instanceof Error) {
    return { success: false, error: error.message }
  }
  
  return { success: false, error: 'An unexpected error occurred' }
}
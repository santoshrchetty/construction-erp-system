// Error Recovery Middleware
import { NextRequest, NextResponse } from 'next/server'
import { restoreManager } from '@/lib/restorePoint'

interface ErrorRecoveryOptions {
  autoBackup?: boolean
  criticalFiles?: string[]
  rollbackOnError?: boolean
}

export function withErrorRecovery(
  handler: (req: NextRequest) => Promise<NextResponse>,
  options: ErrorRecoveryOptions = {}
) {
  return async (req: NextRequest): Promise<NextResponse> => {
    let restorePointId: string | null = null
    
    try {
      // Auto-backup before risky operations
      if (options.autoBackup) {
        restorePointId = restoreManager.autoBackup()
        console.log(`🔄 Auto-backup created: ${restorePointId}`)
      }
      
      // Execute the handler
      const response = await handler(req)
      
      // Mark restore point as successful if operation completed
      if (restorePointId && response.ok) {
        console.log(`✅ Operation successful, restore point ${restorePointId} available`)
      }
      
      return response
      
    } catch (error) {
      console.error('❌ Error occurred:', error)
      
      // Auto-rollback if enabled
      if (options.rollbackOnError && restorePointId) {
        console.log(`🔄 Auto-rolling back to: ${restorePointId}`)
        const rollbackSuccess = restoreManager.restoreFromPoint(restorePointId)
        
        if (rollbackSuccess) {
          console.log('✅ Rollback completed')
        } else {
          console.log('❌ Rollback failed')
        }
      }
      
      return NextResponse.json({
        error: 'Operation failed',
        details: error instanceof Error ? error.message : 'Unknown error',
        restorePointId: restorePointId,
        rollbackAvailable: !!restorePointId
      }, { status: 500 })
    }
  }
}

// Pre-configured middleware for different risk levels
export const withLowRiskRecovery = (handler: (req: NextRequest) => Promise<NextResponse>) =>
  withErrorRecovery(handler, { autoBackup: false })

export const withMediumRiskRecovery = (handler: (req: NextRequest) => Promise<NextResponse>) =>
  withErrorRecovery(handler, { autoBackup: true })

export const withHighRiskRecovery = (handler: (req: NextRequest) => Promise<NextResponse>) =>
  withErrorRecovery(handler, { autoBackup: true, rollbackOnError: true })

// Usage examples:
// export const GET = withMediumRiskRecovery(async (req) => { ... })
// export const POST = withHighRiskRecovery(async (req) => { ... })
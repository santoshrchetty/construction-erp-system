import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'
import { dataIntegrityService } from '@/lib/services/dataIntegrityService'

export async function GET(request: NextRequest) {
  try {
    await withAuth(request)
    
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'check'
    
    switch (action) {
      case 'check':
        const report = await dataIntegrityService.generateIntegrityReport()
        return NextResponse.json({
          success: true,
          data: report
        })
      
      case 'validate':
        const issues = await dataIntegrityService.validateDataIntegrity()
        return NextResponse.json({
          success: true,
          data: { issues }
        })
      
      default:
        return NextResponse.json({
          success: false,
          error: 'Invalid action'
        }, { status: 400 })
    }
  } catch (error) {
    return NextResponse.json({
      success: false,
      error: 'Data integrity check failed'
    }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    await withAuth(request)
    
    const { action } = await request.json()
    
    if (action === 'fix_orphaned_plants') {
      const result = await dataIntegrityService.fixOrphanedPlants()
      return NextResponse.json({
        success: true,
        data: result
      })
    }
    
    return NextResponse.json({
      success: false,
      error: 'Invalid action'
    }, { status: 400 })
  } catch (error) {
    return NextResponse.json({
      success: false,
      error: 'Data integrity fix failed'
    }, { status: 500 })
  }
}
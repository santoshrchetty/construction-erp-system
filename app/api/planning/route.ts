import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'

async function handlePlanning(action: string, request: NextRequest) {
  const authContext = await withAuth(request, Module.PROJECTS, Permission.VIEW)
  
  switch (action) {
    case 'mrp_shortage':
      return { shortages: [], message: 'MRP shortage monitoring' }
    case 'material_forecast':
      return { forecast: [], message: 'Material forecast data' }
    case 'demand_forecast':
      return { demand: [], message: 'AI demand forecasting' }
    default:
      return { action, message: `${action} functionality available` }
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'default'
    
    const result = await handlePlanning(action, request)
    
    return NextResponse.json({
      success: true,
      category: 'planning',
      action,
      data: result
    })
  } catch (error) {
    if (error instanceof Error && (error.message === 'Unauthorized' || error.message === 'Forbidden')) {
      return NextResponse.json({ error: error.message }, { status: error.message === 'Unauthorized' ? 401 : 403 })
    }
    
    return NextResponse.json({
      error: 'Planning operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
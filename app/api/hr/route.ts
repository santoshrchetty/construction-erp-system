import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'
import * as hrServices from '@/domains/hr/hrServices'

async function handleHR(action: string, request: NextRequest, method: string = 'GET') {
  const authContext = await withAuth(request)
  
  switch (action) {
    case 'timesheets':
      return await hrServices.getTimesheetApprovals(authContext.user.id)
    case 'employees':
      return await hrServices.getEmployeeList()
    case 'leave_requests':
      return await hrServices.getLeaveRequests()
    default:
      return { action, message: `${action} functionality available` }
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'default'
    
    const result = await handleHR(action, request, 'GET')
    
    return NextResponse.json({
      success: true,
      category: 'hr',
      action,
      data: result
    })
  } catch (error) {
    if (error instanceof Error && (error.message === 'Unauthorized' || error.message === 'Forbidden')) {
      return NextResponse.json({ error: error.message }, { status: error.message === 'Unauthorized' ? 401 : 403 })
    }
    
    return NextResponse.json({
      error: 'HR operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'default'
    
    const result = await handleHR(action, request, 'POST')
    
    return NextResponse.json({
      success: true,
      category: 'hr',
      action,
      data: result
    })
  } catch (error) {
    if (error instanceof Error && (error.message === 'Unauthorized' || error.message === 'Forbidden')) {
      return NextResponse.json({ error: error.message }, { status: error.message === 'Unauthorized' ? 401 : 403 })
    }
    
    return NextResponse.json({
      error: 'HR operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
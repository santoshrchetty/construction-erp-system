import { NextRequest, NextResponse } from 'next/server'
import { FlexibleApprovalService } from '@/domains/approval/FlexibleApprovalService'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const objectType = searchParams.get('objectType')
    
    const workflows = await FlexibleApprovalService.getWorkflowDefinitions(objectType || undefined)
    return NextResponse.json(workflows)
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch workflows' }, { status: 500 })
  }
}

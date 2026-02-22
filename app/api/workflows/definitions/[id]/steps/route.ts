import { NextRequest, NextResponse } from 'next/server'
import { FlexibleApprovalService } from '@/domains/approval/FlexibleApprovalService'

export async function GET(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await context.params
    const steps = await FlexibleApprovalService.getWorkflowSteps(id)
    return NextResponse.json(steps)
  } catch (error) {
    console.error('Get workflow steps error:', error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to fetch steps' },
      { status: 500 }
    )
  }
}

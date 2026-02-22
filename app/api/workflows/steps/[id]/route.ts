import { NextRequest, NextResponse } from 'next/server'
import { WorkflowAdminService } from '@/domains/workflow/workflowAdminService'

export async function PUT(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await context.params
    const body = await request.json()
    const step = await WorkflowAdminService.updateWorkflowStep(id, body)
    return NextResponse.json(step)
  } catch (error) {
    console.error('Update step error:', error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to update step' },
      { status: 500 }
    )
  }
}

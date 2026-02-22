import { NextRequest, NextResponse } from 'next/server'
import { WorkflowAdminService } from '@/domains/workflow/workflowAdminService'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const step = await WorkflowAdminService.createWorkflowStep(body)
    return NextResponse.json(step)
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to create step' },
      { status: 500 }
    )
  }
}

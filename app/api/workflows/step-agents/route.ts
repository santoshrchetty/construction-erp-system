import { NextRequest, NextResponse } from 'next/server'
import { WorkflowAdminService } from '@/domains/workflow/workflowAdminService'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const agent = await WorkflowAdminService.addStepAgent(body)
    return NextResponse.json(agent)
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to add agent' },
      { status: 500 }
    )
  }
}

import { NextRequest, NextResponse } from 'next/server'
import { FlexibleApprovalService } from '@/domains/approval/FlexibleApprovalService'

export async function POST(request: NextRequest) {
  try {
    const { workflow_instance_id } = await request.json()
    
    // Call the private advanceWorkflow method via reflection
    const result = await (FlexibleApprovalService as any).advanceWorkflow(workflow_instance_id)
    
    return NextResponse.json({ success: true, message: 'Workflow advanced' })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}

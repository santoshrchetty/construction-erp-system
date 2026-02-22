import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/authMiddleware'
import { FlexibleApprovalService } from '@/domains/approval/FlexibleApprovalService'

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const body = await request.json()
    
    const result = await FlexibleApprovalService.createWorkflowInstance({
      object_type: body.object_type,
      object_id: body.object_id,
      requester_id: context.user.id,
      context_data: body.context_data
    })
    
    if (!result.success) {
      return NextResponse.json({ success: false, error: result.message }, { status: 500 })
    }

    return NextResponse.json({ success: true, data: result.instance })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MAT_REQ_WRITE'])

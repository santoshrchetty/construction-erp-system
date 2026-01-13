import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { ApprovalService } from '@/domains/approval/ApprovalService'
import { FlexibleApprovalService } from '@/domains/approval/FlexibleApprovalService'

const DEFAULT_CUSTOMER_ID = '550e8400-e29b-41d4-a716-446655440001'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action')
    const objectType = searchParams.get('object_type')
    const workflowId = searchParams.get('workflow_id')
    const agentId = searchParams.get('agent_id')

    switch (action) {
      case 'field-definitions':
        const fieldDefs = await ApprovalService.getFieldDefinitions(DEFAULT_CUSTOMER_ID)
        return NextResponse.json(fieldDefs)

      case 'document-types':
        const docTypes = await ApprovalService.getDocumentTypes(DEFAULT_CUSTOMER_ID)
        return NextResponse.json(docTypes)

      case 'approvers':
        const approvers = await ApprovalService.getApprovers({})
        return NextResponse.json(approvers)

      case 'workflow-definitions':
        const workflows = await FlexibleApprovalService.getWorkflowDefinitions(objectType || undefined)
        return NextResponse.json({ success: true, data: workflows })

      case 'workflow-steps':
        if (!workflowId) return NextResponse.json({ error: 'Workflow ID required' }, { status: 400 })
        const steps = await FlexibleApprovalService.getWorkflowSteps(workflowId)
        return NextResponse.json({ success: true, data: steps })

      case 'active-workflows':
        const filters = objectType ? { object_type: objectType } : undefined
        const activeWorkflows = await FlexibleApprovalService.getActiveWorkflows(filters)
        return NextResponse.json({ success: true, data: activeWorkflows })

      case 'pending-approvals':
        if (!agentId) return NextResponse.json({ error: 'Agent ID required' }, { status: 400 })
        const pending = await FlexibleApprovalService.getPendingApprovals(agentId)
        return NextResponse.json({ success: true, data: pending })

      default:
        return NextResponse.json({ error: 'Invalid action parameter' }, { status: 400 })
    }
  } catch (error) {
    console.error('Approvals API error:', error)
    return NextResponse.json({ error: 'Failed to fetch data' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { action, ...data } = body

    switch (action) {
      case 'create-workflow-instance':
        const result = await FlexibleApprovalService.createWorkflowInstance(data)
        return NextResponse.json(result)

      case 'process-approval':
        const { stepInstanceId, approvalAction, comments } = data
        const processResult = await FlexibleApprovalService.processApproval(
          stepInstanceId,
          approvalAction,
          comments
        )
        return NextResponse.json(processResult)

      case 'create-policy':
        const policyResult = await ApprovalService.createPolicy(data)
        return NextResponse.json(policyResult)

      default:
        return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
    }
  } catch (error) {
    console.error('Approval creation error:', error)
    return NextResponse.json({ error: 'Failed to process request' }, { status: 500 })
  }
}
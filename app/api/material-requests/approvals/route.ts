import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { FlexibleApprovalService } from '@/domains/approval/FlexibleApprovalService'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { action, payload } = body

    switch (action) {
      case 'submit_for_approval':
        return await submitForApproval(payload)
      
      case 'get_pending_approvals':
        return await getPendingApprovals(payload)
      
      case 'process_approval':
        return await processApproval(payload)
      
      default:
        return NextResponse.json({ success: false, error: 'Invalid action' }, { status: 400 })
    }
  } catch (error) {
    console.error('Material Request Approval API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}

async function submitForApproval(payload: any) {
  const { request_id, requester_id } = payload

  const { data: mr, error: mrError } = await supabase
    .from('material_requests')
    .select('*')
    .eq('id', request_id)
    .single()

  if (mrError || !mr) {
    return NextResponse.json({ success: false, error: 'Material request not found' }, { status: 404 })
  }

  const result = await FlexibleApprovalService.createWorkflowInstance({
    object_type: 'MATERIAL_REQUEST',
    object_id: request_id,
    requester_id: requester_id || mr.created_by,
    context_data: {
      request_number: mr.request_number,
      request_type: mr.request_type,
      company_code: mr.company_code,
      plant_code: mr.plant_code,
      project_code: mr.project_code,
      total_amount: mr.total_amount || 0
    }
  })

  if (result.success) {
    await supabase
      .from('material_requests')
      .update({ status: 'IN_APPROVAL' })
      .eq('id', request_id)
  }

  return NextResponse.json(result)
}

async function getPendingApprovals(payload: any) {
  const { agent_id } = payload

  if (!agent_id) {
    return NextResponse.json({ success: false, error: 'Agent ID required' }, { status: 400 })
  }

  const approvals = await FlexibleApprovalService.getPendingApprovals(agent_id)

  const enrichedApprovals = await Promise.all(
    approvals.map(async (approval: any) => {
      const { data: mr } = await supabase
        .from('material_requests')
        .select(`
          *,
          material_request_items(
            id,
            line_number,
            material_code,
            material_name,
            description,
            requested_quantity,
            base_uom,
            estimated_price,
            currency_code
          )
        `)
        .eq('id', approval.workflow_instances.object_id)
        .single()

      return {
        ...approval,
        material_request: mr
      }
    })
  )

  return NextResponse.json({ success: true, data: enrichedApprovals })
}

async function processApproval(payload: any) {
  const { step_instance_id, action, comments, request_id } = payload

  const result = await FlexibleApprovalService.processApproval(
    step_instance_id,
    action,
    comments
  )

  if (result.success) {
    const { data: instance } = await supabase
      .from('workflow_instances')
      .select('status')
      .eq('object_id', request_id)
      .single()

    if (instance?.status === 'COMPLETED') {
      await supabase
        .from('material_requests')
        .update({ status: 'APPROVED' })
        .eq('id', request_id)
    } else if (action === 'REJECT') {
      await supabase
        .from('material_requests')
        .update({ status: 'REJECTED' })
        .eq('id', request_id)
    }
  }

  return NextResponse.json(result)
}

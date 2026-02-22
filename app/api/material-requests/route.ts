import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/authMiddleware'
import { materialRequestService } from '@/domains/materials/materialRequestService'

export const GET = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    
    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ success: false, error: 'Tenant ID required' }, { status: 400 })
    }
    
    if (id) {
      const result = await materialRequestService.getMaterialRequestById(id, tenantId)
      if (!result.success) {
        return NextResponse.json({ success: false, error: result.error }, { status: 500 })
      }
      return NextResponse.json({ success: true, data: result.data })
    }
    
    // Get all requests for user with filters
    const filters = {
      request_type: searchParams.get('request_type') || undefined,
      status: searchParams.get('status') || undefined,
      requested_by: context.user.id,
      company_code: searchParams.get('company_code') || undefined,
      date_from: searchParams.get('date_from') || undefined,
      date_to: searchParams.get('date_to') || undefined,
      tenant_id: tenantId
    }
    
    const result = await materialRequestService.getMaterialRequests(filters)
    if (!result.success) {
      return NextResponse.json({ success: false, error: result.error }, { status: 500 })
    }
    
    return NextResponse.json({ success: true, data: result.data })
    
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MAT_REQ_READ'])

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const body = await request.json()
    
    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ success: false, error: 'Tenant ID required' }, { status: 400 })
    }
    
    const result = await materialRequestService.createMaterialRequest(body, context.user.id, tenantId)
    
    if (!result.success) {
      return NextResponse.json({ success: false, error: result.error }, { status: 500 })
    }

    return NextResponse.json({ success: true, data: result.data })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MAT_REQ_WRITE'])

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    const body = await request.json()
    
    if (!id) {
      return NextResponse.json({ success: false, error: 'Request ID required' }, { status: 400 })
    }

    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ success: false, error: 'Tenant ID required' }, { status: 400 })
    }

    // For status updates - now handled by materialRequestService
    if (body.status) {
      const result = await materialRequestService.updateMaterialRequestStatus(
        id, 
        body.status, 
        context.user.id, 
        body.comments,
        tenantId
      )
      
      if (!result.success) {
        return NextResponse.json({ success: false, error: result.error }, { status: 500 })
      }
      
      return NextResponse.json({ success: true })
    }

    // For other updates, we'd need to add an update method to the service
    return NextResponse.json({ success: false, error: 'Update method not implemented' }, { status: 400 })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MAT_REQ_WRITE'])
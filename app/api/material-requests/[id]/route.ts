import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/authMiddleware'
import { materialRequestService } from '@/domains/materials/materialRequestService'

export const PUT = withAuth(async (request: NextRequest, context) => {
  try {
    const url = new URL(request.url)
    const id = url.pathname.split('/').pop()
    const body = await request.json()
    
    if (!id) {
      return NextResponse.json({ success: false, error: 'Request ID required' }, { status: 400 })
    }
    
    const tenantId = context.tenantId
    if (!tenantId) {
      return NextResponse.json({ success: false, error: 'Tenant ID required' }, { status: 400 })
    }

    // Full update with items
    const result = await materialRequestService.updateMaterialRequest(id, body, context.user.id, tenantId)
    
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

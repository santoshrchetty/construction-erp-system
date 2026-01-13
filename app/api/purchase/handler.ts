import { NextRequest } from 'next/server'
import * as poServices from '@/domains/purchase-orders/poServices-compatible'

export async function handlePurchaseOrders(action: string, request: NextRequest, method: string = 'GET') {
  try {
    const body = method === 'POST' || method === 'PUT' ? await request.json() : {}
    const { searchParams } = new URL(request.url)
    
    switch (action) {
      case 'list':
        return await poServices.purchaseOrderService.getAllPOs()

      case 'create':
        if (method !== 'POST') throw new Error('POST method required for create')
        return await poServices.purchaseOrderService.createPO(body)

      case 'items':
        const poId = searchParams.get('poId') || body.poId
        if (!poId) throw new Error('PO ID required')
        return await poServices.purchaseOrderService.getPOItems(parseInt(poId))

      case 'add-item':
        if (method !== 'POST') throw new Error('POST method required for add-item')
        return await poServices.purchaseOrderService.addPOItem(body)

      case 'vendors':
        return await poServices.purchaseOrderService.getVendors()

      case 'materials':
        return await poServices.purchaseOrderService.getMaterials()

      case 'projects':
        return await poServices.purchaseOrderService.getProjects()

      case 'approve':
        if (method !== 'POST') throw new Error('POST method required for approve')
        const { poNumber, approverId, comments } = body
        return await poServices.purchaseOrderService.approvePO(poNumber, approverId, comments)

      case 'reject':
        if (method !== 'POST') throw new Error('POST method required for reject')
        const { poNumber: rejectPoNumber, approverId: rejectApproverId, comments: rejectComments } = body
        return await poServices.purchaseOrderService.rejectPO(rejectPoNumber, rejectApproverId, rejectComments)

      case 'pending-approvals':
        const approverId = searchParams.get('approverId')
        if (!approverId) throw new Error('Approver ID required')
        return await poServices.purchaseOrderService.getPendingApprovals(approverId)

      default:
        return { action, message: `${action} functionality available` }
    }
  } catch (error) {
    console.error('PO handler error:', error)
    throw error
  }
}
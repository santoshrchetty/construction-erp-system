import { NextRequest } from 'next/server'
import { CostCenterService } from '@/domains/cost-centers/costCenterServices'

const costCenterService = new CostCenterService()

export async function handleCostCenters(action: string, request: NextRequest, method: string = 'GET') {
  try {
    if (method === 'GET') {
      const { searchParams } = new URL(request.url)
      const companyCode = searchParams.get('companyCode')
      
      const data = await costCenterService.getCostCentersByCompany(companyCode || undefined)
      return { success: true, data }
    }

    return { success: false, error: 'Method not supported' }
  } catch (error) {
    console.error('Cost centers handler error:', error)
    throw error
  }
}
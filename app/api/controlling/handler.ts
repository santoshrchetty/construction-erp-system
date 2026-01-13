import { NextRequest } from 'next/server'

export async function handleControlling(action: string, request: NextRequest, method: string = 'GET') {
  switch (action) {
    case 'cost-center-overview':
      return { costCenters: [] }
    case 'project-cost-analysis':
      return { costAnalysis: [] }
    case 'budget-monitoring':
      return { budgetData: [] }
    default:
      return { action, message: `${action} functionality available` }
  }
}
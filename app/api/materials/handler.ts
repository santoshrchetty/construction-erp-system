import { NextRequest } from 'next/server'

export async function handleMaterials(action: string, request: NextRequest, method: string = 'GET') {
  switch (action) {
    case 'create-material':
      return { success: true, data: {} }
    case 'stock-overview':
      return { stock: [] }
    case 'bulk-upload':
      return { success: true, processed: 0 }
    case 'material-master':
      return { materials: [] }
    case 'search-materials':
      return { results: [] }
    default:
      return { action, message: `${action} functionality available` }
  }
}
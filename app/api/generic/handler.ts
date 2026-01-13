import { NextRequest } from 'next/server'

export async function handleGeneric(category: string, action: string, request: NextRequest, method: string = 'GET') {
  // Mock response for generic handler
  return {
    category,
    action,
    message: `${category}/${action} functionality available`,
    data: []
  }
}
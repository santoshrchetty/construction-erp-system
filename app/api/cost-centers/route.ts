import { NextRequest, NextResponse } from 'next/server'
import { handleCostCenters } from './handler'

export async function GET(request: NextRequest) {
  try {
    const result = await handleCostCenters('get', request, 'GET')
    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}
import { NextRequest, NextResponse } from 'next/server'
import { handleFinance } from './handler'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'default'
    
    const result = await handleFinance(action, request, 'GET')
    
    return NextResponse.json({
      success: true,
      category: 'finance',
      action,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Finance operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'default'
    const body = await request.json()
    
    // Handle Finance Engine Events
    if (action === 'finance_event' || body.action === 'finance_event') {
      const { processFinanceEvent } = await import('./finance-engine')
      return await processFinanceEvent(request)
    }
    
    const result = await handleFinance(action, request, 'POST')
    
    return NextResponse.json({
      success: true,
      category: 'finance',
      action,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Finance operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
// Finance Engine API - Test endpoint for modern event-based finance engine
import { NextRequest, NextResponse } from 'next/server'
import { ModernFinanceEngine } from '@/domains/finance/ModernFinanceEngine'

export async function processFinanceEvent(request: NextRequest) {
  try {
    const event = await request.json()
    const financeEngine = new ModernFinanceEngine()
    
    const result = await financeEngine.processFinanceEvent(event, 'system-user')
    
    return NextResponse.json({
      success: true,
      message: `Posted ${result.journalEntries} journal entries`,
      eventId: event.eventId,
      data: result
    })
  } catch (error) {
    console.error('Finance Engine Error:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
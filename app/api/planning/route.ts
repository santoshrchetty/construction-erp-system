import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const projectId = url.searchParams.get('projectId')
    const dateFrom = url.searchParams.get('dateFrom') || new Date().toISOString().split('T')[0]
    const dateTo = url.searchParams.get('dateTo') || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    const limit = parseInt(url.searchParams.get('limit') || '50')

    if (!projectId) {
      return NextResponse.json({ error: 'projectId is required' }, { status: 400 })
    }

    // Use service layer
    const { resourcePlanningService } = await import('@/lib/services/resourcePlanning.service')
    const activities = await resourcePlanningService.getActivitiesForResourcePlanning({
      projectId,
      dateFrom,
      dateTo,
      limit
    })

    return NextResponse.json({ activities })
  } catch (error) {
    console.error('Resource planning API error:', error)
    return NextResponse.json({ error: 'Failed to fetch activities' }, { status: 500 })
  }
}

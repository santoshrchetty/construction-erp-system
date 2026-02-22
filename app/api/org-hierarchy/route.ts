import { NextRequest, NextResponse } from 'next/server'
import { WorkflowRepository } from '@/domains/workflow/workflowRepository'

export async function GET() {
  try {
    const hierarchy = await WorkflowRepository.getOrganizationalHierarchy()
    return NextResponse.json(hierarchy)
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to fetch' },
      { status: 500 }
    )
  }
}

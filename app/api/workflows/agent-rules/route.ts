import { NextResponse } from 'next/server'
import { WorkflowRepository } from '@/domains/workflow/workflowRepository'

export async function GET() {
  try {
    const rules = await WorkflowRepository.getAgentRules()
    return NextResponse.json(rules)
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch agent rules' }, { status: 500 })
  }
}

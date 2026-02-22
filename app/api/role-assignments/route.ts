import { NextRequest, NextResponse } from 'next/server'
import { RoleAssignmentService } from '@/domains/workflow/roleAssignmentService'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const roleCode = searchParams.get('role_code')
    const assignments = await RoleAssignmentService.getRoleAssignments(roleCode || undefined)
    return NextResponse.json(assignments)
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to fetch' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const assignment = await RoleAssignmentService.createRoleAssignment(body)
    return NextResponse.json(assignment)
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to create' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')
    if (!id) throw new Error('ID required')
    await RoleAssignmentService.deleteRoleAssignment(id)
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to delete' },
      { status: 500 }
    )
  }
}

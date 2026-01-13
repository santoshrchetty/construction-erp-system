import { NextRequest, NextResponse } from 'next/server'
import { userService } from '@/domains/administration/userService'
import { roleService } from '@/domains/administration/roleService'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action')

    switch (action) {
      case 'user-management':
        const users = await userService.getUsers()
        return NextResponse.json({ success: true, data: users })
      
      case 'roles':
        const roles = await userService.getRoles()
        return NextResponse.json({ success: true, data: roles })
      
      case 'departments':
        const departments = await userService.getDepartments()
        return NextResponse.json({ success: true, data: departments })
      
      default:
        return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
    }
  } catch (error) {
    console.error('Admin API error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action')

    switch (action) {
      case 'create-user':
        const user = await userService.createUser(body)
        return NextResponse.json({ success: true, data: user })
      
      case 'create-role':
        const role = await roleService.createRole(body)
        return NextResponse.json({ success: true, data: role })
      
      case 'assign-role':
        await userService.assignRole(body.user_id, body.role_id)
        return NextResponse.json({ success: true })
      
      case 'remove-role':
        await userService.removeRole(body.user_id)
        return NextResponse.json({ success: true })
      
      default:
        return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
    }
  } catch (error) {
    console.error('Admin API error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action')
    const id = searchParams.get('id')

    switch (action) {
      case 'update-user':
        if (!id) throw new Error('User ID required')
        const user = await userService.updateUser(id, body)
        return NextResponse.json({ success: true, data: user })
      
      case 'update-role':
        if (!id) throw new Error('Role ID required')
        const role = await roleService.updateRole(id, body)
        return NextResponse.json({ success: true, data: role })
      
      default:
        return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
    }
  } catch (error) {
    console.error('Admin API error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action')
    const id = searchParams.get('id')

    switch (action) {
      case 'deactivate-user':
        if (!id) throw new Error('User ID required')
        const user = await userService.deactivateUser(id)
        return NextResponse.json({ success: true, data: user })
      
      case 'delete-role':
        if (!id) throw new Error('Role ID required')
        await roleService.deleteRole(id)
        return NextResponse.json({ success: true })
      
      default:
        return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
    }
  } catch (error) {
    console.error('Admin API error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
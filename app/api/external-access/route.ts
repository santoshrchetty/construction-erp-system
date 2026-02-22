import { NextRequest, NextResponse } from 'next/server'
import { handleExternalAccess } from './handler'

export async function GET(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const params = Object.fromEntries(url.searchParams.entries())
    
    if (!action) {
      return NextResponse.json({ success: false, error: 'Action required' }, { status: 400 })
    }
    
    const result = await handleExternalAccess(action, params, 'GET')
    return NextResponse.json({ success: true, data: result })
  } catch (error) {
    console.error('External Access API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to process request' 
    }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const body = await request.json()
    
    if (!action) {
      return NextResponse.json({ success: false, error: 'Action required' }, { status: 400 })
    }
    
    const result = await handleExternalAccess(action, body, 'POST')
    return NextResponse.json({ success: true, data: result })
  } catch (error) {
    console.error('External Access API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to process request' 
    }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const body = await request.json()
    
    if (!action) {
      return NextResponse.json({ success: false, error: 'Action required' }, { status: 400 })
    }
    
    const result = await handleExternalAccess(action, body, 'PUT')
    return NextResponse.json({ success: true, data: result })
  } catch (error) {
    console.error('External Access API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to process request' 
    }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    const params = Object.fromEntries(url.searchParams.entries())
    
    if (!action) {
      return NextResponse.json({ success: false, error: 'Action required' }, { status: 400 })
    }
    
    const result = await handleExternalAccess(action, params, 'DELETE')
    return NextResponse.json({ success: true, data: result })
  } catch (error) {
    console.error('External Access API error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to process request' 
    }, { status: 500 })
  }
}

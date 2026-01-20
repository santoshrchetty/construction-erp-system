import { NextRequest, NextResponse } from 'next/server'
import { handleWBS } from './handler'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const projectId = searchParams.get('projectId')
    const action = searchParams.get('action') || 'nodes'
    
    // If projectId is provided without action, default to getting WBS nodes
    if (projectId && !searchParams.get('action')) {
      const result = await handleWBS('nodes', request, 'GET')
      return NextResponse.json({
        success: true,
        data: result
      })
    }
    
    const result = await handleWBS(action, request, 'GET')
    
    return NextResponse.json({
      success: true,
      category: 'wbs',
      action,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'WBS operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'default'
    
    const result = await handleWBS(action, request, 'POST')
    
    return NextResponse.json({
      success: true,
      category: 'wbs',
      action,
      data: result
    })
  } catch (error) {
    console.error('POST /api/wbs error:', error)
    return NextResponse.json({
      error: 'WBS operation failed',
      details: error instanceof Error ? error.message : JSON.stringify(error)
    }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'default'
    
    const result = await handleWBS(action, request, 'PUT')
    
    return NextResponse.json({
      success: true,
      category: 'wbs',
      action,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'WBS operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'delete'
    
    const result = await handleWBS(action, request, 'DELETE')
    
    return NextResponse.json({
      success: true,
      category: 'wbs',
      action,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'WBS operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
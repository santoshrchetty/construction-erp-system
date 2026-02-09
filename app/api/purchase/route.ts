import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'
import { handlePurchaseOrders } from './handler'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'list'
    
    const authContext = await withAuth(request)
    const result = await handlePurchaseOrders(action, request, 'GET')
    
    return NextResponse.json({
      success: true,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Purchase order operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'create'
    
    const authContext = await withAuth(request)
    const result = await handlePurchaseOrders(action, request, 'POST')
    
    return NextResponse.json({
      success: true,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Purchase order operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'update'
    
    const authContext = await withAuth(request)
    const result = await handlePurchaseOrders(action, request, 'PUT')
    
    return NextResponse.json({
      success: true,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Purchase order operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get('action') || 'delete-item'
    
    const authContext = await withAuth(request)
    const result = await handlePurchaseOrders(action, request, 'DELETE')
    
    return NextResponse.json({
      success: true,
      data: result
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Purchase order operation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
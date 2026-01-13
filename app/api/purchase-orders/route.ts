import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createServiceClient()
    const { data, error } = await supabase
      .from('purchase_orders')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    return NextResponse.json({ purchaseOrders: data })
  } catch (error) {
    console.error('Purchase orders API error:', error)
    return NextResponse.json({ error: 'Failed to fetch purchase orders' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const supabase = createServiceClient()
    
    const { data, error } = await supabase
      .from('purchase_orders')
      .insert(body)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json({ purchaseOrder: data })
  } catch (error) {
    console.error('Purchase order creation error:', error)
    return NextResponse.json({ error: 'Failed to create purchase order' }, { status: 500 })
  }
}
import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('number_ranges')
      .select('*')
      .order('object_type')

    if (error) throw error

    return NextResponse.json({ numberRanges: data })
  } catch (error) {
    console.error('Number ranges API error:', error)
    return NextResponse.json({ error: 'Failed to fetch number ranges' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('number_ranges')
      .insert(body)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json({ numberRange: data })
  } catch (error) {
    console.error('Number range creation error:', error)
    return NextResponse.json({ error: 'Failed to create number range' }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    const { id, ...updateData } = body
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('number_ranges')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json({ numberRange: data })
  } catch (error) {
    console.error('Number range update error:', error)
    return NextResponse.json({ error: 'Failed to update number range' }, { status: 500 })
  }
}
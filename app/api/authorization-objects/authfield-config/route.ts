import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('authorization_field_config')
      .select('*')
      .eq('is_active', true)
      .order('display_order')
    
    if (error) throw error
    
    return NextResponse.json({
      success: true,
      data: data || []
    })
  } catch (error) {
    console.error('Failed to fetch field config:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message 
    }, { status: 500 })
  }
}

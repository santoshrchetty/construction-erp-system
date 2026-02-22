import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = await createServiceClient()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return NextResponse.json({ success: false, count: 0 })
    }

    const { count, error } = await supabase
      .from('step_instances')
      .select('*', { count: 'exact', head: true })
      .eq('assigned_agent_id', user.id)
      .eq('status', 'PENDING')

    if (error) throw error

    return NextResponse.json({ success: true, count: count || 0 })
  } catch (error) {
    console.error('Failed to fetch approvals count:', error)
    return NextResponse.json({ success: false, count: 0 })
  }
}

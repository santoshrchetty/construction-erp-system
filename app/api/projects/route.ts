import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { handleProjects } from './handler'

export async function GET(request: NextRequest) {
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    
    if (action) {
      const result = await handleProjects(action, {}, 'GET')
      return NextResponse.json({ success: true, data: result })
    }
    
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    return NextResponse.json({ projects: data })
  } catch (error) {
    console.error('Projects API error:', error)
    return NextResponse.json({ error: 'Failed to fetch projects' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  console.log('POST request received')
  
  try {
    const url = new URL(request.url)
    const action = url.searchParams.get('action')
    console.log('Action:', action)
    
    const body = await request.json()
    console.log('Body:', body)
    
    console.log('Supabase client created')

    if (action) {
      console.log(`Processing ${action} action`)
      const result = await handleProjects(action, body, 'POST')
      return NextResponse.json({ success: true, data: result })
    }

    // Default: Create new project
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('projects')
      .insert(body)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json({ project: data })
  } catch (error) {
    console.error('Projects API error:', error)
    return NextResponse.json({ error: 'Failed to process request' }, { status: 500 })
  }
}
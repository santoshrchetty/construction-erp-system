import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function POST(request: NextRequest) {
  try {
    const { tenantId } = await request.json()
    const cookieStore = await cookies()
    
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          get: (name) => cookieStore.get(name)?.value,
          set: (name, value, options) => cookieStore.set(name, value, options),
          remove: (name, options) => cookieStore.delete(name),
        }
      }
    )
    
    const { data: { session } } = await supabase.auth.getSession()
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    
    // Fetch user profile to validate tenant access
    const { data: profile, error } = await supabase
      .from('users')
      .select('tenant_id')
      .eq('id', session.user.id)
      .single()
    
    if (error || !profile) {
      return NextResponse.json({ error: 'User profile not found' }, { status: 404 })
    }
    
    // Validate tenant access
    if (tenantId && profile.tenant_id !== tenantId) {
      return NextResponse.json(
        { error: 'You do not have access to this tenant' },
        { status: 403 }
      )
    }
    
    // Set tenant cookie (server-side)
    const response = NextResponse.json({ 
      success: true, 
      tenantId: profile.tenant_id 
    })
    
    response.cookies.set('tenant-id', profile.tenant_id, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 7 // 7 days
    })
    
    return response
  } catch (error) {
    console.error('Tenant session error:', error)
    return NextResponse.json(
      { error: 'Failed to set tenant session' },
      { status: 500 }
    )
  }
}

export async function GET(request: NextRequest) {
  try {
    const cookieStore = await cookies()
    const tenantId = cookieStore.get('tenant-id')?.value
    
    if (!tenantId) {
      return NextResponse.json({ tenantId: null })
    }
    
    return NextResponse.json({ tenantId })
  } catch (error) {
    console.error('Get tenant session error:', error)
    return NextResponse.json({ tenantId: null })
  }
}

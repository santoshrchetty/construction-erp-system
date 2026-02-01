import { createServiceClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import { authCache } from '@/lib/authCache'

export async function POST() {
  try {
    const supabase = await createServiceClient()
    
    // Get user before logout to clear their cache
    const { data: { user } } = await supabase.auth.getUser()
    
    // Server-side session invalidation
    await supabase.auth.signOut()
    
    // Clear user's cached authorization data
    if (user) {
      authCache.clearUser(user.id)
    }
    
    const response = NextResponse.json({ success: true })
    
    // Clear tenant cookie
    response.cookies.delete('tenant-id')
    
    // Set secure headers
    response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate')
    response.headers.set('Pragma', 'no-cache')
    
    return response
    
  } catch (error) {
    console.error('Server logout error:', error)
    return NextResponse.json({ error: 'Logout failed' }, { status: 500 })
  }
}
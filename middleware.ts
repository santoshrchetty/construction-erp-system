import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { cookies } from 'next/headers'
import { extractSubdomain, isLocalDevelopment } from '@/lib/utils/subdomain'

// Define protected and public routes
const protectedRoutes = ['/erp-modules', '/admin', '/projects', '/finance', '/materials', '/inventory']
const authRoutes = ['/login', '/signup']
const publicRoutes = ['/', '/about', '/contact']

// Extract subdomain from request
function getSubdomainFromRequest(req: NextRequest): string | null {
  const host = req.headers.get('host')
  if (!host) return null
  
  // Development mode - no subdomain
  if (isLocalDevelopment(host)) return null
  
  return extractSubdomain(host)
}

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl
  
  // Skip middleware for static files and public routes
  if (
    pathname.startsWith('/_next') ||
    pathname.includes('.') ||
    publicRoutes.includes(pathname)
  ) {
    return NextResponse.next()
  }
  
  const res = NextResponse.next()
  
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return req.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => {
            req.cookies.set(name, value)
            res.cookies.set(name, value)
          })
        },
      },
    }
  )
  
  const { data: { session } } = await supabase.auth.getSession()
  const subdomain = getSubdomainFromRequest(req)
  
  // For API routes, add subdomain to headers
  if (pathname.startsWith('/api')) {
    const response = NextResponse.next()
    if (subdomain) response.headers.set('x-subdomain', subdomain)
    return response
  }
  
  // Protect routes that require authentication
  if (!session && protectedRoutes.some(route => pathname.startsWith(route))) {
    const redirectUrl = new URL('/login', req.url)
    redirectUrl.searchParams.set('redirectTo', pathname)
    return NextResponse.redirect(redirectUrl)
  }
  
  // If user is authenticated, validate tenant access
  if (session) {
    const tenantCookie = req.cookies.get('tenant-id')?.value
    
    if (!tenantCookie && protectedRoutes.some(route => pathname.startsWith(route))) {
      const redirectUrl = new URL('/login', req.url)
      redirectUrl.searchParams.set('redirectTo', pathname)
      return NextResponse.redirect(redirectUrl)
    }
    
    // Fetch user profile and tenant
    const { data: profile } = await supabase
      .from('users')
      .select('tenant_id, tenants!inner(subdomain)')
      .eq('id', session.user.id)
      .single()
    
    if (profile && tenantCookie && profile.tenant_id !== tenantCookie) {
      const response = NextResponse.redirect(new URL('/login', req.url))
      response.cookies.delete('tenant-id')
      return response
    }
    
    // Validate subdomain matches user's tenant (production only)
    if (subdomain && profile?.tenants?.subdomain && subdomain !== profile.tenants.subdomain) {
      const response = NextResponse.redirect(new URL('/login', req.url))
      response.cookies.delete('tenant-id')
      return response
    }
  }
  
  // Add security headers
  const response = NextResponse.next()
  const tenantCookie = req.cookies.get('tenant-id')?.value
  
  if (tenantCookie) response.headers.set('x-tenant-id', tenantCookie)
  if (subdomain) response.headers.set('x-subdomain', subdomain)
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.headers.set('X-XSS-Protection', '1; mode=block')
  
  if (process.env.NODE_ENV === 'production') {
    response.headers.set(
      'Content-Security-Policy',
      "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://*.supabase.co;"
    )
  }
  
  return response
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { cookies } from 'next/headers'

// Define protected and public routes
const protectedRoutes = ['/erp-modules', '/admin', '/projects', '/finance', '/materials', '/inventory']
const authRoutes = ['/login', '/signup']
const publicRoutes = ['/', '/about', '/contact']

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl
  
  // Skip auth check for static files and API routes
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    pathname.includes('.') ||
    publicRoutes.includes(pathname)
  ) {
    return NextResponse.next()
  }
  
  const res = NextResponse.next()
  
  // Create a Supabase client configured to use cookies
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
  
  const {
    data: { session },
    error
  } = await supabase.auth.getSession()
  
  // Handle authentication errors - only log once, don't spam
  if (error && error.status === 429) {
    // Rate limited - allow through to avoid infinite loop
    return NextResponse.next()
  }
  
  if (error) {
    console.error('Middleware auth error:', error)
    if (protectedRoutes.some(route => pathname.startsWith(route))) {
      return NextResponse.redirect(new URL('/login', req.url))
    }
  }
  
  // Redirect authenticated users away from auth pages
  if (session && authRoutes.some(route => pathname.startsWith(route))) {
    return NextResponse.redirect(new URL('/erp-modules', req.url))
  }
  
  // Protect routes that require authentication
  if (!session && protectedRoutes.some(route => pathname.startsWith(route))) {
    const redirectUrl = new URL('/login', req.url)
    redirectUrl.searchParams.set('redirectTo', pathname)
    return NextResponse.redirect(redirectUrl)
  }
  
  // Add security headers
  const response = NextResponse.next()
  
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.headers.set('X-XSS-Protection', '1; mode=block')
  
  // Add CSP header for production
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
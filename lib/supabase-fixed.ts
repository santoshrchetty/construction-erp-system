import { createClient } from '@supabase/supabase-js'
import { createClientComponentClient, createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { Database } from '@/types/supabase/database.types'
import { cookies } from 'next/headers'

// Client-side Supabase client (for components)
export const createBrowserClient = () => {
  return createClientComponentClient<Database>()
}

// Server-side Supabase client (for server components/API routes)
export const createServerClient = () => {
  const cookieStore = cookies()
  return createServerComponentClient<Database>({ cookies: () => cookieStore })
}

// Service role client (for admin operations)
export const createServiceClient = () => {
  return createClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    }
  )
}

// Default client for components (to avoid multiple instances)
let browserClient: ReturnType<typeof createClientComponentClient<Database>> | null = null

export const supabase = (() => {
  if (typeof window !== 'undefined') {
    // Client-side: reuse the same instance
    if (!browserClient) {
      browserClient = createClientComponentClient<Database>()
    }
    return browserClient
  } else {
    // Server-side: create new instance each time
    return createClient<Database>(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
  }
})()
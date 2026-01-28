import { createBrowserClient } from '@supabase/ssr'
import { Database } from '@/types/supabase/database.types'

// Singleton instance to prevent multiple clients
let clientInstance: ReturnType<typeof createBrowserClient<Database>> | null = null

// Client-side browser client with singleton pattern
export function createClient() {
  if (clientInstance) return clientInstance
  
  clientInstance = createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
        flowType: 'pkce'
      }
    }
  )
  
  return clientInstance
}

// Default client instance for components
export const supabase = createClient()
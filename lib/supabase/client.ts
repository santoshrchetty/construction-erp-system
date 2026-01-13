import { createBrowserClient } from '@supabase/ssr'
import { Database } from '@/types/supabase/database.types'

// Client-side browser client
export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}

// Default client instance for components (auth only)
export const supabase = createClient()
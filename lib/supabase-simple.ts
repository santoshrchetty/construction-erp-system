import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { Database } from '@/types/supabase/database.types'

// Single client instance to avoid multiple client warnings
let clientInstance: ReturnType<typeof createClientComponentClient<Database>> | null = null

export const supabase = (() => {
  if (typeof window !== 'undefined') {
    // Client-side: reuse the same instance
    if (!clientInstance) {
      clientInstance = createClientComponentClient<Database>()
    }
    return clientInstance
  }
  // This shouldn't happen in client components, but fallback
  return createClientComponentClient<Database>()
})()

export default supabase
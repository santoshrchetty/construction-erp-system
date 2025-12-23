import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { Database } from '@/types/supabase/database.types'

// Single unified Supabase client for the entire application
export const supabase = createClientComponentClient<Database>()

// Export as default for backward compatibility
export default supabase
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { Database } from '@/types/supabase/database.types'

// Use Supabase auth helpers for better Next.js integration
export const supabase = createClientComponentClient<Database>()
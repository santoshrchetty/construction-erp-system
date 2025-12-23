// Centralized Supabase client exports following best practices

// Client-side auth client (for components)
export { supabase as clientAuth } from '../supabase-client'

// Server-side clients (for server actions and components)
export { createServerClient, createServiceClient } from '../supabase-server'

// Types
export type { Database } from '@/types/supabase/database.types'
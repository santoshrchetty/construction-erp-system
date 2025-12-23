'use server'

import { createServiceClient } from '@/lib/supabase'
import { Database } from '@/types/supabase/database.types'

const supabase = createServiceClient()

interface BatchUserData {
  email: string
  password: string
  first_name?: string
  last_name?: string
  role_id: string
  department?: string
}

// Retry with exponential backoff
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  baseDelay = 1000
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (error: any) {
      if (error.message?.includes('rate limit') && i < maxRetries - 1) {
        const delay = baseDelay * Math.pow(2, i)
        await new Promise(resolve => setTimeout(resolve, delay))
        continue
      }
      throw error
    }
  }
  throw new Error('Max retries exceeded')
}

// Production-safe user creation with rate limiting
export async function createUserSafe(userData: BatchUserData) {
  return retryWithBackoff(async () => {
    // Validate role exists
    const { data: role } = await supabase
      .from('roles')
      .select('id')
      .eq('id', userData.role_id)
      .single()
    
    if (!role) throw new Error('Invalid role selected')

    // Create auth user with retry
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: userData.email,
      password: userData.password,
      email_confirm: true
    })

    if (authError) {
      if (authError.message.includes('rate limit')) {
        throw new Error('rate limit exceeded')
      }
      throw new Error(`Auth creation failed: ${authError.message}`)
    }

    // Create profile
    const profileData: Database['public']['Tables']['users']['Insert'] = {
      id: authData.user.id,
      email: userData.email,
      first_name: userData.first_name || null,
      last_name: userData.last_name || null,
      department: userData.department || null,
      role_id: userData.role_id,
      is_active: true
    }

    const { error: profileError } = await supabase
      .from('users')
      .insert(profileData)

    if (profileError) {
      // Cleanup on failure
      await supabase.auth.admin.deleteUser(authData.user.id)
      throw new Error(`Profile creation failed: ${profileError.message}`)
    }

    return { success: true, userId: authData.user.id }
  })
}

// Batch create with rate limit management
export async function createUsersBatch(users: BatchUserData[]) {
  const results = []
  const BATCH_SIZE = 5 // Process 5 at a time
  const DELAY_BETWEEN_BATCHES = 2000 // 2 second delay

  for (let i = 0; i < users.length; i += BATCH_SIZE) {
    const batch = users.slice(i, i + BATCH_SIZE)
    
    const batchResults = await Promise.allSettled(
      batch.map(user => createUserSafe(user))
    )

    results.push(...batchResults)

    // Delay between batches to avoid rate limits
    if (i + BATCH_SIZE < users.length) {
      await new Promise(resolve => setTimeout(resolve, DELAY_BETWEEN_BATCHES))
    }
  }

  return results
}
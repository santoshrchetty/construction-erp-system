'use server'

import { revalidatePath } from 'next/cache'
import { createServiceClient } from '@/lib/supabase'
import { Database } from '@/types/supabase/database.types'

const supabase = createServiceClient()

export async function getUsers() {
  try {
    const { data, error } = await supabase
      .from('users')
      .select(`
        id, email, first_name, last_name, role_id, employee_code, department, is_active, created_at,
        roles(id, name, description)
      `)
      .order('created_at', { ascending: false })

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch users' }
  }
}

export async function getRoles() {
  try {
    const { data, error } = await supabase
      .from('roles')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch roles' }
  }
}

export async function updateUser(userId: string, formData: FormData) {
  try {
    if (!userId) {
      throw new Error('User ID is required')
    }

    const roleId = formData.get('role_id') as string
    
    // Validate role if provided
    if (roleId) {
      const { data: role } = await supabase
        .from('roles')
        .select('id')
        .eq('id', roleId)
        .single()
      
      if (!role) {
        throw new Error('Invalid role selected')
      }
    }

    const data: Database['public']['Tables']['users']['Update'] = {
      first_name: (formData.get('first_name') as string)?.trim() || null,
      last_name: (formData.get('last_name') as string)?.trim() || null,
      employee_code: (formData.get('employee_code') as string)?.trim() || null,
      department: (formData.get('department') as string)?.trim() || null,
      role_id: roleId || null,
      is_active: formData.get('is_active') === 'true'
    }

    const { error } = await supabase
      .from('users')
      .update(data)
      .eq('id', userId)

    if (error) throw new Error(`Update failed: ${error.message}`)

    revalidatePath('/admin')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update user' }
  }
}

// Retry with exponential backoff for rate limits
async function retryAuthOperation<T>(
  operation: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await operation()
    } catch (error: any) {
      const isRateLimit = error.message?.toLowerCase().includes('rate limit') || 
                         error.message?.toLowerCase().includes('too many requests')
      
      if (isRateLimit && i < maxRetries - 1) {
        const delay = Math.pow(2, i) * 1000 + Math.random() * 1000 // 1s, 2s, 4s + jitter
        await new Promise(resolve => setTimeout(resolve, delay))
        continue
      }
      throw error
    }
  }
  throw new Error('Max retries exceeded')
}

export async function createUser(formData: FormData) {
  try {
    const email = formData.get('email') as string
    const password = formData.get('password') as string
    const roleId = formData.get('role_id') as string

    // Validate required fields
    if (!email || !password || !roleId) {
      throw new Error('Email, password, and role are required')
    }

    // Validate role exists
    const { data: role } = await supabase
      .from('roles')
      .select('id')
      .eq('id', roleId)
      .single()
    
    if (!role) {
      throw new Error('Invalid role selected')
    }

    // Create auth user with retry logic
    const authData = await retryAuthOperation(async () => {
      const { data, error } = await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true
      })
      if (error) throw new Error(`Auth creation failed: ${error.message}`)
      return data
    })

    // Insert user profile (not update since user doesn't exist yet)
    const profileData: Database['public']['Tables']['users']['Insert'] = {
      id: authData.user.id,
      email,
      first_name: (formData.get('first_name') as string)?.trim() || null,
      last_name: (formData.get('last_name') as string)?.trim() || null,
      employee_code: (formData.get('employee_code') as string)?.trim() || null,
      department: (formData.get('department') as string)?.trim() || null,
      role_id: roleId,
      is_active: true
    }

    const { error: profileError } = await supabase
      .from('users')
      .insert(profileData)

    if (profileError) {
      // Cleanup: delete auth user if profile creation fails
      await retryAuthOperation(() => supabase.auth.admin.deleteUser(authData.user.id))
      throw new Error(`Profile creation failed: ${profileError.message}`)
    }

    revalidatePath('/admin')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create user' }
  }
}

export async function deactivateUser(userId: string) {
  try {
    const { error } = await supabase
      .from('users')
      .update({ is_active: false })
      .eq('id', userId)

    if (error) throw error

    revalidatePath('/admin')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to deactivate user' }
  }
}

export async function resetUserPassword(userId: string, newPassword: string) {
  try {
    const { error } = await supabase.auth.admin.updateUserById(userId, {
      password: newPassword
    })

    if (error) throw error
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to reset password' }
  }
}
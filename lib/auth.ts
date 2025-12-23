import { supabase } from './supabase'

export interface User {
  id: string
  email: string
  first_name?: string
  last_name?: string
  role_id?: string
  employee_code?: string
  department?: string
  role?: {
    name: string
    permissions: any
  }
}

export class AuthService {
  /**
   * Sign up new user
   */
  static async signUp(email: string, password: string, userData?: Partial<User>) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: userData
      }
    })

    if (error) throw error
    return data
  }

  /**
   * Sign in user
   */
  static async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    })

    if (error) throw error
    return data
  }

  /**
   * Sign out user
   */
  static async signOut() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  /**
   * Get current user with role
   */
  static async getCurrentUser(): Promise<User | null> {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) return null

    const { data: userData, error } = await supabase
      .from('users')
      .select(`
        *,
        role:roles(name, permissions)
      `)
      .eq('id', user.id)
      .single()

    if (error) throw error
    return userData
  }

  /**
   * Update user profile
   */
  static async updateProfile(userId: string, updates: Partial<User>) {
    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', userId)
      .select()
      .single()

    if (error) throw error
    return data
  }

  /**
   * Check if user has permission
   */
  static async hasPermission(resource: string, action: string): Promise<boolean> {
    const { data, error } = await supabase
      .rpc('has_permission', {
        user_id: (await supabase.auth.getUser()).data.user?.id,
        resource,
        action
      })

    if (error) return false
    return data
  }

  /**
   * Get user role
   */
  static async getUserRole(): Promise<string> {
    const { data, error } = await supabase
      .rpc('get_user_role', {
        user_id: (await supabase.auth.getUser()).data.user?.id
      })

    if (error) return 'Employee'
    return data
  }

  /**
   * Get all roles
   */
  static async getRoles() {
    const { data, error } = await supabase
      .from('roles')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return data
  }

  /**
   * Assign role to user
   */
  static async assignRole(userId: string, roleId: string) {
    const { data, error } = await supabase
      .from('users')
      .update({ role_id: roleId })
      .eq('id', userId)
      .select()
      .single()

    if (error) throw error
    return data
  }
}
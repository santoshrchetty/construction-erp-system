import { createServiceClient } from '@/lib/supabase/server'
import type { SupabaseClient } from '@supabase/supabase-js'

export class AuthorizationRepository {
  private supabase: SupabaseClient | null = null

  constructor(supabase?: SupabaseClient) {
    this.supabase = supabase || null
  }

  get client() {
    if (!this.supabase) {
      throw new Error('Supabase client not initialized. Use async methods.')
    }
    return this.supabase
  }

  async initClient() {
    if (!this.supabase) {
      this.supabase = await createServiceClient()
    }
    return this.supabase
  }

  async getUserRole(userId: string) {
    const client = await this.initClient()
    const { data, error } = await client
      .from('users')
      .select('*, roles(*)')
      .eq('id', userId)
      .single()

    if (error) throw error
    return data
  }

  async getRolePermissions(roleId: string) {
    const client = await this.initClient()
    const { data, error } = await client
      .from('role_authorization_objects')
      .select('authorization_objects(object_name, module)')
      .eq('role_id', roleId)
      .eq('is_active', true)

    if (error) throw error
    return data || []
  }

  async getAvailableModules() {
    const client = await this.initClient()
    const { data, error } = await client
      .from('authorization_objects')
      .select('module')
      .neq('module', null)
      .order('module')

    if (error) throw error
    
    // Use Set for deduplication but return array
    const uniqueModules = [...new Set(data?.map(obj => obj.module) || [])]
    return uniqueModules
  }

  async getRoleByName(roleName: string) {
    const client = await this.initClient()
    const { data, error } = await client
      .from('roles')
      .select('id')
      .eq('name', roleName)
      .single()

    if (error) throw error
    return data
  }

  async getRoleModules(roleId: string) {
    const client = await this.initClient()
    const { data, error } = await client
      .from('role_authorization_objects')
      .select('authorization_objects!inner(module)')
      .eq('role_id', roleId)
      .eq('is_active', true)

    if (error) throw error
    return data?.map(obj => obj.authorization_objects.module) || []
  }
}
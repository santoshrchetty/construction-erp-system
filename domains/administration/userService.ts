import { createServiceClient } from '@/lib/supabase/server'

// Fixed import path for server-side operations

export interface CreateUserRequest {
  email: string
  password: string
  first_name: string
  last_name: string
  employee_code: string
  department: string
  role_id: string
}

export interface UpdateUserRequest {
  first_name: string
  last_name: string
  employee_code: string
  department: string
  role_id: string
  is_active: boolean
}

export class UserService {
  private async getClient() {
    return await createServiceClient()
  }

  async getUsers() {
    const client = await this.getClient()
    const { data: users, error: usersError } = await client
      .from('users')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (usersError) throw usersError
    
    const { data: roles, error: rolesError } = await client
      .from('roles')
      .select('*')
    
    if (rolesError) throw rolesError
    
    return users.map(user => ({
      ...user,
      roles: roles.find(role => role.id === user.role_id) || null
    }))
  }

  async getRoles() {
    const client = await this.getClient()
    const { data, error } = await client
      .from('roles')
      .select('id, name, description')
      .order('name')
    
    if (error) throw error
    return data || []
  }

  async getDepartments() {
    const client = await this.getClient()
    const { data, error } = await client
      .from('departments')
      .select('id, name, code, description')
      .eq('is_active', true)
      .order('name')
    
    if (error) throw error
    return data || []
  }

  async createUser(userData: CreateUserRequest) {
    const client = await this.getClient()
    const { data: authUser, error: authError } = await client.auth.admin.createUser({
      email: userData.email,
      password: userData.password,
      email_confirm: true
    })

    if (authError) throw authError

    const { data: user, error: userError } = await client
      .from('users')
      .insert({
        id: authUser.user.id,
        email: userData.email,
        first_name: userData.first_name,
        last_name: userData.last_name,
        employee_code: userData.employee_code,
        department: userData.department,
        role_id: userData.role_id,
        is_active: true
      })
      .select()
      .single()

    if (userError) throw userError
    return user
  }

  async updateUser(userId: string, userData: UpdateUserRequest) {
    const client = await this.getClient()
    const { data, error } = await client
      .from('users')
      .update({
        first_name: userData.first_name,
        last_name: userData.last_name,
        employee_code: userData.employee_code,
        department: userData.department,
        role_id: userData.role_id,
        is_active: userData.is_active
      })
      .eq('id', userId)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async deactivateUser(userId: string) {
    const client = await this.getClient()
    const { data, error } = await client
      .from('users')
      .update({ is_active: false })
      .eq('id', userId)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async assignRole(userId: string, roleId: string) {
    const client = await this.getClient()
    const { data, error } = await client
      .from('users')
      .update({ role_id: roleId })
      .eq('id', userId)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async removeRole(userId: string) {
    const client = await this.getClient()
    const { data, error } = await client
      .from('users')
      .update({ role_id: null })
      .eq('id', userId)
      .select()
      .single()

    if (error) throw error
    return data
  }
}

export const userService = new UserService()
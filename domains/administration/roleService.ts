import { createServiceClient } from '@/lib/supabase/server'

export interface Role {
  id: string
  name: string
  description: string
}

export interface AuthObject {
  id: string
  object_name: string
  description: string
  module: string
  fields: AuthField[]
}

export interface AuthField {
  id: string
  field_name: string
  field_description: string
  field_values: string[]
}

export class RoleService {
  private supabase = createServiceClient()

  async getRoles(): Promise<Role[]> {
    const { data, error } = await this.supabase
      .from('roles')
      .select('*')
      .order('name')
    
    if (error) throw error
    return data || []
  }

  async createRole(role: Omit<Role, 'id'>): Promise<Role> {
    const { data, error } = await this.supabase
      .from('roles')
      .insert(role)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async updateRole(roleId: string, role: Partial<Role>): Promise<Role> {
    const { data, error } = await this.supabase
      .from('roles')
      .update(role)
      .eq('id', roleId)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  async deleteRole(roleId: string): Promise<void> {
    const { error } = await this.supabase
      .from('roles')
      .delete()
      .eq('id', roleId)
    
    if (error) throw error
  }

  async getAuthObjects(): Promise<AuthObject[]> {
    return [
      {
        id: '1',
        object_name: 'PROJECT_MANAGEMENT',
        description: 'Project Management Access',
        module: 'projects',
        fields: [
          {
            id: '1',
            field_name: 'ACTIVITY',
            field_description: 'Activity Type',
            field_values: ['CREATE', 'READ', 'UPDATE', 'DELETE', '*']
          }
        ]
      }
    ]
  }

  async getRoleAuthorizations(roleName: string): Promise<any[]> {
    return []
  }

  async saveRoleAuthorizations(roleName: string, authorizations: any[]): Promise<void> {
    console.log('Saving role authorizations:', { roleName, authorizations })
  }
}

export const roleService = new RoleService()
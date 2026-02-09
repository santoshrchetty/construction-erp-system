import { AuthorizationRepository } from './authorizationRepository'
import { authCache } from '@/lib/authCache'
import { UserRole } from '@/lib/permissions/types'
import type { SupabaseClient } from '@supabase/supabase-js'

export class AuthorizationService {
  private repository: AuthorizationRepository

  constructor(supabase?: SupabaseClient) {
    this.repository = new AuthorizationRepository(supabase)
  }

  async getUserPermissions(userId: string) {
    try {
      const profile = await this.repository.getUserRole(userId)
      const roleId = profile?.role_id
      
      if (!roleId) {
        return {
          profile: null,
          authorizedObjects: new Set<string>(),
          isAdmin: false
        }
      }
      
      // Check cache first
      let authorizedObjects = authCache.get(userId, roleId)
      
      if (!authorizedObjects) {
        authorizedObjects = await this.repository.getRolePermissions(roleId)
        authCache.set(userId, roleId, authorizedObjects)
      }

      const objectNames = new Set(
        authorizedObjects?.map(auth => auth.authorization_objects?.object_name).filter(Boolean) || []
      )

      return {
        profile,
        authorizedObjects: objectNames,
        isAdmin: profile?.roles?.name === 'Admin'
      }
    } catch (error) {
      if (process.env.NODE_ENV === 'development') {
        console.error('Authorization service error:', error)
      }
      return {
        profile: null,
        authorizedObjects: new Set<string>(),
        isAdmin: false
      }
    }
  }

  async getUserModules(roleName: string) {
    try {
      const availableModules = await this.repository.getAvailableModules()
      
      // Get role ID from name with null checking
      const role = await this.repository.getRoleByName(roleName)
      if (!role?.id) {
        throw new Error(`Role '${roleName}' not found`)
      }
      
      const assignedModules = await this.repository.getRoleModules(role.id)
      
      const assignedSet = new Set(assignedModules)
      const unassignedModules = availableModules.filter(module => !assignedSet.has(module))

      return {
        availableModules: unassignedModules,
        assignedModules
      }
    } catch (error) {
      if (process.env.NODE_ENV === 'development') {
        console.error('Module service error:', error)
      }
      throw error // Re-throw for proper error handling in API
    }
  }

  async getUserCompanyCodes(userId: string) {
    try {
      const profile = await this.repository.getUserRole(userId)
      
      if (!profile) {
        return { companyCodes: [], currentCompanyCode: null }
      }
      
      // Get all company codes user has access to within their group
      const client = await this.repository.initClient()
      const { data: companyCodes, error } = await client
        .from('company_codes')
        .select('company_code, company_name, currency, grpcompany_code')
        .eq('grpcompany_code', profile.grpcompany_code)
        .eq('is_active', true)
        .order('company_code')
      
      if (error) throw error
      
      return {
        companyCodes: companyCodes || [],
        currentCompanyCode: profile.company_code || companyCodes?.[0]?.company_code
      }
    } catch (error) {
      console.error('Get user company codes error:', error)
      return { companyCodes: [], currentCompanyCode: null }
    }
  }

  invalidateUserCache(userId: string) {
    authCache.clearUser(userId)
  }

  hasPermission(authorizedObjects: Set<string>, permission: string): boolean {
    return authorizedObjects.has(permission)
  }
}
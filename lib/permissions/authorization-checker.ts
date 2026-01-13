import { createClient } from '@/lib/supabase-server'

export async function checkUserAuthorization(userId: string, authObject: string): Promise<boolean> {
  try {
    const supabase = createClient()
    
    // Get user profile with role information
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select('*, roles(*)')
      .eq('id', userId)
      .single()
    
    if (profileError || !profile) {
      console.error('Profile fetch error:', profileError)
      return false
    }
    
    // Admin gets full access to everything
    if (profile.roles?.name === 'Admin' || profile.roles?.name === 'System Administrator') {
      return true
    }
    
    // Check if user has specific authorization for this object
    const { data: userRoles, error: rolesError } = await supabase
      .from('user_roles')
      .select('role_id')
      .eq('user_id', userId)
      .eq('is_active', true)
    
    if (rolesError || !userRoles || userRoles.length === 0) {
      return false
    }
    
    const roleIds = userRoles.map(ur => ur.role_id)
    
    // Get authorization objects for user's roles
    const { data: authObjects, error: authError } = await supabase
      .from('authorization_objects')
      .select('id, object_name')
      .eq('object_name', authObject)
      .single()
    
    if (authError || !authObjects) {
      // If auth object doesn't exist in DB, deny access
      return false
    }
    
    // Check if user has access to this authorization object
    const { data: roleAuth, error: roleAuthError } = await supabase
      .from('role_authorization_objects')
      .select('*')
      .in('role_id', roleIds)
      .eq('auth_object_id', authObjects.id)
      .eq('is_active', true)
    
    if (roleAuthError) {
      console.error('Role auth check error:', roleAuthError)
      return false
    }
    
    // User has access if any role assignment exists for this object
    return roleAuth && roleAuth.length > 0
    
  } catch (error) {
    console.error('Authorization check error:', error)
    return false
  }
}

export async function getUserAuthorizedObjects(userId: string): Promise<string[]> {
  try {
    const supabase = createClient()
    
    // Get user profile
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select('*, roles(*)')
      .eq('id', userId)
      .single()
    
    if (profileError || !profile) {
      return []
    }
    
    // Admin gets all objects
    if (profile.roles?.name === 'Admin' || profile.roles?.name === 'System Administrator') {
      const { data: allObjects } = await supabase
        .from('authorization_objects')
        .select('object_name')
      
      return allObjects?.map(obj => obj.object_name) || []
    }
    
    // Get user's role IDs
    const { data: userRoles } = await supabase
      .from('user_roles')
      .select('role_id')
      .eq('user_id', userId)
      .eq('is_active', true)
    
    if (!userRoles || userRoles.length === 0) {
      return []
    }
    
    const roleIds = userRoles.map(ur => ur.role_id)
    
    // Get authorized objects for user's roles
    const { data: authorizedObjects } = await supabase
      .from('role_authorization_objects')
      .select(`
        authorization_objects!inner(object_name)
      `)
      .in('role_id', roleIds)
      .eq('is_active', true)
    
    return authorizedObjects?.map(auth => auth.authorization_objects.object_name) || []
    
  } catch (error) {
    console.error('Get authorized objects error:', error)
    return []
  }
}
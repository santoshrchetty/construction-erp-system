import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { AuthorizationService } from '@/lib/services/authorizationService'
import type { User } from '@supabase/supabase-js'

interface UserProfile {
  id: string
  role_id: string
  roles: {
    name: string
  } | null
}

export interface AuthContext {
  user: User
  profile: UserProfile | null
  authorizedObjects: Set<string>
  isAdmin: boolean
  authService: AuthorizationService
  tenantId: string
}

export function withAuth(
  handler: (request: NextRequest, context: AuthContext) => Promise<NextResponse>,
  requiredPermissions?: string[]
) {
  return async (request: NextRequest) => {
    try {
      const supabase = await createServiceClient()
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      
      if (userError || !user) {
        return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
      }

      const authService = new AuthorizationService(supabase)
      const { profile, authorizedObjects, isAdmin } = await authService.getUserPermissions(user.id)

      // Get tenant_id from secure cookie (set during login)
      const tenantCookie = request.cookies.get('tenant-id')?.value
      
      if (!tenantCookie) {
        return NextResponse.json({ error: 'No tenant context' }, { status: 401 })
      }
      
      // Validate user belongs to tenant
      const { data: userProfile, error: profileError } = await supabase
        .from('users')
        .select('tenant_id')
        .eq('id', user.id)
        .single()
      
      if (profileError || !userProfile || userProfile.tenant_id !== tenantCookie) {
        return NextResponse.json({ error: 'Tenant access denied' }, { status: 403 })
      }

      // Check required permissions
      if (requiredPermissions && !isAdmin) {
        const hasPermission = requiredPermissions.some(permission => 
          authService.hasPermission(authorizedObjects, permission)
        )
        
        if (!hasPermission) {
          return NextResponse.json({ error: 'Insufficient permissions' }, { status: 403 })
        }
      }

      const context: AuthContext = {
        user,
        profile,
        authorizedObjects,
        isAdmin,
        authService,
        tenantId: tenantCookie
      }

      return await handler(request, context)
    } catch (error) {
      // Use proper logging instead of console.error in production
      if (process.env.NODE_ENV === 'development') {
        console.error('Auth middleware error:', error)
      }
      return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
    }
  }
}
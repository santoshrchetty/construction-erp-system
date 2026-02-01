import { NextRequest } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export interface TenantContext {
  tenantId: string
  userId: string
  supabase: ReturnType<typeof createServerClient>
}

/**
 * Validates tenant access and returns tenant context for API routes
 * Throws error if validation fails
 */
export async function validateTenantAccess(request: NextRequest): Promise<TenantContext> {
  const cookieStore = await cookies()
  
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get: (name) => cookieStore.get(name)?.value,
        set: (name, value, options) => cookieStore.set(name, value, options),
        remove: (name, options) => cookieStore.delete(name),
      }
    }
  )
  
  // Check authentication
  const { data: { session }, error: sessionError } = await supabase.auth.getSession()
  
  if (sessionError || !session) {
    throw new Error('Unauthorized: No valid session')
  }
  
  // Get tenant from cookie
  const tenantId = cookieStore.get('tenant-id')?.value
  
  if (!tenantId) {
    throw new Error('Unauthorized: No tenant context')
  }
  
  // Validate user belongs to tenant
  const { data: profile, error: profileError } = await supabase
    .from('users')
    .select('tenant_id')
    .eq('id', session.user.id)
    .single()
  
  if (profileError || !profile) {
    throw new Error('Unauthorized: User profile not found')
  }
  
  if (profile.tenant_id !== tenantId) {
    throw new Error('Forbidden: Tenant access denied')
  }
  
  return {
    tenantId,
    userId: session.user.id,
    supabase
  }
}

/**
 * Helper to add tenant filter to Supabase queries
 */
export function withTenantFilter<T>(
  query: any,
  tenantId: string,
  tenantColumn: string = 'tenant_id'
) {
  return query.eq(tenantColumn, tenantId)
}

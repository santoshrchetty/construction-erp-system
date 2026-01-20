import { NextRequest } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'
import { cookies } from 'next/headers'
import { UserRole, Module, Permission } from '@/lib/permissions/types'
import { permissionChecker } from '@/lib/permissions/checker'

export async function withAuth(request: NextRequest) {
  const supabase = await createServiceClient()
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (userError || !user) throw new Error('Unauthorized')
  
  const { data: profile } = await supabase
    .from('users')
    .select('*, roles(*)')
    .eq('id', user.id)
    .single()
  
  const userRole = profile?.roles?.name as UserRole || UserRole.EMPLOYEE
  
  return { user, profile, userRole, supabase, userId: user.id }
}
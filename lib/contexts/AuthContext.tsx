'use client'
import { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { createClient } from '@/lib/supabase/client'
import { User, Session } from '@supabase/supabase-js'
import { useRouter } from 'next/navigation'
import { extractSubdomain, isLocalDevelopment } from '@/lib/utils/subdomain'

interface AuthContextType {
  user: User | null
  profile: any
  session: Session | null
  loading: boolean
  currentTenant: string | null
  signIn: (email: string, password: string, selectedTenantId?: string) => Promise<{ session: Session | null; profile: any }>
  signOut: () => Promise<void>
  refreshSession: () => Promise<void>
  setCurrentTenant: (tenantId: string) => Promise<void>
}

const AuthContext = createContext<AuthContextType | null>(null)
const supabase = createClient()

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [profile, setProfile] = useState<any>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const [currentTenant, setCurrentTenantState] = useState<string | null>(null)
  const router = useRouter()

  useEffect(() => {
    let mounted = true

    const initAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession()
        
        if (!mounted) return
        
        setSession(session)
        setUser(session?.user ?? null)
        
        if (session?.user) {
          fetchUserProfile(session.user.id)
        }
      } catch (error) {
        console.error('Auth init error:', error)
      } finally {
        if (mounted) setLoading(false)
      }
    }

    initAuth()

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return
        
        setSession(session)
        setUser(session?.user ?? null)
        
        if (session?.user) {
          fetchUserProfile(session.user.id)
        } else {
          setProfile(null)
        }
        
        if (event === 'SIGNED_OUT') {
          setUser(null)
          setProfile(null)
          setSession(null)
          router.push('/login')
        }
        // Don't auto-redirect on SIGNED_IN - let login page handle it
      }
    )

    return () => {
      mounted = false
      subscription.unsubscribe()
    }
  }, [router])

  const fetchUserProfile = async (userId: string) => {
    try {
      const { data } = await supabase
        .from('users')
        .select('*, roles(*)')
        .eq('id', userId)
        .single()
      
      if (data) setProfile(data)
    } catch (error) {
      console.error('Profile fetch error:', error)
    }
  }

  const signIn = async (email: string, password: string, selectedTenantId?: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    
    // Fetch user profile
    const { data: userProfile, error: profileError } = await supabase
      .from('users')
      .select('*, roles(*), tenants!inner(id, tenant_code, tenant_name, subdomain)')
      .eq('id', data.user.id)
      .single()
    
    if (profileError || !userProfile) {
      throw new Error('Failed to fetch user profile')
    }
    
    // Get subdomain from URL
    const hostname = window.location.hostname
    const subdomain = isLocalDevelopment(hostname) ? null : extractSubdomain(hostname)
    
    // Validate tenant access
    let tenantId = selectedTenantId || userProfile.tenant_id
    
    // If subdomain exists, validate it matches user's tenant
    if (subdomain && userProfile.tenants?.subdomain !== subdomain) {
      await supabase.auth.signOut()
      throw new Error('You do not have access to this organization')
    }
    
    // If tenant selection provided, validate it
    if (selectedTenantId && userProfile.tenant_id !== selectedTenantId) {
      await supabase.auth.signOut()
      throw new Error('You do not have access to the selected organization')
    }
    
    // Set tenant session server-side
    const tenantResponse = await fetch('/api/auth/tenant', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tenantId })
    })
    
    if (!tenantResponse.ok) {
      await supabase.auth.signOut()
      throw new Error('Failed to establish tenant session')
    }
    
    setProfile(userProfile)
    setCurrentTenantState(userProfile.tenant_id)
    
    return { session: data.session, profile: userProfile }
  }

  const signOut = async () => {
    try {
      await fetch('/api/auth/logout', { method: 'POST', credentials: 'include' })
      await supabase.auth.signOut()
      localStorage.clear()
      sessionStorage.clear()
      window.location.href = '/login'
    } catch (error) {
      console.error('Logout error:', error)
      window.location.href = '/login'
    }
  }

  const refreshSession = async () => {
    const { data, error } = await supabase.auth.refreshSession()
    if (error) throw error
    setSession(data.session)
    setUser(data.user)
  }

  const setCurrentTenant = async (tenantId: string) => {
    if (!user) throw new Error('No user logged in')
    
    const { data, error } = await supabase.rpc('set_current_tenant', {
      user_uuid: user.id,
      tenant_uuid: tenantId
    })
    
    if (error || !data) throw new Error('Failed to set tenant')
    
    setCurrentTenantState(tenantId)
    localStorage.setItem('selectedTenant', tenantId)
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <AuthContext.Provider value={{ 
      user, 
      profile, 
      session, 
      loading, 
      currentTenant,
      signIn, 
      signOut, 
      refreshSession,
      setCurrentTenant
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
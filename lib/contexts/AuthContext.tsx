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
        const { data: { user } } = await supabase.auth.getUser()
        
        if (!mounted) return
        
        const { data: { session } } = await supabase.auth.getSession()
        setSession(session)
        setUser(user)
        
        if (user) {
          fetchUserProfile(user.id)
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
      // Get user email from auth
      const { data: authData, error: authError } = await supabase.auth.getUser()
      
      if (authError || !authData?.user?.email) {
        console.error('Auth error in fetchUserProfile:', authError)
        return
      }
      
      const userEmail = authData.user.email
      console.log('Fetching profile for:', userEmail)
      
      // Get selected tenant from cookie (set by login)
      const tenantCookie = document.cookie
        .split('; ')
        .find(row => row.startsWith('tenant-id='))
        ?.split('=')[1]
      
      const selectedTenant = localStorage.getItem('selectedTenant') || tenantCookie
      console.log('Selected tenant:', selectedTenant)
      
      if (!selectedTenant) {
        // If no tenant selected, get first user record
        const { data, error } = await supabase
          .from('users')
          .select('*, roles(*), tenants(*)')
          .eq('email', userEmail)
          .limit(1)
          .single()
        
        console.log('First user record:', { data, error })
        
        if (data) {
          setProfile(data)
          setCurrentTenantState(data.tenant_id)
          localStorage.setItem('selectedTenant', data.tenant_id)
        }
      } else {
        // Fetch user for selected tenant
        const { data, error } = await supabase
          .from('users')
          .select('*, roles(*), tenants(*)')
          .eq('email', userEmail)
          .eq('tenant_id', selectedTenant)
          .single()
        
        console.log('Tenant-specific user record:', { data, error, selectedTenant })
        
        if (data) {
          setProfile(data)
          setCurrentTenantState(data.tenant_id)
        } else if (error) {
          console.error('Failed to fetch user for tenant:', error)
          // Clear invalid tenant selection
          localStorage.removeItem('selectedTenant')
        }
      }
    } catch (error) {
      console.error('Profile fetch error:', error)
    }
  }

  const signIn = async (email: string, password: string, selectedTenantId?: string) => {
    console.log('SignIn called with:', { email, selectedTenantId })
    
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    
    // Determine which tenant to use
    const tenantId = selectedTenantId || localStorage.getItem('selectedTenant')
    console.log('Using tenantId:', tenantId)
    
    if (!tenantId) {
      throw new Error('No tenant selected')
    }
    
    // Fetch user profile for the selected tenant
    const { data: userProfile, error: profileError } = await supabase
      .from('users')
      .select('*, roles(*), tenants!inner(id, tenant_code, tenant_name, subdomain)')
      .eq('email', email)
      .eq('tenant_id', tenantId)
      .single()
    
    console.log('User profile fetch result:', { userProfile, profileError })
    
    if (profileError || !userProfile) {
      await supabase.auth.signOut()
      throw new Error('You do not have access to this organization')
    }
    
    // Get subdomain from URL
    const hostname = window.location.hostname
    const subdomain = isLocalDevelopment(hostname) ? null : extractSubdomain(hostname)
    
    // If subdomain exists, validate it matches user's tenant
    if (subdomain && userProfile.tenants?.subdomain !== subdomain) {
      await supabase.auth.signOut()
      throw new Error('You do not have access to this organization')
    }
    
    // Set tenant session server-side
    const tenantResponse = await fetch('/api/auth/tenant', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tenantId })
    })
    
    console.log('Tenant session response:', tenantResponse.status)
    
    if (!tenantResponse.ok) {
      await supabase.auth.signOut()
      throw new Error('Failed to establish tenant session')
    }
    
    setProfile(userProfile)
    setCurrentTenantState(userProfile.tenant_id)
    localStorage.setItem('selectedTenant', userProfile.tenant_id)
    
    console.log('Login successful, tenant set to:', userProfile.tenant_id)
    
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
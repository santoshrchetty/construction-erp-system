'use client'
import { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { createClient } from '@/lib/supabase/client'
import { User, Session } from '@supabase/supabase-js'
import { useRouter } from 'next/navigation'

interface AuthContextType {
  user: User | null
  profile: any
  session: Session | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
  refreshSession: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [profile, setProfile] = useState<any>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const [mounted, setMounted] = useState(false)
  const router = useRouter()
  const supabase = createClient()

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (!mounted) return

    let retryCount = 0
    const maxRetries = 3
    let timeoutId: NodeJS.Timeout

    const getSession = async () => {
      try {
        const { data: { session }, error } = await supabase.auth.getSession()
        
        if (error) {
          console.error('Session error:', error)
          if (retryCount < maxRetries) {
            retryCount++
            setTimeout(getSession, 1000 * retryCount)
            return
          }
        }
        
        setSession(session)
        setUser(session?.user ?? null)
        
        if (session?.user) {
          await fetchUserProfile(session.user.id)
        } else {
          setProfile(null)
        }
      } catch (error) {
        console.error('Auth initialization error:', error)
      } finally {
        setLoading(false)
        if (timeoutId) clearTimeout(timeoutId)
      }
    }

    // Set timeout to prevent infinite loading
    timeoutId = setTimeout(() => {
      console.warn('Auth initialization timeout')
      setLoading(false)
    }, 5000)

    getSession()

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('Auth state change:', event)
        
        setSession(session)
        setUser(session?.user ?? null)
        
        if (session?.user) {
          await fetchUserProfile(session.user.id)
        } else {
          setProfile(null)
        }
        
        setLoading(false)
        
        // Handle auth events
        if (event === 'SIGNED_OUT') {
          // Ensure clean state on sign out
          setUser(null)
          setProfile(null)
          setSession(null)
          router.push('/login')
        } else if (event === 'SIGNED_IN' && session?.user) {
          router.push('/erp-modules')
        } else if (event === 'TOKEN_REFRESHED') {
          console.log('Token refreshed successfully')
        }
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [mounted, router])

  const fetchUserProfile = async (userId: string) => {
    try {
      const { data: profile, error } = await supabase
        .from('users')
        .select('*, roles(*)')
        .eq('id', userId)
        .single()
      
      if (error) {
        // Silently handle - profile is optional for tiles functionality
        return
      }
      
      setProfile(profile)
    } catch (error) {
      console.error('Profile fetch error:', error)
    }
  }

  const signIn = async (email: string, password: string) => {
    setLoading(true)
    try {
      const { data, error } = await supabase.auth.signInWithPassword({ 
        email, 
        password 
      })
      
      if (error) throw error
      
      // Session will be handled by onAuthStateChange
    } catch (error) {
      setLoading(false)
      throw error
    }
  }

  const signOut = async () => {
    try {
      // Call server-side logout endpoint
      const response = await fetch('/api/auth/logout', {
        method: 'POST',
        credentials: 'include'
      })
      
      if (!response.ok) throw new Error('Server logout failed')
      
      // Clear client storage
      localStorage.clear()
      sessionStorage.clear()
      
      // Clear local state
      setUser(null)
      setProfile(null)
      setSession(null)
      
      // Force redirect
      window.location.href = '/login'
      
    } catch (error) {
      console.error('Logout error:', error)
      // Fallback: force clear and redirect
      localStorage.clear()
      sessionStorage.clear()
      setUser(null)
      setProfile(null)
      setSession(null)
      window.location.href = '/login'
    }
  }

  const refreshSession = async () => {
    try {
      const { data, error } = await supabase.auth.refreshSession()
      if (error) throw error
      
      setSession(data.session)
      setUser(data.user)
    } catch (error) {
      console.error('Session refresh error:', error)
      throw error
    }
  }

  // Show loading spinner during SSR hydration
  if (!mounted) {
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
      signIn, 
      signOut, 
      refreshSession 
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
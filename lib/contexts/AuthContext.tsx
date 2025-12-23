'use client'

import { createContext, useContext, useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase-simple'


interface UserProfile {
  id: string
  email: string
  first_name: string | null
  last_name: string | null
  role_id: string | null
  employee_code: string | null
  department: string | null
  is_active: boolean
  roles: {
    id: string
    name: string
    description: string
    permissions: any
  } | null
}

interface AuthContextType {
  user: User | null
  profile: UserProfile | null
  loading: boolean
  signOut: () => Promise<void>
  hasPermission: (resource: string, action: string) => boolean
  getUserRole: () => string | null
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [profile, setProfile] = useState<UserProfile | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const getInitialSession = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession()

        if (session?.user) {
          setUser(session.user)
          await loadUserProfile(session.user.id)
        } else {
          setUser(null)
          setProfile(null)
          setLoading(false)
        }
      } catch (error) {
        console.error('Error getting initial session:', error)
        setUser(null)
        setProfile(null)
        setLoading(false)
      }
    }

    getInitialSession()

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event === 'SIGNED_OUT' || !session) {
          setUser(null)
          setProfile(null)
          setLoading(false)
        } else if (session?.user) {
          setUser(session.user)
          await loadUserProfile(session.user.id)
        }
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const loadUserProfile = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('users')
        .select(`
          id, email, first_name, last_name, role_id, employee_code, department, is_active,
          roles(id, name, description, permissions)
        `)
        .eq('id', userId)
        .single() as { data: any; error: any }

      if (error) {
        console.error('Error loading user profile:', error)
        setProfile(null)
      } else if (data) {
        // Transform the roles array to single role object
        const transformedData = {
          ...data,
          roles: Array.isArray(data.roles) ? data.roles[0] : data.roles
        }
        setProfile(transformedData)
      } else {
        setProfile(null)
      }
    } catch (error) {
      console.error('Error loading user profile:', error)
      setProfile(null)
    } finally {
      setLoading(false)
    }
  }

  const signOut = async () => {
    try {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
      
      // Clear state immediately
      setUser(null)
      setProfile(null)
      
      // Force redirect to login
      window.location.replace('/login')
    } catch (error) {
      console.error('Error signing out:', error)
      // Force redirect even on error
      window.location.replace('/login')
    }
  }

  const hasPermission = (resource: string, action: string): boolean => {
    if (!profile?.roles) return false
    
    const permissions = profile.roles.permissions
    if (permissions?.all) return true
    
    return permissions?.[resource]?.includes(action) || false
  }

  const getUserRole = (): string | null => {
    return profile?.roles?.name || null
  }

  const value = {
    user,
    profile,
    loading,
    signOut,
    hasPermission,
    getUserRole
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
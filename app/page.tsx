'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase-client'

export default function HomePage() {
  const router = useRouter()

  useEffect(() => {
    const checkAuth = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      
      if (session) {
        // User is logged in, get their role and redirect
        const { data: userData } = await supabase
          .from('users')
          .select('roles(name)')
          .eq('id', session.user.id)
          .single()

        const userRole = (userData?.roles as any)?.name
        
        if (!userRole) {
          router.push('/login')
          return
        }
        
        const roleRoutes = {
          'Admin': '/admin',
          'Manager': '/manager',
          'Procurement': '/procurement', 
          'Storekeeper': '/storekeeper',
          'Engineer': '/engineer',
          'Finance': '/finance',
          'HR': '/hr',
          'Employee': '/employee'
        }
        
        const redirectPath = roleRoutes[userRole as keyof typeof roleRoutes]
        
        if (!redirectPath) {
          router.push('/login')
          return
        }
        
        router.push(redirectPath)
      } else {
        // No session, redirect to login
        router.push('/login')
      }
    }

    checkAuth()
  }, [router])

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p className="text-gray-600">Loading...</p>
      </div>
    </div>
  )
}
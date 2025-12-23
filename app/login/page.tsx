'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase-client'
import { useAuth } from '@/lib/contexts/AuthContext'

const ROLE_ROUTES = {
  'Admin': '/admin',
  'Manager': '/manager',
  'Procurement': '/procurement',
  'Storekeeper': '/storekeeper',
  'Engineer': '/engineer',
  'Finance': '/finance',
  'HR': '/hr',
  'Employee': '/employee'
}



export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)
  
  const { user, profile, loading: authLoading } = useAuth()
  const router = useRouter()



  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      if (authError) throw authError
      
      // Get user role to determine redirect
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('roles(name)')
        .eq('id', authData.user.id)
        .single() as { data: { roles: { name: string } } | null; error: any }

      if (userError || !userData?.roles) {
        throw new Error('User role not found. Contact administrator.')
      }

      const userRole = (userData.roles as any).name
      const redirectPath = ROLE_ROUTES[userRole as keyof typeof ROLE_ROUTES]
      
      if (!redirectPath) {
        throw new Error(`Invalid role: ${userRole}. Access denied.`)
      }

      // Redirect to role-specific dashboard
      router.push(redirectPath)

    } catch (error: any) {
      setError(error.message)
      setLoading(false)
    }
  }

  // Show loading if auth is still loading
  if (authLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-xl shadow-lg p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Welcome Back</h1>
          <p className="text-gray-600">Sign in to your construction management account</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
              Email Address
            </label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Enter your email"
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
              Password
            </label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Enter your password"
            />
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
              {error}
            </div>
          )}





          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
          

        </form>

        <div className="mt-8 pt-6 border-t border-gray-200">
          <div className="text-center">
            <p className="text-sm text-gray-500 mb-4">Demo Accounts:</p>
            <div className="bg-gray-50 p-3 rounded text-sm space-y-2">
              <div>
                <strong>Manager:</strong> manager@nttdemo.com<br/>
                <strong>Password:</strong> demo123
              </div>
              <div className="border-t pt-2">
                <strong>Engineer:</strong> engineer@nttdemo.com<br/>
                <strong>Password:</strong> demo123
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
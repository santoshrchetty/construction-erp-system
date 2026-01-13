'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'

export default function AuthTest() {
  const [authData, setAuthData] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const { data: { session }, error } = await supabase.auth.getSession()
        
        setAuthData({
          session: !!session,
          user: session?.user?.email || null,
          error: error?.message || null,
          expires: session?.expires_at ? new Date(session.expires_at * 1000).toISOString() : null
        })
      } catch (err: any) {
        setAuthData({
          session: false,
          user: null,
          error: err.message,
          expires: null
        })
      } finally {
        setLoading(false)
      }
    }

    checkAuth()
  }, [])

  const handleLogin = async () => {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: 'admin@nttdemo.com',
        password: 'demo123'
      })
      
      if (error) {
        alert('Login error: ' + error.message)
      } else {
        alert('Login successful!')
        window.location.reload()
      }
    } catch (err: any) {
      alert('Login error: ' + err.message)
    }
  }

  if (loading) {
    return <div className="p-8">Loading...</div>
  }

  return (
    <div className="p-8 max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Authentication Test</h1>
      
      <div className="bg-gray-100 p-4 rounded mb-4">
        <h2 className="font-semibold mb-2">Current Auth Status:</h2>
        <pre className="text-sm">{JSON.stringify(authData, null, 2)}</pre>
      </div>
      
      <div className="space-x-4">
        <button 
          onClick={handleLogin}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Test Login
        </button>
        
        <button 
          onClick={() => window.location.href = '/erp-modules'}
          className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
        >
          Go to ERP Modules
        </button>
      </div>
    </div>
  )
}
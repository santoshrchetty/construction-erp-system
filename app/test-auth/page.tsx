'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase-client'

export default function TestAuth() {
  const [status, setStatus] = useState('Testing connection...')

  useEffect(() => {
    const testConnection = async () => {
      try {
        const { data, error } = await supabase.from('projects').select('count').limit(1)
        
        if (error) {
          setStatus(`Connection error: ${error.message}`)
        } else {
          setStatus('✅ Supabase connection successful')
        }
      } catch (err) {
        setStatus(`❌ Connection failed: ${err}`)
      }
    }

    testConnection()
  }, [])

  const createDemoUser = async () => {
    try {
      const { data, error } = await supabase.auth.signUp({
        email: 'admin@demo.com',
        password: 'demo123'
      })

      if (error) {
        setStatus(`❌ User creation failed: ${error.message}`)
      } else {
        setStatus('✅ Demo user created successfully')
      }
    } catch (err) {
      setStatus(`❌ Error: ${err}`)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-lg shadow p-6">
        <h1 className="text-xl font-bold mb-4">Supabase Test</h1>
        <p className="mb-4">{status}</p>
        <button 
          onClick={createDemoUser}
          className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700"
        >
          Create Demo User
        </button>
      </div>
    </div>
  )
}
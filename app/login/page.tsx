'use client'

import { useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '@/lib/contexts/AuthContext'
import { AlertCircle, Eye, EyeOff } from 'lucide-react'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [attempts, setAttempts] = useState(0)
  
  const { signIn } = useAuth()
  const router = useRouter()
  const searchParams = useSearchParams()
  const redirectTo = searchParams.get('redirectTo') || '/erp-modules'

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    
    // Rate limiting
    if (attempts >= 5) {
      setError('Too many failed attempts. Please wait before trying again.')
      return
    }
    
    setLoading(true)
    setError('')
    
    try {
      await signIn(email, password)
      // Navigation handled by AuthContext onAuthStateChange
    } catch (err: any) {
      console.error('Login error:', err)
      setAttempts(prev => prev + 1)
      
      // User-friendly error messages
      if (err.message?.includes('Invalid login credentials')) {
        setError('Invalid email or password. Please check your credentials.')
      } else if (err.message?.includes('Email not confirmed')) {
        setError('Please check your email and confirm your account before signing in.')
      } else if (err.message?.includes('Too many requests')) {
        setError('Too many login attempts. Please wait a few minutes before trying again.')
      } else {
        setError('Login failed. Please try again or contact support if the problem persists.')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#F7F7F7] via-white to-[#F0F8FF] flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-[0_8px_32px_rgba(0,0,0,0.12)] p-8 md:p-10">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-light text-[#32363A] mb-3 tracking-tight">Nexus ERP</h1>
          <div className="h-1 w-16 bg-gradient-to-r from-[#0A6ED1] to-[#0080FF] mx-auto mb-4 rounded-full"></div>
          <p className="text-[#6A6D70] font-light">Sign in to continue</p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg flex items-start">
            <AlertCircle className="w-5 h-5 mr-2 mt-0.5 flex-shrink-0" />
            <span className="text-sm">{error}</span>
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-6">
          <div>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
              placeholder="Enter your email"
              disabled={loading}
              aria-label="Email Address"
            />
          </div>

          <div>
            <div className="relative">
              <input
                id="password"
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                autoComplete="current-password"
                className="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
                placeholder="Enter your password"
                disabled={loading}
                aria-label="Password"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                disabled={loading}
              >
                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>

          <button
            type="submit"
            disabled={loading || attempts >= 5}
            className="w-full bg-[#0A6ED1] text-white py-3 px-4 rounded-lg font-medium hover:bg-[#0080FF] focus:ring-2 focus:ring-[#0A6ED1] focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-[0_2px_8px_rgba(10,110,209,0.3)] hover:shadow-[0_4px_12px_rgba(10,110,209,0.4)]"
          >
            {loading ? (
              <div className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                Signing in...
              </div>
            ) : (
              'Sign In'
            )}
          </button>
        </form>
        
        {attempts >= 3 && attempts < 5 && (
          <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 text-yellow-700 rounded-lg text-sm">
            Warning: {5 - attempts} attempts remaining before temporary lockout.
          </div>
        )}
      </div>
    </div>
  )
}
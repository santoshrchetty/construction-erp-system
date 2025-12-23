'use client'

import { useState } from 'react'
import { useAuth } from '@/lib/contexts/AuthContext'

export default function UserProfile() {
  const { user, profile, signOut, getUserRole } = useAuth()
  const [showDropdown, setShowDropdown] = useState(false)

  if (!user || !profile) return null

  const initials = `${profile.first_name?.[0] || ''}${profile.last_name?.[0] || ''}`.toUpperCase() || user.email[0].toUpperCase()

  return (
    <div className="relative">
      <button
        onClick={() => setShowDropdown(!showDropdown)}
        className="flex items-center space-x-3 p-2 rounded-lg hover:bg-gray-100"
      >
        <div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white text-sm font-medium">
          {initials}
        </div>
        <div className="text-left">
          <div className="text-sm font-medium text-gray-900">
            {profile.first_name} {profile.last_name}
          </div>
          <div className="text-xs text-gray-500">{getUserRole()}</div>
        </div>
      </button>

      {showDropdown && (
        <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border z-50">
          <div className="p-3 border-b">
            <div className="text-sm font-medium text-gray-900">
              {profile.first_name} {profile.last_name}
            </div>
            <div className="text-xs text-gray-500">{user.email}</div>
            <div className="text-xs text-blue-600 mt-1">{getUserRole()}</div>
          </div>
          <div className="p-1">
            <button
              onClick={() => {
                signOut()
                setShowDropdown(false)
              }}
              className="w-full text-left px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded"
            >
              Sign Out
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
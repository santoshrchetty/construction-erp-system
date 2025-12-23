'use client'

import { useAuth } from '@/lib/contexts/AuthContext'
import { useEffect, useState } from 'react'

export default function AuthFlowDebugger() {
  const { user, profile, loading, getUserRole } = useAuth()
  const [logs, setLogs] = useState<string[]>([])

  const addLog = (message: string) => {
    const timestamp = new Date().toLocaleTimeString()
    setLogs(prev => [...prev, `[${timestamp}] ${message}`])
  }

  useEffect(() => {
    addLog(`🔄 Auth state changed - Loading: ${loading}`)
    
    if (loading) {
      addLog('⏳ Waiting for authentication...')
    } else {
      if (user) {
        addLog(`✅ User authenticated: ${user.email}`)
        addLog(`📧 User ID: ${user.id}`)
        
        if (profile) {
          addLog(`👤 Profile loaded: ${profile.first_name} ${profile.last_name}`)
          addLog(`🏷️ Role: ${getUserRole() || 'No role'}`)
          addLog(`🏢 Department: ${profile.department || 'No department'}`)
          addLog(`📋 Employee Code: ${profile.employee_code || 'No code'}`)
          addLog(`🔑 Permissions: ${JSON.stringify(profile.roles?.permissions || {})}`)
        } else {
          addLog('❌ Profile not loaded')
        }
      } else {
        addLog('❌ User not authenticated')
      }
    }
  }, [user, profile, loading, getUserRole])

  return (
    <div className="fixed bottom-4 right-4 w-96 max-h-96 bg-white border border-gray-300 rounded-lg shadow-lg overflow-hidden">
      <div className="bg-gray-100 px-4 py-2 border-b">
        <h3 className="font-medium text-sm">🔍 Auth Flow Debugger</h3>
        <button 
          onClick={() => setLogs([])}
          className="text-xs text-gray-500 hover:text-gray-700"
        >
          Clear logs
        </button>
      </div>
      
      <div className="p-4 max-h-80 overflow-y-auto">
        <div className="space-y-2">
          <div className="text-xs">
            <strong>Current State:</strong>
            <div className="ml-2">
              Loading: {loading ? '🟡 Yes' : '🟢 No'}<br/>
              User: {user ? '🟢 Yes' : '🔴 No'}<br/>
              Profile: {profile ? '🟢 Yes' : '🔴 No'}<br/>
              Role: {getUserRole() || '🔴 None'}
            </div>
          </div>
          
          <div className="border-t pt-2">
            <strong className="text-xs">Logs:</strong>
            <div className="mt-1 space-y-1 text-xs font-mono">
              {logs.map((log, index) => (
                <div key={index} className="text-gray-700">
                  {log}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
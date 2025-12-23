'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase-client'
import TimesheetCostSummary from '@/components/dashboards/TimesheetCostSummary'

export default function HRDashboard() {
  const [activeTab, setActiveTab] = useState('overview')
  const [selectedProjectId, setSelectedProjectId] = useState<string>('')
  const [stats, setStats] = useState({
    totalEmployees: 0,
    pendingTimesheets: 0,
    activeProjects: 0,
    totalHours: 0
  })

  const tabs = [
    { key: 'overview', label: 'Overview', icon: '📊' },
    { key: 'employees', label: 'Employees', icon: '👥' },
    { key: 'timesheets', label: 'Timesheets', icon: '⏰' },
    { key: 'roles', label: 'Roles & Permissions', icon: '🔐' }
  ]

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const { data: users } = await supabase.from('users').select('*').eq('is_active', true)
      const { data: timesheets } = await supabase.from('daily_timesheets').select('*').eq('status', 'submitted')
      const { data: projects } = await supabase.from('projects').select('*').eq('status', 'active')
      
      setStats({
        totalEmployees: users?.length || 0,
        pendingTimesheets: timesheets?.length || 0,
        activeProjects: projects?.length || 0,
        totalHours: timesheets?.reduce((sum, ts) => sum + (ts.hours || 0), 0) || 0
      })
    } catch (error) {
      console.error('Error fetching stats:', error)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">HR Dashboard</h1>
              <p className="text-gray-600">Employee management, timesheet approvals, and role assignments</p>
            </div>
          </div>
        </div>
      </div>

      <nav className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4">
          <div className="flex space-x-6">
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`py-3 px-2 border-b-2 font-medium text-sm flex items-center space-x-2 ${
                  activeTab === tab.key
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <span>{tab.icon}</span>
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'overview' && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <span className="text-2xl">👥</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.totalEmployees}</h3>
                  <p className="text-sm text-gray-500">Total Employees</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-yellow-100 rounded-lg">
                  <span className="text-2xl">⏰</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.pendingTimesheets}</h3>
                  <p className="text-sm text-gray-500">Pending Timesheets</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-green-100 rounded-lg">
                  <span className="text-2xl">🏗️</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.activeProjects}</h3>
                  <p className="text-sm text-gray-500">Active Projects</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-purple-100 rounded-lg">
                  <span className="text-2xl">📊</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.totalHours.toLocaleString()}</h3>
                  <p className="text-sm text-gray-500">Total Hours This Month</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'employees' && (
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-bold">Employee Management</h2>
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  Add Employee
                </button>
              </div>
            </div>
            <div className="p-6">
              <p className="text-gray-500">Employee management interface coming soon...</p>
            </div>
          </div>
        )}

        {activeTab === 'timesheets' && (
          <TimesheetCostSummary projectId={selectedProjectId || 'default'} />
        )}

        {activeTab === 'roles' && (
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-bold">Roles & Permissions</h2>
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  Manage Roles
                </button>
              </div>
            </div>
            <div className="p-6">
              <p className="text-gray-500">Role management interface coming soon...</p>
            </div>
          </div>
        )}
      </main>
    </div>
  )
}
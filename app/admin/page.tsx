'use client'

import { useState, useEffect } from 'react'
import ProtectedRoute from '../../components/auth/ProtectedRoute'
import { useAuth } from '@/lib/contexts/AuthContext'
import { supabase } from '@/lib/supabase'
import { createUser, getUsers, getRoles, updateUser } from '@/app/actions/users/actions'
import BulkUserUpload from '@/components/BulkUserUpload'

interface DashboardStats {
  totalUsers: number
  activeUsers: number
  totalProjects: number
  activeProjects: number
  totalTasks: number
  completedTasks: number
}

interface User {
  id: string
  email: string
  first_name: string | null
  last_name: string | null
  role_id: string | null
  department: string | null
  is_active: boolean
  roles: { name: string } | null
}

interface Role {
  id: string
  name: string
}

export default function AdminDashboard() {
  const { user, profile, signOut } = useAuth()
  const [activeTab, setActiveTab] = useState('overview')
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    activeUsers: 0,
    totalProjects: 0,
    activeProjects: 0,
    totalTasks: 0,
    completedTasks: 0
  })
  const [users, setUsers] = useState<User[]>([])
  const [roles, setRoles] = useState<Role[]>([])
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [showEditForm, setShowEditForm] = useState(false)
  const [editingUser, setEditingUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [isSubmitting, setIsSubmitting] = useState(false)

  const tabs = [
    { key: 'overview', label: 'System Overview', icon: '📊' },
    { key: 'users', label: 'User Management', icon: '👥' },
    { key: 'bulk', label: 'Bulk Upload', icon: '📤' },
    { key: 'projects', label: 'Project Overview', icon: '🏗️' },
    { key: 'settings', label: 'System Settings', icon: '⚙️' }
  ]

  useEffect(() => {
    loadDashboardData()
  }, [])

  const loadDashboardData = async () => {
    try {
      const [usersResult, projectsResult, tasksResult, rolesResult] = await Promise.all([
        getUsers(),
        supabase.from('projects').select('id, status'),
        supabase.from('tasks').select('id, status'),
        getRoles()
      ])

      const usersData = usersResult.success ? usersResult.data : []
      const projects = projectsResult.data || []
      const tasks = tasksResult.data || []
      const rolesData = rolesResult.success ? rolesResult.data : []

      setUsers(usersData)
      setRoles(rolesData)
      
      setStats({
        totalUsers: usersData.length,
        activeUsers: usersData.filter(u => u.is_active).length,
        totalProjects: projects.length,
        activeProjects: projects.filter(p => p.status === 'active').length,
        totalTasks: tasks.length,
        completedTasks: tasks.filter(t => t.status === 'completed').length
      })
    } catch (error) {
      console.error('Error loading dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCreateUser = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (isSubmitting) return
    setIsSubmitting(true)
    const formData = new FormData(e.currentTarget)
    const result = await createUser(formData)
    
    if (result.success) {
      setShowCreateForm(false)
      loadDashboardData()
    } else {
      alert(result.error)
    }
    setIsSubmitting(false)
  }

  const handleEditUser = (user: User) => {
    setEditingUser(user)
    setShowEditForm(true)
  }

  const handleUpdateUser = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!editingUser || isSubmitting) return
    setIsSubmitting(true)
    
    const formData = new FormData(e.currentTarget)
    const result = await updateUser(editingUser.id, formData)
    
    if (result.success) {
      setShowEditForm(false)
      setEditingUser(null)
      loadDashboardData()
    } else {
      alert(result.error)
    }
    setIsSubmitting(false)
  }

  const handleLogout = async () => {
    await signOut()
  }

  const StatCard = ({ title, value, subtitle, color }: {
    title: string
    value: number
    subtitle: string
    color: string
  }) => (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-center">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className={`text-2xl font-bold ${color}`}>{value}</p>
          <p className="text-xs text-gray-500">{subtitle}</p>
        </div>
      </div>
    </div>
  )

  return (
    <ProtectedRoute allowedRoles={['Admin']}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow">
          <div className="px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
                <p className="text-gray-600">System administration and management</p>
              </div>
              <div className="flex items-center space-x-4">
                <span className="bg-red-100 text-red-800 px-3 py-1 rounded-full text-sm font-medium">
                  {profile?.roles?.name || 'Admin'}
                </span>
                <button
                  onClick={handleLogout}
                  className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="bg-white border-b">
          <div className="px-4">
            <div className="flex space-x-6">
              {tabs.map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key)}
                  className={`py-3 px-2 border-b-2 font-medium text-sm flex items-center space-x-2 ${
                    activeTab === tab.key
                      ? 'border-red-500 text-red-600'
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

        {/* Content */}
        <main className="p-6">
          {activeTab === 'overview' && (
            <div className="space-y-6">
              {/* Stats Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <StatCard
                  title="Total Users"
                  value={stats.totalUsers}
                  subtitle={`${stats.activeUsers} active`}
                  color="text-blue-600"
                />
                <StatCard
                  title="Total Projects"
                  value={stats.totalProjects}
                  subtitle={`${stats.activeProjects} active`}
                  color="text-green-600"
                />
                <StatCard
                  title="Total Tasks"
                  value={stats.totalTasks}
                  subtitle={`${stats.completedTasks} completed`}
                  color="text-purple-600"
                />
                <StatCard
                  title="System Health"
                  value={100}
                  subtitle="All systems operational"
                  color="text-emerald-600"
                />
              </div>

              {/* Recent Activity */}
              <div className="bg-white rounded-lg shadow">
                <div className="p-6 border-b">
                  <h3 className="text-lg font-medium">System Overview</h3>
                </div>
                <div className="p-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <h4 className="font-medium mb-3">User Activity</h4>
                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span>Active Users</span>
                          <span className="font-medium">{stats.activeUsers}/{stats.totalUsers}</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-blue-600 h-2 rounded-full" 
                            style={{ width: `${stats.totalUsers > 0 ? (stats.activeUsers / stats.totalUsers) * 100 : 0}%` }}
                          ></div>
                        </div>
                      </div>
                    </div>
                    <div>
                      <h4 className="font-medium mb-3">Project Progress</h4>
                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span>Active Projects</span>
                          <span className="font-medium">{stats.activeProjects}/{stats.totalProjects}</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-green-600 h-2 rounded-full" 
                            style={{ width: `${stats.totalProjects > 0 ? (stats.activeProjects / stats.totalProjects) * 100 : 0}%` }}
                          ></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'users' && (
            <div className="space-y-6">
              <div className="flex justify-between items-center">
                <h2 className="text-2xl font-bold">User Management</h2>
                <button
                  onClick={() => setShowCreateForm(true)}
                  className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                >
                  Add User
                </button>
              </div>
              
              <div className="bg-white rounded-lg shadow overflow-hidden">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Department</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {users.map((user) => (
                      <tr key={user.id}>
                        <td className="px-4 py-3">
                          <div>
                            <div className="font-medium">{user.first_name} {user.last_name}</div>
                            <div className="text-sm text-gray-500">{user.email}</div>
                          </div>
                        </td>
                        <td className="px-4 py-3">
                          <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                            {user.roles?.name || 'No Role'}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm">{user.department || '-'}</td>
                        <td className="px-4 py-3">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            user.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                            {user.is_active ? 'Active' : 'Inactive'}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <button
                            onClick={() => handleEditUser(user)}
                            className="text-blue-600 hover:text-blue-800 text-sm mr-3"
                          >
                            Edit
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              
              {showEditForm && editingUser && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                  <div className="bg-white rounded-lg p-6 w-full max-w-md">
                    <h3 className="text-lg font-bold mb-4">Edit User</h3>
                    <form onSubmit={handleUpdateUser} className="space-y-4">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium mb-1">First Name</label>
                          <input
                            type="text"
                            name="first_name"
                            defaultValue={editingUser.first_name || ''}
                            className="w-full border rounded px-3 py-2"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium mb-1">Last Name</label>
                          <input
                            type="text"
                            name="last_name"
                            defaultValue={editingUser.last_name || ''}
                            className="w-full border rounded px-3 py-2"
                          />
                        </div>
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-1">Department</label>
                        <input
                          type="text"
                          name="department"
                          defaultValue={editingUser.department || ''}
                          className="w-full border rounded px-3 py-2"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-1">Role</label>
                        <select
                          name="role_id"
                          defaultValue={editingUser.role_id || ''}
                          className="w-full border rounded px-3 py-2"
                        >
                          <option value="">Select Role</option>
                          {roles.map((role) => (
                            <option key={role.id} value={role.id}>
                              {role.name}
                            </option>
                          ))}
                        </select>
                      </div>
                      <div>
                        <label className="flex items-center">
                          <input
                            type="checkbox"
                            name="is_active"
                            defaultChecked={editingUser.is_active}
                            value="true"
                            className="mr-2"
                          />
                          <span className="text-sm">Active User</span>
                        </label>
                      </div>
                      <div className="flex justify-end space-x-3">
                        <button
                          type="button"
                          onClick={() => { setShowEditForm(false); setEditingUser(null) }}
                          className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                        >
                          Cancel
                        </button>
                        <button
                          type="submit"
                          disabled={isSubmitting}
                          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
                        >
                          {isSubmitting ? 'Updating...' : 'Update User'}
                        </button>
                      </div>
                    </form>
                  </div>
                </div>
              )}

              {showCreateForm && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                  <div className="bg-white rounded-lg p-6 w-full max-w-md">
                    <h3 className="text-lg font-bold mb-4">Create New User</h3>
                    <form onSubmit={handleCreateUser} className="space-y-4">
                      <div>
                        <label className="block text-sm font-medium mb-1">Email</label>
                        <input
                          type="email"
                          name="email"
                          required
                          className="w-full border rounded px-3 py-2"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-1">Password</label>
                        <input
                          type="password"
                          name="password"
                          required
                          className="w-full border rounded px-3 py-2"
                        />
                      </div>
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium mb-1">First Name</label>
                          <input
                            type="text"
                            name="first_name"
                            className="w-full border rounded px-3 py-2"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium mb-1">Last Name</label>
                          <input
                            type="text"
                            name="last_name"
                            className="w-full border rounded px-3 py-2"
                          />
                        </div>
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-1">Role</label>
                        <select
                          name="role_id"
                          required
                          className="w-full border rounded px-3 py-2"
                        >
                          <option value="">Select Role ({roles.length} available)</option>
                          {roles.map((role) => (
                            <option key={role.id} value={role.id}>
                              {role.name}
                            </option>
                          ))}
                        </select>
                      </div>
                      <div className="flex justify-end space-x-3">
                        <button
                          type="button"
                          onClick={() => setShowCreateForm(false)}
                          className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                        >
                          Cancel
                        </button>
                        <button
                          type="submit"
                          disabled={isSubmitting}
                          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
                        >
                          {isSubmitting ? 'Creating...' : 'Create User'}
                        </button>
                      </div>
                    </form>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'bulk' && (
            <BulkUserUpload onComplete={loadDashboardData} />
          )}

          {activeTab === 'projects' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium mb-4">Master Data Management</h3>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                <button onClick={() => window.location.href = '/materials'} className="p-4 border rounded-lg hover:bg-gray-50 text-center">
                  <div className="text-2xl mb-2">🧱</div>
                  <div className="font-medium">Material Master</div>
                  <div className="text-sm text-gray-500">Manage materials & specifications</div>
                </button>
                <button onClick={() => window.location.href = '/vendors'} className="p-4 border rounded-lg hover:bg-gray-50 text-center">
                  <div className="text-2xl mb-2">🏢</div>
                  <div className="font-medium">Vendor Master</div>
                  <div className="text-sm text-gray-500">Manage suppliers & contractors</div>
                </button>
                <button onClick={() => window.location.href = '/projects'} className="p-4 border rounded-lg hover:bg-gray-50 text-center">
                  <div className="text-2xl mb-2">🏗️</div>
                  <div className="font-medium">Project Master</div>
                  <div className="text-sm text-gray-500">Manage project details</div>
                </button>
                <button onClick={() => window.location.href = '/inventory'} className="p-4 border rounded-lg hover:bg-gray-50 text-center">
                  <div className="text-2xl mb-2">📦</div>
                  <div className="font-medium">Inventory</div>
                  <div className="text-sm text-gray-500">Stock management & tracking</div>
                </button>
                <button onClick={() => window.location.href = '/purchase-orders'} className="p-4 border rounded-lg hover:bg-gray-50 text-center">
                  <div className="text-2xl mb-2">📋</div>
                  <div className="font-medium">Purchase Orders</div>
                  <div className="text-sm text-gray-500">PO creation & management</div>
                </button>
                <button onClick={() => window.location.href = '/sap-config'} className="p-4 border rounded-lg hover:bg-gray-50 text-center">
                  <div className="text-2xl mb-2">⚙️</div>
                  <div className="font-medium">SAP Configuration</div>
                  <div className="text-sm text-gray-500">Organizational structure setup</div>
                </button>
                <button onClick={() => window.location.href = '/erp-config'} className="p-4 border rounded-lg hover:bg-gray-50 text-center">
                  <div className="text-2xl mb-2">🏭</div>
                  <div className="font-medium">ERP Configuration</div>
                  <div className="text-sm text-gray-500">Material Types, Account Determination</div>
                </button>
              </div>
            </div>
          )}

          {activeTab === 'settings' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium mb-4">System Settings</h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    System Maintenance Mode
                  </label>
                  <div className="flex items-center">
                    <input type="checkbox" className="mr-2" />
                    <span className="text-sm text-gray-600">Enable maintenance mode</span>
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Default Project Settings
                  </label>
                  <select className="border rounded px-3 py-2">
                    <option>Standard Working Days (Mon-Fri)</option>
                    <option>6-Day Work Week</option>
                    <option>Custom Schedule</option>
                  </select>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>
    </ProtectedRoute>
  )
}
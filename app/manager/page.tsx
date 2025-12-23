'use client'

import { useState, useEffect } from 'react'
import ProtectedRoute from '../../components/auth/ProtectedRoute'
import { useAuth } from '@/lib/contexts/AuthContext'
import { supabase } from '@/lib/supabase-client'

interface ProjectSummary {
  id: string
  name: string
  code: string
  status: string
  budget: number
  progress: number
  team_size: number
  risk_level: 'low' | 'medium' | 'high'
}

interface ManagerStats {
  totalProjects: number
  activeProjects: number
  totalBudget: number
  teamMembers: number
  completedTasks: number
  pendingApprovals: number
}

export default function ManagerDashboard() {
  const { user, profile, signOut } = useAuth()
  const [activeTab, setActiveTab] = useState('overview')
  const [stats, setStats] = useState<ManagerStats>({
    totalProjects: 0,
    activeProjects: 0,
    totalBudget: 0,
    teamMembers: 0,
    completedTasks: 0,
    pendingApprovals: 0
  })
  const [projects, setProjects] = useState<ProjectSummary[]>([])
  const [loading, setLoading] = useState(true)

  const tabs = [
    { key: 'overview', label: 'Portfolio Overview', icon: '📊' },
    { key: 'projects', label: 'Project Management', icon: '🏗️' },
    { key: 'team', label: 'Team Management', icon: '👥' },
    { key: 'approvals', label: 'Approvals', icon: '✅' }
  ]

  useEffect(() => {
    loadManagerData()
  }, [])

  const loadManagerData = async () => {
    try {
      const [projectsResult, tasksResult, usersResult] = await Promise.all([
        supabase.from('projects').select('id, name, code, status, budget'),
        supabase.from('tasks').select('id, status'),
        supabase.from('users').select('id, is_active')
      ])

      const projectsData = projectsResult.data || []
      const tasksData = tasksResult.data || []
      const usersData = usersResult.data || []

      // Calculate stats
      setStats({
        totalProjects: projectsData.length,
        activeProjects: projectsData.filter(p => p.status === 'active').length,
        totalBudget: projectsData.reduce((sum, p) => sum + (p.budget || 0), 0),
        teamMembers: usersData.filter(u => u.is_active).length,
        completedTasks: tasksData.filter(t => t.status === 'completed').length,
        pendingApprovals: Math.floor(Math.random() * 10) + 1 // Mock data
      })

      // Transform projects with mock data for demo
      const projectSummaries: ProjectSummary[] = projectsData.map(p => ({
        id: p.id,
        name: p.name,
        code: p.code,
        status: p.status,
        budget: p.budget || 0,
        progress: Math.floor(Math.random() * 100),
        team_size: Math.floor(Math.random() * 15) + 5,
        risk_level: ['low', 'medium', 'high'][Math.floor(Math.random() * 3)] as 'low' | 'medium' | 'high'
      }))

      setProjects(projectSummaries)
    } catch (error) {
      console.error('Error loading manager data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = async () => {
    await signOut()
  }

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case 'low': return 'bg-green-100 text-green-800'
      case 'medium': return 'bg-yellow-100 text-yellow-800'
      case 'high': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800'
      case 'planning': return 'bg-blue-100 text-blue-800'
      case 'on_hold': return 'bg-yellow-100 text-yellow-800'
      case 'completed': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const StatCard = ({ title, value, subtitle, color, icon }: {
    title: string
    value: number | string
    subtitle: string
    color: string
    icon: string
  }) => (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-center">
        <div className="flex-1">
          <div className="flex items-center mb-2">
            <span className="text-2xl mr-2">{icon}</span>
            <p className="text-sm font-medium text-gray-600">{title}</p>
          </div>
          <p className={`text-2xl font-bold ${color}`}>{value}</p>
          <p className="text-xs text-gray-500">{subtitle}</p>
        </div>
      </div>
    </div>
  )

  return (
    <ProtectedRoute allowedRoles={['Manager']}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow">
          <div className="px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Manager Dashboard</h1>
                <p className="text-gray-600">Project portfolio and team management</p>
              </div>
              <div className="flex items-center space-x-4">
                <span className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium">
                  {profile?.roles?.name || 'Manager'}
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

        {/* Content */}
        <main className="p-6">
          {activeTab === 'overview' && (
            <div className="space-y-6">
              {/* Stats Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <StatCard
                  title="Total Projects"
                  value={stats.totalProjects}
                  subtitle={`${stats.activeProjects} active`}
                  color="text-blue-600"
                  icon="🏗️"
                />
                <StatCard
                  title="Portfolio Budget"
                  value={`$${(stats.totalBudget / 1000000).toFixed(1)}M`}
                  subtitle="Total allocated budget"
                  color="text-green-600"
                  icon="💰"
                />
                <StatCard
                  title="Team Members"
                  value={stats.teamMembers}
                  subtitle="Active team members"
                  color="text-purple-600"
                  icon="👥"
                />
                <StatCard
                  title="Completed Tasks"
                  value={stats.completedTasks}
                  subtitle="This month"
                  color="text-emerald-600"
                  icon="✅"
                />
                <StatCard
                  title="Pending Approvals"
                  value={stats.pendingApprovals}
                  subtitle="Require your attention"
                  color="text-orange-600"
                  icon="⏳"
                />
                <StatCard
                  title="Portfolio Health"
                  value="Good"
                  subtitle="Overall status"
                  color="text-green-600"
                  icon="📈"
                />
              </div>

              {/* Quick Actions */}
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-medium mb-4">Quick Actions</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <button className="p-4 border rounded-lg hover:bg-gray-50 text-left">
                    <div className="text-2xl mb-2">📋</div>
                    <div className="font-medium">Review Project Status</div>
                    <div className="text-sm text-gray-600">Check project progress</div>
                  </button>
                  <button className="p-4 border rounded-lg hover:bg-gray-50 text-left">
                    <div className="text-2xl mb-2">👥</div>
                    <div className="font-medium">Manage Team</div>
                    <div className="text-sm text-gray-600">Assign resources</div>
                  </button>
                  <button className="p-4 border rounded-lg hover:bg-gray-50 text-left">
                    <div className="text-2xl mb-2">📊</div>
                    <div className="font-medium">View Reports</div>
                    <div className="text-sm text-gray-600">Performance analytics</div>
                  </button>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'projects' && (
            <div className="space-y-6">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-medium">Project Portfolio</h3>
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  New Project
                </button>
              </div>
              <div className="bg-white rounded-lg shadow overflow-hidden">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Project</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Progress</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Budget</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Team</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Risk</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {projects.map((project) => (
                      <tr key={project.id} className="hover:bg-gray-50">
                        <td className="px-4 py-3">
                          <div>
                            <div className="font-medium text-sm">{project.name}</div>
                            <div className="text-xs text-gray-500">{project.code}</div>
                          </div>
                        </td>
                        <td className="px-4 py-3">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(project.status)}`}>
                            {project.status}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <div className="flex items-center space-x-2">
                            <div className="w-16 h-2 bg-gray-200 rounded-full overflow-hidden">
                              <div 
                                className="h-full bg-blue-500 transition-all duration-300"
                                style={{ width: `${project.progress}%` }}
                              ></div>
                            </div>
                            <span className="text-xs text-gray-500">{project.progress}%</span>
                          </div>
                        </td>
                        <td className="px-4 py-3 text-sm font-medium">${project.budget.toLocaleString()}</td>
                        <td className="px-4 py-3 text-sm">{project.team_size} members</td>
                        <td className="px-4 py-3">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getRiskColor(project.risk_level)}`}>
                            {project.risk_level}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'team' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium mb-4">Team Management</h3>
              <p className="text-gray-600">Team management features will be integrated here.</p>
            </div>
          )}

          {activeTab === 'approvals' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium mb-4">Pending Approvals</h3>
              <div className="space-y-4">
                <div className="border rounded-lg p-4">
                  <div className="flex justify-between items-center">
                    <div>
                      <h4 className="font-medium">Purchase Order #PO-2024-001</h4>
                      <p className="text-sm text-gray-600">Construction materials - $25,000</p>
                    </div>
                    <div className="flex space-x-2">
                      <button className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700">
                        Approve
                      </button>
                      <button className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700">
                        Reject
                      </button>
                    </div>
                  </div>
                </div>
                <div className="border rounded-lg p-4">
                  <div className="flex justify-between items-center">
                    <div>
                      <h4 className="font-medium">Timesheet Approval</h4>
                      <p className="text-sm text-gray-600">John Doe - Week ending Dec 15</p>
                    </div>
                    <div className="flex space-x-2">
                      <button className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700">
                        Approve
                      </button>
                      <button className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700">
                        Reject
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>
    </ProtectedRoute>
  )
}
/*
'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import * as Icons from 'lucide-react'

interface ProjectDashboardProps {
  onProjectSelect?: (projectId: string, projectName: string) => void
  onNewProject?: () => void
}

interface ProjectStats {
  total: number
  active: number
  completed: number
  planning: number
  totalBudget: number
}

export default function ProjectDashboard({ onProjectSelect, onNewProject }: ProjectDashboardProps) {
  const [stats, setStats] = useState<ProjectStats>({
    total: 0,
    active: 0,
    completed: 0,
    planning: 0,
    totalBudget: 0
  })
  const [recentProjects, setRecentProjects] = useState<any[]>([])

  useEffect(() => {
    fetchStats()
    fetchRecentProjects()
  }, [])

  const fetchStats = async () => {
    const { data: projects } = await supabase
      .from('projects')
      .select('status, budget')

    if (projects) {
      const stats = projects.reduce((acc, project) => {
        acc.total++
        acc.totalBudget += project.budget || 0
        if (project.status === 'active') acc.active++
        if (project.status === 'completed') acc.completed++
        if (project.status === 'planning') acc.planning++
        return acc
      }, { total: 0, active: 0, completed: 0, planning: 0, totalBudget: 0 })
      
      setStats(stats)
    }
  }

  const fetchRecentProjects = async () => {
    const { data } = await supabase
      .from('projects')
      .select('id, name, code, status, budget, start_date')
      .order('created_at', { ascending: false })
      .limit(5)

    if (data) setRecentProjects(data)
  }

  const StatCard = ({ title, value, subtitle, icon: Icon, color }: any) => (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-center">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className={`text-2xl font-bold ${color}`}>{value}</p>
          <p className="text-xs text-gray-500">{subtitle}</p>
        </div>
        <Icon className={`w-8 h-8 ${color}`} />
      </div>
    </div>
  )

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Projects Dashboard</h1>
          <p className="text-gray-600">Overview of all construction projects</p>
        </div>
        <div className="flex space-x-3">
          <button
            onClick={() => window.location.href = '/projects'}
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Manage Projects
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard
          title="Total Projects"
          value={stats.total}
          subtitle="All projects"
          icon={Icons.Building}
          color="text-blue-600"
        />
        <StatCard
          title="Active Projects"
          value={stats.active}
          subtitle="Currently running"
          icon={Icons.Play}
          color="text-green-600"
        />
        <StatCard
          title="Completed"
          value={stats.completed}
          subtitle="Successfully finished"
          icon={Icons.CheckCircle}
          color="text-emerald-600"
        />
        <StatCard
          title="Total Budget"
          value={`$${stats.totalBudget.toLocaleString()}`}
          subtitle="Combined project value"
          icon={Icons.DollarSign}
          color="text-purple-600"
        />
      </div>

      {/* Recent Projects */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b">
          <h3 className="text-lg font-medium">Recent Projects</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Budget</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Start Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {recentProjects.map((project) => (
                <tr key={project.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-mono">{project.code}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">{project.name}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 text-xs rounded-full ${
                      project.status === 'active' ? 'bg-green-100 text-green-800' :
                      project.status === 'completed' ? 'bg-blue-100 text-blue-800' :
                      project.status === 'planning' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {project.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">${project.budget?.toLocaleString()}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">{new Date(project.start_date).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
*/
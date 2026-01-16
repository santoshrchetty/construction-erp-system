'use client'

import React, { useState, useEffect } from 'react'
import { Building, DollarSign, TrendingUp, Activity, RefreshCw, Play, CheckCircle } from 'lucide-react'
import { supabase } from '@/lib/supabase/client'

interface ProjectSummary {
  totalProjects: number
  totalCosts: number
  totalRevenue: number
  netProfit: number
  profitMargin: number
}

interface Project {
  project_code: string
  total_costs: number
  total_revenue: number
  net_amount: number
  transaction_count: number
  last_posting_date: string
  budget?: number
  wbs_details?: WBSDetail[]
  expanded?: boolean
}

interface WBSDetail {
  wbs_element: string
  wbs_description?: string
  total_debits: number
  total_credits: number
  net_amount: number
  transaction_count: number
  last_posting_date: string
}

interface ProjectStats {
  total: number
  active: number
  completed: number
  planning: number
  totalBudget: number
}

interface RecentProject {
  id: string
  name: string
  code: string
  status: string
  budget: number
  start_date: string
}

export function ProjectsOverviewDashboard() {
  const [summary, setSummary] = useState<ProjectSummary>({
    totalProjects: 0,
    totalCosts: 0,
    totalRevenue: 0,
    netProfit: 0,
    profitMargin: 0
  })
  const [projects, setProjects] = useState<Project[]>([])
  const [stats, setStats] = useState<ProjectStats>({
    total: 0,
    active: 0,
    completed: 0,
    planning: 0,
    totalBudget: 0
  })
  const [recentProjects, setRecentProjects] = useState<RecentProject[]>([])
  const [categories, setCategories] = useState<string[]>([])
  const [loading, setLoading] = useState(true)

  const loadDashboardData = async () => {
    setLoading(true)
    try {
      console.log('Starting dashboard API call...')
      
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 10000) // 10 second timeout
      
      const response = await fetch('/api/projects?action=dashboard', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ companyCode: 'C001' }),
        signal: controller.signal
      })
      
      clearTimeout(timeoutId)
      console.log('Dashboard API response status:', response.status)
      
      const result = await response.json()
      console.log('Dashboard API response:', result)
      
      if (result.success) {
        console.log('Setting summary:', result.data.summary)
        console.log('Setting projects:', result.data.projects)
        setSummary(result.data.summary || {
          totalProjects: 0,
          totalCosts: 0,
          totalRevenue: 0,
          netProfit: 0,
          profitMargin: 0
        })
        setProjects(result.data.projects || [])
      } else {
        console.error('Dashboard API error:', result)
        // Set default values on error
        setSummary({
          totalProjects: 0,
          totalCosts: 0,
          totalRevenue: 0,
          netProfit: 0,
          profitMargin: 0
        })
        setProjects([])
      }
    } catch (error) {
      console.error('Failed to load dashboard data:', error)
      // Set default values on error
      setSummary({
        totalProjects: 0,
        totalCosts: 0,
        totalRevenue: 0,
        netProfit: 0,
        profitMargin: 0
      })
      setProjects([])
    } finally {
      setLoading(false)
    }
  }

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
    try {
      const { data, error } = await supabase
        .from('projects')
        .select('id, name, code, status, budget, start_date')
        .order('start_date', { ascending: false })
        .limit(5)

      if (error) {
        console.error('Error fetching recent projects:', error)
        return
      }
      
      console.log('Recent projects loaded:', data)
      setRecentProjects(data || [])
    } catch (error) {
      console.error('Failed to load recent projects:', error)
    }
  }

  const fetchCategories = async () => {
    try {
      const { data, error } = await supabase
        .from('projects')
        .select('category_code')
        .not('category_code', 'is', null)

      if (error) {
        console.error('Error fetching categories:', error)
        return
      }
      
      const uniqueCategories = [...new Set(data?.map(p => p.category_code) || [])]
      setCategories(uniqueCategories)
    } catch (error) {
      console.error('Failed to load categories:', error)
    }
  }

  const handleProjectClick = async (project: Project) => {
    if (project.expanded) {
      // Collapse - remove WBS details
      setProjects(prev => prev.map(p => 
        p.project_code === project.project_code 
          ? { ...p, expanded: false, wbs_details: [] }
          : p
      ))
    } else {
      // Expand - load WBS details
      try {
        const response = await fetch('/api/projects?action=wbs-details', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ projectCode: project.project_code, companyCode: 'C001' })
        })
        
        const result = await response.json()
        console.log('WBS details response:', result)
        
        if (result.success) {
          setProjects(prev => prev.map(p => 
            p.project_code === project.project_code 
              ? { ...p, expanded: true, wbs_details: result.data.wbs_details || [] }
              : p
          ))
        } else {
          console.error('WBS details error:', result)
        }
      } catch (error) {
        console.error('Failed to load WBS details:', error)
      }
    }
  }

  useEffect(() => {
    loadDashboardData()
    fetchStats()
    fetchRecentProjects()
    fetchCategories()
  }, [])

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="p-4">
        {/* Financial Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Building className="w-8 h-8 text-blue-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Projects</p>
                <p className="text-2xl font-bold text-blue-900">{summary.totalProjects}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <DollarSign className="w-8 h-8 text-red-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Costs</p>
                <p className="text-2xl font-bold text-red-900">${summary.totalCosts.toLocaleString()}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <TrendingUp className="w-8 h-8 text-green-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Revenue</p>
                <p className="text-2xl font-bold text-green-900">${summary.totalRevenue.toLocaleString()}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Activity className="w-8 h-8 text-purple-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Net Profit</p>
                <p className={`text-2xl font-bold ${summary.netProfit >= 0 ? 'text-green-900' : 'text-red-900'}`}>
                  ${summary.netProfit.toLocaleString()}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Mobile-Optimized Filters */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-6 gap-4">
            <div className="col-span-1">
              <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
              <select className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-blue-500">
                <option value="">All Categories</option>
                {categories.map(category => (
                  <option key={category} value={category}>{category}</option>
                ))}
              </select>
            </div>
            <div className="col-span-1">
              <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <select className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-blue-500">
                <option value="">All Status</option>
                <option value="active">Active</option>
                <option value="planning">Planning</option>
                <option value="completed">Completed</option>
              </select>
            </div>
            <div className="col-span-1 sm:col-span-2 lg:col-span-1">
              <label className="block text-sm font-medium text-gray-700 mb-2">Search</label>
              <input 
                type="text" 
                placeholder="Project code or name..."
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="col-span-1">
              <label className="block text-sm font-medium text-gray-700 mb-2">Budget</label>
              <select className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-blue-500">
                <option value="">All Budgets</option>
                <option value="0-1M">Under $1M</option>
                <option value="1M-5M">$1M - $5M</option>
                <option value="5M+">Over $5M</option>
              </select>
            </div>
            <div className="col-span-1">
              <label className="block text-sm font-medium text-gray-700 mb-2">Actions</label>
              <div className="flex space-x-2">
                <button className="flex-1 px-3 py-2 bg-blue-600 text-white rounded-md text-sm hover:bg-blue-700 focus:ring-2 focus:ring-blue-500">
                  Filter
                </button>
                <button className="px-3 py-2 bg-gray-200 text-gray-700 rounded-md text-sm hover:bg-gray-300">
                  Clear
                </button>
              </div>
            </div>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Building className="w-8 h-8 text-blue-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">All Projects</p>
                <p className="text-2xl font-bold text-blue-900">{stats.total}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Play className="w-8 h-8 text-green-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Active</p>
                <p className="text-2xl font-bold text-green-900">{stats.active}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <CheckCircle className="w-8 h-8 text-emerald-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Completed</p>
                <p className="text-2xl font-bold text-emerald-900">{stats.completed}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <DollarSign className="w-8 h-8 text-purple-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Budget</p>
                <p className="text-2xl font-bold text-purple-900">${stats.totalBudget.toLocaleString()}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Projects Table */}
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden mb-6">
          <div className="px-4 py-3 border-b">
            <h3 className="text-lg font-medium">Recent Projects</h3>
            <p className="text-sm text-gray-600">Latest project activities</p>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Budget</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Start Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {recentProjects.map((project) => (
                  <tr key={project.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm font-mono">{project.code}</td>
                    <td className="px-4 py-3 text-sm font-medium">{project.name}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 text-xs rounded-full ${
                        project.status === 'active' ? 'bg-green-100 text-green-800' :
                        project.status === 'completed' ? 'bg-blue-100 text-blue-800' :
                        project.status === 'planning' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {project.status}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right text-sm">${project.budget?.toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm">{new Date(project.start_date).toLocaleDateString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Financial Projects Table */}
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          <div className="px-4 py-3 border-b flex justify-between items-center">
            <div>
              <h3 className="text-lg font-medium">Project Financial Summary</h3>
              <p className="text-sm text-gray-600">Real-time data from Universal Journal</p>
            </div>
            <button
              onClick={loadDashboardData}
              disabled={loading}
              className="flex items-center px-3 py-2 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
              Refresh
            </button>
          </div>

          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-2 text-gray-500">Loading project data...</p>
            </div>
          ) : projects.length === 0 ? (
            <div className="p-8 text-center">
              <p className="text-gray-500">No project financial data found</p>
              <p className="text-sm text-gray-400 mt-2">Check if projects exist in universal_journal table</p>
              <button
                onClick={loadDashboardData}
                className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
              >
                Retry Loading
              </button>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Project</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Budget</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Costs</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Revenue</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Net Amount</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Transactions</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Last Activity</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {projects.map((project, index) => (
                    <React.Fragment key={project.project_code || `project-${index}`}>
                      <tr className="hover:bg-gray-50 cursor-pointer"
                          onClick={() => handleProjectClick(project)}>
                        <td className="px-4 py-3 font-medium text-blue-600 hover:text-blue-800">
                          <div className="flex items-center">
                            <span className={`mr-2 transition-transform ${
                              project.expanded ? 'rotate-90' : ''
                            }`}>▶</span>
                            {project.project_code}
                          </div>
                        </td>
                        <td className="px-4 py-3 text-right">${project.budget?.toLocaleString() || 'N/A'}</td>
                        <td className="px-4 py-3 text-right">${(project.total_costs || project.actual_cost || 0).toLocaleString()}</td>
                        <td className="px-4 py-3 text-right">${(project.total_revenue || project.revenue || 0).toLocaleString()}</td>
                        <td className={`px-4 py-3 text-right font-medium ${
                          (project.net_amount || (project.revenue || 0) - (project.actual_cost || 0)) >= 0 ? 'text-green-600' : 'text-red-600'
                        }`}>
                          ${(project.net_amount || (project.revenue || 0) - (project.actual_cost || 0)).toLocaleString()}
                        </td>
                        <td className="px-4 py-3 text-right">{project.transaction_count || 0}</td>
                        <td className="px-4 py-3 text-sm text-gray-600">
                          {project.last_posting_date ? new Date(project.last_posting_date).toLocaleDateString() : 'N/A'}
                        </td>
                      </tr>
                      {project.expanded && project.wbs_details?.map((wbs) => (
                        <tr key={`${project.project_code}-${wbs.wbs_element}`} className="bg-blue-50">
                          <td className="px-4 py-3 text-sm text-gray-600 pl-8">
                            └─ {wbs.wbs_element}
                          </td>
                          <td className="px-4 py-3 text-right text-sm">-</td>
                          <td className="px-4 py-3 text-right text-sm">${(wbs.total_debits || 0).toLocaleString()}</td>
                          <td className="px-4 py-3 text-right text-sm">${(wbs.total_credits || 0).toLocaleString()}</td>
                          <td className={`px-4 py-3 text-right text-sm font-medium ${
                            (wbs.net_amount || 0) >= 0 ? 'text-green-600' : 'text-red-600'
                          }`}>
                            ${(wbs.net_amount || 0).toLocaleString()}
                          </td>
                          <td className="px-4 py-3 text-right text-sm">{wbs.transaction_count || 0}</td>
                          <td className="px-4 py-3 text-sm text-gray-600">
                            {wbs.last_posting_date ? new Date(wbs.last_posting_date).toLocaleDateString() : 'N/A'}
                          </td>
                        </tr>
                      ))}
                    </React.Fragment>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
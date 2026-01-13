'use client'

import { useState, useEffect } from 'react'
import { repositories } from '@/lib/repositories'

interface Activity {
  id: string
  code: string
  name: string
  description?: string
  planned_start_date: string
  planned_end_date: string
  actual_start_date?: string
  actual_end_date?: string
  planned_hours: number
  budget_amount: number
  progress_percentage: number
  status: 'not_started' | 'in_progress' | 'completed' | 'on_hold'
  wbs_node: {
    code: string
    name: string
  }
  responsible_user?: {
    name: string
    email: string
  }
  tasks_count: number
  completed_tasks: number
}

interface ActivitiesListProps {
  projectId: string
}

export default function ActivitiesList({ projectId }: ActivitiesListProps) {
  const [activities, setActivities] = useState<Activity[]>([])
  const [filteredActivities, setFilteredActivities] = useState<Activity[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [sortBy, setSortBy] = useState('code')
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(20)
  const [viewMode, setViewMode] = useState<'table' | 'cards'>('table')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadActivities()
  }, [projectId])

  useEffect(() => {
    filterAndSortActivities()
  }, [activities, searchTerm, statusFilter, sortBy, sortOrder])

  const loadActivities = async () => {
    try {
      console.log('Loading activities for project:', projectId)
      const data = await repositories.activities.findByProject(projectId)
      console.log('Raw activities data:', data)
      
      const formattedActivities: Activity[] = data.map(activity => ({
        id: activity.id,
        code: activity.code,
        name: activity.name,
        description: activity.description || undefined,
        planned_start_date: activity.planned_start_date || '',
        planned_end_date: activity.planned_end_date || '',
        actual_start_date: activity.actual_start_date || undefined,
        actual_end_date: activity.actual_end_date || undefined,
        planned_hours: activity.planned_hours || 0,
        budget_amount: activity.budget_amount || 0,
        progress_percentage: activity.progress_percentage || 0,
        status: (activity.status as Activity['status']) || 'not_started',
        wbs_node: {
          code: activity.wbs_nodes?.code || '',
          name: activity.wbs_nodes?.name || ''
        },
        responsible_user: undefined, // Removed for now
        tasks_count: 0,
        completed_tasks: 0
      }))
      
      console.log('Formatted activities:', formattedActivities)
      setActivities(formattedActivities)
    } catch (error) {
      console.error('Failed to load activities:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterAndSortActivities = () => {
    let filtered = activities

    // Apply search filter
    if (searchTerm) {
      filtered = filtered.filter(activity =>
        activity.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        activity.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        activity.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        activity.wbs_node.code.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    // Apply status filter
    if (statusFilter !== 'all') {
      filtered = filtered.filter(activity => activity.status === statusFilter)
    }

    // Apply sorting
    filtered.sort((a, b) => {
      let aValue: any, bValue: any
      
      switch (sortBy) {
        case 'name':
          aValue = a.name
          bValue = b.name
          break
        case 'status':
          aValue = a.status
          bValue = b.status
          break
        case 'progress':
          aValue = a.progress_percentage
          bValue = b.progress_percentage
          break
        case 'budget':
          aValue = a.budget_amount
          bValue = b.budget_amount
          break
        case 'start_date':
          aValue = new Date(a.planned_start_date)
          bValue = new Date(b.planned_start_date)
          break
        default:
          aValue = a.code
          bValue = b.code
      }

      if (typeof aValue === 'string') {
        return sortOrder === 'asc' ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue)
      }
      return sortOrder === 'asc' ? aValue - bValue : bValue - aValue
    })

    setFilteredActivities(filtered)
    setCurrentPage(1) // Reset to first page when filtering
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-100 text-green-800'
      case 'in_progress': return 'bg-blue-100 text-blue-800'
      case 'on_hold': return 'bg-yellow-100 text-yellow-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  const handleSort = (field: string) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortBy(field)
      setSortOrder('asc')
    }
  }

  // Pagination
  const totalPages = Math.ceil(filteredActivities.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const paginatedActivities = filteredActivities.slice(startIndex, startIndex + itemsPerPage)

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Activities ({filteredActivities.length})</h1>
          <p className="text-gray-600 text-sm">Project activities and work packages</p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={() => setViewMode(viewMode === 'table' ? 'cards' : 'table')}
            className="px-3 py-1 bg-gray-200 rounded text-sm hover:bg-gray-300"
          >
            {viewMode === 'table' ? '📋 Cards' : '📊 Table'}
          </button>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm">
            + New Activity
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4 items-center bg-gray-50 p-4 rounded">
        <div className="flex-1 min-w-64">
          <input
            type="text"
            placeholder="Search activities..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-3 py-2 border rounded text-sm"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="px-3 py-2 border rounded text-sm"
        >
          <option value="all">All Status</option>
          <option value="not_started">Not Started</option>
          <option value="in_progress">In Progress</option>
          <option value="completed">Completed</option>
          <option value="on_hold">On Hold</option>
        </select>
        <select
          value={sortBy}
          onChange={(e) => setSortBy(e.target.value)}
          className="px-3 py-2 border rounded text-sm"
        >
          <option value="code">Sort by Code</option>
          <option value="name">Sort by Name</option>
          <option value="status">Sort by Status</option>
          <option value="progress">Sort by Progress</option>
          <option value="budget">Sort by Budget</option>
          <option value="start_date">Sort by Start Date</option>
        </select>
      </div>

      {/* Table View */}
      {viewMode === 'table' && (
        <div className="bg-white rounded shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('code')}>
                    Code {sortBy === 'code' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('name')}>
                    Name {sortBy === 'name' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left">WBS</th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('status')}>
                    Status {sortBy === 'status' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('progress')}>
                    Progress {sortBy === 'progress' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('budget')}>
                    Budget {sortBy === 'budget' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('start_date')}>
                    Start Date {sortBy === 'start_date' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {paginatedActivities.map((activity) => (
                  <tr key={activity.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-xs">{activity.code}</td>
                    <td className="px-4 py-3">
                      <div className="font-medium">{activity.name}</div>
                      {activity.description && (
                        <div className="text-xs text-gray-500 truncate max-w-xs">{activity.description}</div>
                      )}
                    </td>
                    <td className="px-4 py-3 text-xs">{activity.wbs_node.code}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs ${getStatusColor(activity.status)}`}>
                        {activity.status.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center space-x-2">
                        <div className="w-16 bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-blue-600 h-2 rounded-full" 
                            style={{ width: `${activity.progress_percentage}%` }}
                          ></div>
                        </div>
                        <span className="text-xs">{activity.progress_percentage}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs">{formatCurrency(activity.budget_amount)}</td>
                    <td className="px-4 py-3 text-xs">{new Date(activity.planned_start_date).toLocaleDateString()}</td>
                    <td className="px-4 py-3">
                      <div className="flex space-x-1">
                        <button className="text-blue-600 hover:text-blue-800 text-xs px-2 py-1 rounded hover:bg-blue-50">
                          Edit
                        </button>
                        <button className="text-green-600 hover:text-green-800 text-xs px-2 py-1 rounded hover:bg-green-50">
                          Progress
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Cards View */}
      {viewMode === 'cards' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {paginatedActivities.map((activity) => (
            <div key={activity.id} className="bg-white rounded shadow p-4 hover:shadow-lg transition-shadow">
              <div className="flex justify-between items-start mb-2">
                <div className="flex-1">
                  <h3 className="font-medium text-sm">{activity.name}</h3>
                  <p className="text-xs text-gray-600 mt-1">{activity.code}</p>
                </div>
                <span className={`px-2 py-1 rounded text-xs ${getStatusColor(activity.status)}`}>
                  {activity.status.replace('_', ' ')}
                </span>
              </div>
              
              <div className="space-y-2">
                <div className="flex justify-between text-xs">
                  <span>Progress</span>
                  <span>{activity.progress_percentage}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-blue-600 h-2 rounded-full" 
                    style={{ width: `${activity.progress_percentage}%` }}
                  ></div>
                </div>
                
                <div className="text-xs text-gray-600 space-y-1">
                  <div>WBS: {activity.wbs_node.code}</div>
                  <div>Budget: {formatCurrency(activity.budget_amount)}</div>
                  <div>Start: {new Date(activity.planned_start_date).toLocaleDateString()}</div>
                </div>
                
                <div className="flex space-x-2 pt-2">
                  <button className="flex-1 text-blue-600 hover:text-blue-800 text-xs px-2 py-1 rounded hover:bg-blue-50 border">
                    Edit
                  </button>
                  <button className="flex-1 text-green-600 hover:text-green-800 text-xs px-2 py-1 rounded hover:bg-green-50 border">
                    Progress
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-between items-center bg-white p-4 rounded shadow">
          <div className="text-sm text-gray-600">
            Showing {startIndex + 1}-{Math.min(startIndex + itemsPerPage, filteredActivities.length)} of {filteredActivities.length} activities
          </div>
          <div className="flex space-x-2">
            <button
              onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
              disabled={currentPage === 1}
              className="px-3 py-1 border rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Previous
            </button>
            <span className="px-3 py-1 text-sm">
              Page {currentPage} of {totalPages}
            </span>
            <button
              onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
              disabled={currentPage === totalPages}
              className="px-3 py-1 border rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Next
            </button>
          </div>
        </div>
      )}

      {/* Empty State */}
      {filteredActivities.length === 0 && (
        <div className="text-center py-12 bg-white rounded shadow">
          <p className="text-gray-500 mb-4">
            {searchTerm || statusFilter !== 'all' ? 'No activities match your filters.' : 'No activities found.'}
          </p>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Create First Activity
          </button>
        </div>
      )}
    </div>
  )
}
'use client'

import { useState, useEffect } from 'react'
import { CalendarDays, Clock, DollarSign, Search, Plus, Play, Pause, CheckCircle, AlertCircle, Edit, GitBranch } from 'lucide-react'
import { repositories } from '@/lib/repositories'
import ActivityForm from './ActivityForm'
import ProgressUpdate from './ProgressUpdate'
import DependencyManager from './DependencyManager'

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
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [showProgress, setShowProgress] = useState(false)
  const [showDependencies, setShowDependencies] = useState(false)
  const [selectedActivity, setSelectedActivity] = useState<Activity | null>(null);
  const [wbsNodes, setWbsNodes] = useState<Array<{ id: string; code: string; name: string }>>([]);

  useEffect(() => {
    loadActivities()
    loadWbsNodes()
  }, [projectId])

  useEffect(() => {
    filterActivities()
  }, [activities, searchTerm, statusFilter])

  const loadActivities = async () => {
    try {
      const data = await repositories.activities.findByProject(projectId)
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
        responsible_user: undefined, // TODO: Add user relationship
        tasks_count: 0, // TODO: Get from tasks table
        completed_tasks: 0 // TODO: Calculate from tasks
      }))
      setActivities(formattedActivities)
    } catch (error) {
      console.error('Failed to load activities:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadWbsNodes = async () => {
    try {
      const data = await repositories.wbs.findByProject(projectId)
      setWbsNodes(data.map(node => ({ id: node.id, code: node.code, name: node.name })))
    } catch (error) {
      console.error('Failed to load WBS nodes:', error)
    }
  }

  const handleActivityCreated = () => {
    setShowForm(false)
    loadActivities()
  }

  const handleProgressUpdated = () => {
    setShowProgress(false)
    setSelectedActivity(null)
    loadActivities()
  }

  const handleDependenciesUpdated = () => {
    setShowDependencies(false)
    setSelectedActivity(null)
    loadActivities()
  }

  const openProgressUpdate = (activity: Activity) => {
    setSelectedActivity(activity)
    setShowProgress(true)
  }

  const openDependencyManager = (activity: Activity) => {
    setSelectedActivity(activity)
    setShowDependencies(true)
  }

  const filterActivities = () => {
    let filtered = activities

    if (searchTerm) {
      filtered = filtered.filter(activity =>
        activity.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        activity.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        activity.description?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter(activity => activity.status === statusFilter)
    }

    setFilteredActivities(filtered)
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed':
        return <CheckCircle className="h-4 w-4 text-green-600" />
      case 'in_progress':
        return <Play className="h-4 w-4 text-blue-600" />
      case 'on_hold':
        return <Pause className="h-4 w-4 text-yellow-600" />
      case 'not_started':
        return <Clock className="h-4 w-4 text-gray-600" />
      default:
        return <AlertCircle className="h-4 w-4 text-red-600" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800'
      case 'in_progress':
        return 'bg-blue-100 text-blue-800'
      case 'on_hold':
        return 'bg-yellow-100 text-yellow-800'
      case 'not_started':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-red-100 text-red-800'
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  const isOverdue = (activity: Activity) => {
    if (activity.status === 'completed') return false
    const today = new Date()
    const plannedEnd = new Date(activity.planned_end_date)
    return today > plannedEnd
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Activities</h1>
          <p className="text-gray-600 mt-1">Project activities and work packages</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
        >
          <Plus className="h-4 w-4" />
          New Activity
        </button>
      </div>

      <div className="flex gap-4 items-center">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <input
            type="text"
            placeholder="Search activities..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <option value="all">All Status</option>
          <option value="not_started">Not Started</option>
          <option value="in_progress">In Progress</option>
          <option value="completed">Completed</option>
          <option value="on_hold">On Hold</option>
        </select>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {filteredActivities.map((activity) => (
          <div key={activity.id} className={`bg-white rounded-lg shadow border hover:shadow-lg transition-shadow ${isOverdue(activity) ? 'border-red-200' : ''}`}>
            <div className="p-6 pb-3">
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(activity.status)}
                    <h3 className="text-lg font-semibold">{activity.name}</h3>
                    {isOverdue(activity) && (
                      <span className="bg-red-100 text-red-800 px-2 py-1 rounded text-xs font-medium">
                        Overdue
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-gray-600 mt-1">{activity.code}</p>
                  {activity.description && (
                    <p className="text-sm text-gray-500 mt-2">{activity.description}</p>
                  )}
                </div>
                <span className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(activity.status)}`}>
                  {activity.status.replace('_', ' ')}
                </span>
              </div>
            </div>
            <div className="p-6 pt-0 space-y-4">
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Progress</span>
                  <span>{activity.progress_percentage}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-blue-600 h-2 rounded-full" style={{ width: `${activity.progress_percentage}%` }}></div>
                </div>
                <div className="text-xs text-gray-600">
                  {activity.completed_tasks} of {activity.tasks_count} tasks completed
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 text-sm">
                <div className="flex items-center text-gray-600">
                  <CalendarDays className="h-4 w-4 mr-2" />
                  <div>
                    <div>Start: {new Date(activity.planned_start_date).toLocaleDateString()}</div>
                    <div>End: {new Date(activity.planned_end_date).toLocaleDateString()}</div>
                  </div>
                </div>
                <div className="flex items-center text-gray-600">
                  <DollarSign className="h-4 w-4 mr-2" />
                  <div>
                    <div>{formatCurrency(activity.budget_amount)}</div>
                    <div className="text-xs">{activity.planned_hours}h planned</div>
                  </div>
                </div>
              </div>

              <div className="pt-2 border-t">
                <div className="flex justify-between items-center">
                  <div>
                    <span className="border border-gray-300 px-2 py-1 rounded text-xs">
                      {activity.wbs_node.code}
                    </span>
                    <p className="text-xs text-gray-600 mt-1">{activity.wbs_node.name}</p>
                  </div>
                  <div className="flex items-center space-x-2">
                    {activity.responsible_user && (
                      <div className="text-right">
                        <p className="text-sm font-medium">{activity.responsible_user.name}</p>
                        <p className="text-xs text-gray-600">{activity.responsible_user.email}</p>
                      </div>
                    )}
                    <button
                      onClick={() => openProgressUpdate(activity)}
                      className="p-2 border border-gray-300 rounded hover:bg-gray-50"
                    >
                      <Edit className="h-3 w-3" />
                    </button>
                    <button
                      onClick={() => openDependencyManager(activity)}
                      className="p-2 border border-gray-300 rounded hover:bg-gray-50"
                    >
                      <GitBranch className="h-3 w-3" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredActivities.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500">No activities found matching your criteria.</p>
          <button className="mt-4 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2 mx-auto">
            <Plus className="h-4 w-4" />
            Create First Activity
          </button>
        </div>
      )}

      <div className="bg-white rounded-lg shadow border">
        <div className="p-6">
          <h3 className="text-lg font-semibold">Activities Summary</h3>
        </div>
        <div className="p-6 pt-0">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold">{activities.length}</div>
              <p className="text-sm text-gray-600">Total Activities</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-green-600">
                {activities.filter(a => a.status === 'completed').length}
              </div>
              <p className="text-sm text-gray-600">Completed</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">
                {activities.filter(a => a.status === 'in_progress').length}
              </div>
              <p className="text-sm text-gray-600">In Progress</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-red-600">
                {activities.filter(a => isOverdue(a)).length}
              </div>
              <p className="text-sm text-gray-600">Overdue</p>
            </div>
          </div>
        </div>
      </div>

      {/* Modal overlays */}
      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-semibold mb-4">Create New Activity</h2>
            <ActivityForm
              projectId={projectId}
              wbsNodes={wbsNodes}
              onSuccess={handleActivityCreated}
              onCancel={() => setShowForm(false)}
            />
          </div>
        </div>
      )}

      {showProgress && selectedActivity && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-lg w-full mx-4">
            <h2 className="text-xl font-semibold mb-4">Update Progress</h2>
            <ProgressUpdate
              activity={selectedActivity}
              onSuccess={handleProgressUpdated}
              onCancel={() => setShowProgress(false)}
            />
          </div>
        </div>
      )}

      {showDependencies && selectedActivity && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-semibold mb-4">Manage Dependencies</h2>
            <DependencyManager
              activity={selectedActivity}
              projectId={projectId}
              onSuccess={handleDependenciesUpdated}
              onCancel={() => setShowDependencies(false)}
            />
          </div>
        </div>
      )}
    </div>
  )
}
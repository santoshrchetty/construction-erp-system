// DEPRECATED: This file is marked for removal - no active dependencies found
// TODO: Remove after confirming no imports
/*
'use client'

import { useState, useEffect } from 'react'
import { repositories } from '@/lib/repositories'

interface Task {
  id: string
  name: string
  description?: string
  status: 'not_started' | 'in_progress' | 'completed' | 'on_hold'
  priority: 'low' | 'medium' | 'high' | 'critical'
  progress_percentage: number
  planned_start_date?: string
  planned_end_date?: string
  planned_hours?: number
  assigned_to?: string
  activity_id?: string
  wbs_node_id?: string
  created_at: string
}

interface TasksListProps {
  projectId: string
  activityId?: string
}

export default function TasksList({ projectId, activityId }: TasksListProps) {
  const [tasks, setTasks] = useState<Task[]>([])
  const [filteredTasks, setFilteredTasks] = useState<Task[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [priorityFilter, setPriorityFilter] = useState('all')
  const [viewMode, setViewMode] = useState<'kanban' | 'table' | 'list'>('kanban')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadTasks()
  }, [projectId, activityId])

  useEffect(() => {
    filterTasks()
  }, [tasks, searchTerm, statusFilter, priorityFilter])

  const loadTasks = async () => {
    try {
      const data = activityId 
        ? await repositories.tasks.findByActivity(activityId)
        : await repositories.tasks.findByProject(projectId)
      setTasks(data)
    } catch (error) {
      console.error('Failed to load tasks:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterTasks = () => {
    let filtered = tasks

    if (searchTerm) {
      filtered = filtered.filter(task =>
        task.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        task.description?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter(task => task.status === statusFilter)
    }

    if (priorityFilter !== 'all') {
      filtered = filtered.filter(task => task.priority === priorityFilter)
    }

    setFilteredTasks(filtered)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-100 text-green-800 border-green-200'
      case 'in_progress': return 'bg-blue-100 text-blue-800 border-blue-200'
      case 'on_hold': return 'bg-yellow-100 text-yellow-800 border-yellow-200'
      default: return 'bg-gray-100 text-gray-800 border-gray-200'
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'critical': return 'bg-red-100 text-red-800'
      case 'high': return 'bg-orange-100 text-orange-800'
      case 'medium': return 'bg-blue-100 text-blue-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const renderKanbanColumn = (status: string, title: string) => {
    const columnTasks = filteredTasks.filter(task => task.status === status)
    
    return (
      <div className="flex-1 bg-gray-50 rounded-lg p-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="font-medium text-sm">{title}</h3>
          <span className="bg-gray-200 text-gray-700 px-2 py-1 rounded text-xs">
            {columnTasks.length}
          </span>
        </div>
        
        <div className="space-y-3 max-h-96 overflow-y-auto">
          {columnTasks.map(task => (
            <div key={task.id} className="bg-white rounded shadow-sm p-3 border-l-4 border-blue-400">
              <div className="flex justify-between items-start mb-2">
                <h4 className="font-medium text-sm">{task.name}</h4>
                <span className={`px-2 py-1 rounded text-xs ${getPriorityColor(task.priority)}`}>
                  {task.priority}
                </span>
              </div>
              
              {task.description && (
                <p className="text-xs text-gray-600 mb-2">{task.description}</p>
              )}
              
              <div className="space-y-2">
                <div className="flex justify-between text-xs">
                  <span>Progress</span>
                  <span>{task.progress_percentage}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-1">
                  <div 
                    className="bg-blue-600 h-1 rounded-full" 
                    style={{ width: `${task.progress_percentage}%` }}
                  ></div>
                </div>
              </div>
              
              <div className="flex justify-between items-center mt-3 pt-2 border-t">
                <div className="text-xs text-gray-500">
                  {task.assigned_to ? '👤 Assigned' : '👤 Unassigned'}
                </div>
                <div className="flex space-x-1">
                  <button className="text-blue-600 hover:text-blue-800 text-xs">Edit</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Tasks ({filteredTasks.length})</h1>
          <p className="text-gray-600 text-sm">Project tasks and deliverables</p>
        </div>
        <div className="flex space-x-2">
          <select
            value={viewMode}
            onChange={(e) => setViewMode(e.target.value as any)}
            className="px-3 py-1 border rounded text-sm"
          >
            <option value="kanban">🗂️ Kanban</option>
            <option value="table">📊 Table</option>
            <option value="list">📋 List</option>
          </select>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm">
            + New Task
          </button>
        </div>
      </div>

      <div className="flex flex-wrap gap-4 items-center bg-gray-50 p-4 rounded">
        <div className="flex-1 min-w-64">
          <input
            type="text"
            placeholder="Search tasks..."
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
          value={priorityFilter}
          onChange={(e) => setPriorityFilter(e.target.value)}
          className="px-3 py-2 border rounded text-sm"
        >
          <option value="all">All Priority</option>
          <option value="critical">Critical</option>
          <option value="high">High</option>
          <option value="medium">Medium</option>
          <option value="low">Low</option>
        </select>
      </div>

      {viewMode === 'kanban' && (
        <div className="flex gap-4 overflow-x-auto pb-4">
          {renderKanbanColumn('not_started', 'Not Started')}
          {renderKanbanColumn('in_progress', 'In Progress')}
          {renderKanbanColumn('on_hold', 'On Hold')}
          {renderKanbanColumn('completed', 'Completed')}
        </div>
      )}

      {viewMode === 'table' && (
        <div className="bg-white rounded shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left">Name</th>
                  <th className="px-4 py-3 text-left">Status</th>
                  <th className="px-4 py-3 text-left">Priority</th>
                  <th className="px-4 py-3 text-left">Progress</th>
                  <th className="px-4 py-3 text-left">Assignee</th>
                  <th className="px-4 py-3 text-left">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredTasks.map((task) => (
                  <tr key={task.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3">
                      <div className="font-medium">{task.name}</div>
                      {task.description && (
                        <div className="text-xs text-gray-500">{task.description}</div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs ${getStatusColor(task.status)}`}>
                        {task.status.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs ${getPriorityColor(task.priority)}`}>
                        {task.priority}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center space-x-2">
                        <div className="w-16 bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-blue-600 h-2 rounded-full" 
                            style={{ width: `${task.progress_percentage}%` }}
                          ></div>
                        </div>
                        <span className="text-xs">{task.progress_percentage}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs">
                      {task.assigned_to ? '👤 Assigned' : '👤 Unassigned'}
                    </td>
                    <td className="px-4 py-3">
                      <button className="text-blue-600 hover:text-blue-800 text-xs px-2 py-1 rounded hover:bg-blue-50">
                        Edit
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {filteredTasks.length === 0 && (
        <div className="text-center py-12 bg-white rounded shadow">
          <p className="text-gray-500 mb-4">No tasks found.</p>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Create First Task
          </button>
        </div>
      )}
    </div>
  )
}
*/
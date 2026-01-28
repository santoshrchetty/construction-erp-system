'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface Activity {
  id: string
  code: string
  name: string
  description?: string
  project_code: string
  wbs_element: string
  planned_start_date?: string
  planned_end_date?: string
  duration_days?: number
  budget_amount?: number
  status: string
  priority: string
  progress_percentage?: number
}

type FormMode = 'create' | 'view' | 'edit'

interface ActivityFormProps {
  mode: FormMode
  activityId?: string
  projectCode: string
  wbsElement: string
  onClose: () => void
  onSave: (activity: Partial<Activity>) => void
}

export default function ProductionActivityForm({
  mode,
  activityId,
  projectCode,
  wbsElement,
  onClose,
  onSave
}: ActivityFormProps) {
  const [activity, setActivity] = useState<Partial<Activity>>({
    project_code: projectCode,
    wbs_element: wbsElement,
    status: 'not_started',
    priority: 'medium',
    progress_percentage: 0
  })
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [isEditing, setIsEditing] = useState(mode === 'create' || mode === 'edit')

  useEffect(() => {
    if (mode !== 'create' && activityId) {
      loadActivity()
    }
  }, [mode, activityId])

  const loadActivity = async () => {
    setLoading(true)
    try {
      const response = await fetch(`/api/activities?id=${activityId}`)
      const data = await response.json()
      if (data.success) {
        setActivity(data.data)
      }
    } catch (error) {
      console.error('Failed to load activity:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      const method = mode === 'create' ? 'POST' : 'PUT'
      const url = mode === 'create' ? '/api/activities' : `/api/activities?id=${activityId}`
      
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(activity)
      })
      
      const data = await response.json()
      if (data.success) {
        onSave(activity)
        if (mode === 'edit') {
          setIsEditing(false)
        }
      } else {
        alert('Save failed: ' + data.error)
      }
    } catch (error) {
      alert('Save error: ' + (error as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const getTitle = () => {
    switch (mode) {
      case 'create': return 'Create New Activity'
      case 'view': return 'Activity Details'
      case 'edit': return isEditing ? 'Edit Activity' : 'Activity Details'
      default: return 'Activity'
    }
  }

  const canEdit = mode === 'create' || (mode === 'edit' && isEditing)

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6">
          <div className="flex items-center">
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mr-3"></div>
            Loading activity...
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex justify-between items-center p-6 border-b">
          <div>
            <h2 className="text-xl font-semibold text-gray-900">{getTitle()}</h2>
            <p className="text-sm text-gray-600 mt-1">
              {projectCode} • {wbsElement}
            </p>
          </div>
          <div className="flex items-center space-x-2">
            {mode === 'view' && (
              <button
                onClick={() => setIsEditing(true)}
                className="px-3 py-1.5 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
              >
                <Icons.Edit className="w-4 h-4 inline mr-1" />
                Edit
              </button>
            )}
            {mode === 'edit' && !isEditing && (
              <button
                onClick={() => setIsEditing(true)}
                className="px-3 py-1.5 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
              >
                <Icons.Edit className="w-4 h-4 inline mr-1" />
                Edit
              </button>
            )}
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 rounded"
            >
              <Icons.X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Form Content */}
        <div className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Basic Information */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium text-gray-900 border-b pb-2">
                Basic Information
              </h3>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Activity Code *
                </label>
                {canEdit ? (
                  <input
                    type="text"
                    value={activity.code || ''}
                    onChange={(e) => setActivity(prev => ({ ...prev, code: e.target.value }))}
                    className="w-full border rounded-lg px-3 py-2"
                    placeholder="e.g., HW-0001.02-A01"
                  />
                ) : (
                  <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                    {activity.code || 'N/A'}
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Activity Name *
                </label>
                {canEdit ? (
                  <input
                    type="text"
                    value={activity.name || ''}
                    onChange={(e) => setActivity(prev => ({ ...prev, name: e.target.value }))}
                    className="w-full border rounded-lg px-3 py-2"
                    placeholder="Activity name"
                  />
                ) : (
                  <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                    {activity.name || 'N/A'}
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Description
                </label>
                {canEdit ? (
                  <textarea
                    value={activity.description || ''}
                    onChange={(e) => setActivity(prev => ({ ...prev, description: e.target.value }))}
                    className="w-full border rounded-lg px-3 py-2"
                    rows={3}
                    placeholder="Activity description"
                  />
                ) : (
                  <div className="w-full border rounded-lg px-3 py-2 bg-gray-50 min-h-[80px]">
                    {activity.description || 'No description'}
                  </div>
                )}
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Status
                  </label>
                  {canEdit ? (
                    <select
                      value={activity.status || 'not_started'}
                      onChange={(e) => setActivity(prev => ({ ...prev, status: e.target.value }))}
                      className="w-full border rounded-lg px-3 py-2"
                    >
                      <option value="not_started">Not Started</option>
                      <option value="in_progress">In Progress</option>
                      <option value="on_hold">On Hold</option>
                      <option value="completed">Completed</option>
                      <option value="cancelled">Cancelled</option>
                    </select>
                  ) : (
                    <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        activity.status === 'completed' ? 'bg-green-100 text-green-800' :
                        activity.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                        activity.status === 'on_hold' ? 'bg-yellow-100 text-yellow-800' :
                        activity.status === 'cancelled' ? 'bg-red-100 text-red-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {activity.status?.replace('_', ' ') || 'Not Started'}
                      </span>
                    </div>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Priority
                  </label>
                  {canEdit ? (
                    <select
                      value={activity.priority || 'medium'}
                      onChange={(e) => setActivity(prev => ({ ...prev, priority: e.target.value }))}
                      className="w-full border rounded-lg px-3 py-2"
                    >
                      <option value="low">Low</option>
                      <option value="medium">Medium</option>
                      <option value="high">High</option>
                      <option value="critical">Critical</option>
                    </select>
                  ) : (
                    <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        activity.priority === 'critical' ? 'bg-red-100 text-red-800' :
                        activity.priority === 'high' ? 'bg-orange-100 text-orange-800' :
                        activity.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-green-100 text-green-800'
                      }`}>
                        {activity.priority || 'Medium'}
                      </span>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Schedule & Budget */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium text-gray-900 border-b pb-2">
                Schedule & Budget
              </h3>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Start Date
                  </label>
                  {canEdit ? (
                    <input
                      type="date"
                      value={activity.planned_start_date || ''}
                      onChange={(e) => setActivity(prev => ({ ...prev, planned_start_date: e.target.value }))}
                      className="w-full border rounded-lg px-3 py-2"
                    />
                  ) : (
                    <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                      {activity.planned_start_date || 'Not set'}
                    </div>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    End Date
                  </label>
                  {canEdit ? (
                    <input
                      type="date"
                      value={activity.planned_end_date || ''}
                      onChange={(e) => setActivity(prev => ({ ...prev, planned_end_date: e.target.value }))}
                      className="w-full border rounded-lg px-3 py-2"
                    />
                  ) : (
                    <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                      {activity.planned_end_date || 'Not set'}
                    </div>
                  )}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Duration (Days)
                  </label>
                  {canEdit ? (
                    <input
                      type="number"
                      value={activity.duration_days || ''}
                      onChange={(e) => setActivity(prev => ({ ...prev, duration_days: parseInt(e.target.value) || 0 }))}
                      className="w-full border rounded-lg px-3 py-2"
                      min="0"
                    />
                  ) : (
                    <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                      {activity.duration_days || 0} days
                    </div>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Budget Amount
                  </label>
                  {canEdit ? (
                    <input
                      type="number"
                      value={activity.budget_amount || ''}
                      onChange={(e) => setActivity(prev => ({ ...prev, budget_amount: parseFloat(e.target.value) || 0 }))}
                      className="w-full border rounded-lg px-3 py-2"
                      min="0"
                      step="0.01"
                    />
                  ) : (
                    <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                      ${(activity.budget_amount || 0).toLocaleString()}
                    </div>
                  )}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Progress (%)
                </label>
                {canEdit ? (
                  <input
                    type="number"
                    value={activity.progress_percentage || 0}
                    onChange={(e) => setActivity(prev => ({ ...prev, progress_percentage: parseFloat(e.target.value) || 0 }))}
                    className="w-full border rounded-lg px-3 py-2"
                    min="0"
                    max="100"
                  />
                ) : (
                  <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                    <div className="flex items-center">
                      <div className="flex-1 bg-gray-200 rounded-full h-2 mr-3">
                        <div 
                          className="bg-blue-600 h-2 rounded-full" 
                          style={{ width: `${activity.progress_percentage || 0}%` }}
                        ></div>
                      </div>
                      <span className="text-sm font-medium">
                        {activity.progress_percentage || 0}%
                      </span>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="flex justify-end space-x-3 p-6 border-t bg-gray-50">
          <button
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
          >
            {mode === 'view' && !isEditing ? 'Close' : 'Cancel'}
          </button>
          
          {canEdit && (
            <button
              onClick={handleSave}
              disabled={saving || !activity.code || !activity.name}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {saving ? 'Saving...' : mode === 'create' ? 'Create Activity' : 'Save Changes'}
            </button>
          )}
          
          {mode === 'edit' && isEditing && (
            <button
              onClick={() => setIsEditing(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
            >
              Cancel Edit
            </button>
          )}
        </div>
      </div>
    </div>
  )
}